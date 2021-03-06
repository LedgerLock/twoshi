# A local two-node Bitcoin [regtest](https://bitcoin.org/en/developer-examples#regtest-mode) network. 
## One [toshi](https://toshi.io) node, one [bitcoind](https://en.bitcoin.it/wiki/Bitcoind) node, [Dockerized](https://www.docker.com/).

Inspired by
- [toshi docker image](http://www.soroushjp.com/2014/10/15/deploying-your-own-toshi-api-bitcoin-node-using-coreos-docker-aws/)
- [creating-your-own-experimental-bitcoin-network](http://geraldkaszuba.com/creating-your-own-experimental-bitcoin-network/)

# How to use twoshi
- For OSX see seperate section below.

### Docker
- [Install Docker](https://docs.docker.com/installation/)
- On Ubuntu, you need to [edit /etc/default/docker](https://github.com/docker/fig/issues/88):
```
1. Change the DOCKER_OPTS in /etc/default/docker to:
DOCKER_OPTS="-H tcp://127.0.0.1:4243 -H unix:///var/run/docker.sock"

2. Restart docker
sudo restart docker
sudo restart docker.io    (on ubuntu 14.04)

3. Set DOCKER_HOST (.bashrc)
export DOCKER_HOST=tcp://localhost:4243
```

### Clone
- clone this repo, including the toshi submodule which is on the docker branch until such time that my [pull request](https://github.com/coinbase/toshi/pull/131) is merged into coinbase/toshi
```Batchfile
	git clone --recursive git@github.com:LedgerLock/twoshi.git
	cd twoshi
```

### Launch
- launch the regtest two-node-network
```Batchfile
	make twoshi
```
- If you don't have any other docker containers you care about and you wish to remove all lingering images and containers before launching twoshi you can use
```Batchfile
	make twoshi_clean
```
which will first clear everything up and then launch twoshi

The first time you run this it will take a little while to build the docker images. After that it will be very fast.

- The Toshi docker container is running in the background (daemonized)
- Visit localhost:5000, you should see the toshi client with one node (the bitcoind client) connected to it.

![Alt text](/images/toshionlaunch.png?raw=true "Toshi cotainer hooked up to bitcoind on startup, with 101 blocks mined")

- The Bitcoind docker container is running a terminal console. Hit enter and you should see
```Batchfile
	root@bitcoind:/#
```
If you are wondering why we need to run console in the bitcoind container, the reason is the way [docker works](https://docs.docker.com/userguide/dockerizing/). We want to keep the bitcoind container running but Docker containers only run as long as the command we specify is active.

### Bitcoind Version support
The bitcoind node can either run with the latest version supported by [ppa bitcoin:bitcoin](https://launchpad.net/~bitcoin/+archive/ubuntu/bitcoin), currently on **Version 0.9.4** or use the new [version 10](https://github.com/bitcoin/bitcoin/blob/0.10/doc/release-notes.md) (more specifically bitcoin-0.10.0rc3)
- Version 9
<pre>
	<b>make twoshi</b>(_clean)
</pre>
- Version 10
<pre>
	<b>make twoshi</b>(_clean) <b>VERSION=10</b>
</pre>

### Differences for OSX
Docker does not run natively on OSX. As a consequence, the following steps should be taken:
- We recommend using homebrew / cask to install docker [as explained here](http://penandpants.com/2014/03/09/docker-via-homebrew/).
- Instead of connecting to localhost:5000 you will need to connect to the VM running docker. The VM's IP address is defined by the DOCKER_HOST env variable. For instance if DOCKER_HOST=tcp://192.168.59.103:2376 then browse to 192.168.59.103:5000

### Environment Variables and Foreman
An easier way to launch Twoshi is to use 
```Batchfile
	foreman start
```
and add a **.env** file at the root of Twoshi.
If no environment variables are specified, the defaults are:
* bitcoind version 90300
* not running cleanup (i.e. running `make twoshi`, not `make twoshi_clean`)
* bitcoind waits for 5 seconds for toshi to get ready before attempting to connect

You can change that by adding a .env file. [For example](/examples/.env.example), if you want to run bitcoind version 10, with a 25 seconds delay and cleaning up all docker containers, add the following to your .env file:

```Batchfile
	DELAY=25
	VERSION=10
	CLEAN=TRUE
```

### Control
#### Bitcoind node shell
The Bitcoind shell accepts the alias `rt` for `bitcoind -regtest` so you can use the [bitcoind api](https://bitcoin.org/en/developer-reference#bitcoin-core-apis), for example:
```Batchfile
	root@bitcoind:/# rt getinfo
	root@bitcoind:/# rt getpeerinfo
	root@bitcoind:/# rt setgenerate true 101
	root@bitcoind:/# rt getnewaddress
	root@bitcoind:/# rt sendtoaddress $(rt getnewaddress) 1
	...........
```
Of course, this is not the way to do it, you want to control it programatically.

#### Bitcoind RPC
Connect to the bitcoind node with RPC using a [bitcoin rpc client](https://en.bitcoin.it/wiki/API_reference_(JSON-RPC)#Ruby). You can use the [example implementation](/examples/bitcoin_rpc.rb) that connects you directly to the bitcoind in twoshi.
For example, in the twoshi root directory you can launch an IRB console and type

```Ruby
	require './examples/bitcoin_rpc.rb'
	node = BitcoinRPC.new
	node.getinfo
	node.setgenerate(true,101)
	node.sendtoaddress(node.getnewaddress,123.456)
	........
```

#### Bitcoind [REST API](https://github.com/bitcoin/bitcoin/blob/0.10/doc/release-notes.md#rest-interface) (Version 10 only)
- If you are using [bitcoind Version 10](# Bitcoind Version support), you can also take advantage of the new [REST capabilities of bitcoind](https://github.com/bitcoin/bitcoin/blob/0.10/doc/release-notes.md#rest-interface). 
For example, here is how we can get json data about the top block:

```Ruby
	require './examples/bitcoin_rpc.rb'
	node = BitcoinRPC.new
	resturl = 'http://localhost:18332/rest/'	
	url = resturl +'block/'+node.getblock(node.getblockhash(node.getblockcount))['hash']+'.json'
	data = Net::HTTP.get(URI(url))
	json = JSON.parse(data)
```
and you should see the json data of the top block receieved from the bitcoind node.

#### [Toshi REST API](https://toshi.io/docs/)
Use the toshi [api](https://toshi.io/docs/), for example, find the [balance in an address](https://toshi.io/docs/#get-address-balance)
```Batchfile
	GET https://localhost:5000/api/<version>/addresses/<hash>
```

#### [Toshi WebSocket](https://toshi.io/docs/#websockets)
Subscribe to toshi transactions and blocks [websocket notifications](https://toshi.io/docs/#websockets) with the following connection URL
```Batchfile
	ws://localhost:5000
```
See this [example implementation](/examples/toshi_websocket.rb) for subscribing to transactions.

For example, in the twoshi root directory you can launch an IRB console and type:
```Ruby
	require './examples/toshi_websocket.rb'
	require './examples/bitcoin_rpc.rb'
	node = BitcoinRPC.new
 	node.sendtoaddress(node.getnewaddress,1) 
```
and you should see printed on the screen the tx message receieved from Toshi:

```Batchfile
	2.0.0-p481 :007 > "new event [{\"subscription\":\"transactions\",\"data\":{\"hash\":....]"

```

### Stop
- hit **CTRL+D** in the bitcoind CMD prompt you were left with in the host terminal where you typed **make twoshi**
- you can also type in a **host** terminal window
```Batchfile
	docker stop bitcoind
```
This stops the bitcoind daemon.
- if you visit localhost:5000 you can see that the toshi client is now offline with 0 peers connected to it

![Alt text](/images/toshioffline.png?raw=true "Toshi cotainer offline")

### Reconnect

- restart the stopped bitcoind container
```Batchfile
	docker restart bitcoind	
```
At the moment, when you do this a new bitcoind damon is launched and automatically connects to toshi, and as a consequence toshi will **register a new peer** (not sure this matters).

![Alt text](/images/toshibackonline.png?raw=true "Toshi cotainer back online, connected to the restarted bitcoind container counted as a new peer")

- You can attach to the container's terminal
```Batchfile
	docker attach bitcoind
```

### Cleanup
- The first time you do this you need to give the scripts exec permissions
```Batchfile
	chmod a+wx scripts/cleardocker*.sh
```
- If you are **NOT** worried about other docker containers running on your host 
```Batchfile
	cd scripts
	./cleardocker.sh
```
- If you have other docker containers running on your host 
```Batchfile
	cd scripts
	./cleardocker_byname.sh toshi
	./cleardocker_byname.sh bitcoind
```

- You can also run
```Batchfile
	make cleanup
```
which will run cleardocker.sh for you

### Troubleshooting
- If after cloning the repo you type `make twoshi` and it just doesn't work, make sure you cloned recursively
<pre>
git clone <b>--recursive</b> git@github.com:LedgerLock/twoshi.git
</pre>
- If both toshi is launched (as you can check by pointing your browser to `localhost:5000`) and bitcoind is running (as you can confirm by hitting return and being inside `root@bitcoind:/# `) but they are disconnected (see red indication **offline** in image below)

![Alt text](/images/offline.png?raw=true "Toshi cotainer is disconnected from bitcoind")

try to increase the 5 seconds delay in [bitcoind/bitcoind_launch](/bitcoind/bitcoind_launch.sh)
<pre>
	.....
	# increase the number of seconds to more than 5 if bitcoind didn't manage to connect to toshi
	<strike>sleep "5"</strike>
	<b>sleep "10"</b>
	echo "Adding Toshi node at IP:"$TOSHI_IP
	.....
</pre>
and build it again
```Batchfile
	make twoshi_clean
```
