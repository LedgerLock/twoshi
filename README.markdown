# A local two-node Bitcoin [regtest](https://bitcoin.org/en/developer-examples#regtest-mode) network. 
## One [toshi](https://toshi.io) node, one [bitcoind](https://en.bitcoin.it/wiki/Bitcoind) node, [Dockerized](https://www.docker.com/).

Inspired by
- [toshi docker image](http://www.soroushjp.com/2014/10/15/deploying-your-own-toshi-api-bitcoin-node-using-coreos-docker-aws/)
- [creating-your-own-experimental-bitcoin-network](http://geraldkaszuba.com/creating-your-own-experimental-bitcoin-network/)

# How to use twoshi
### Docker
- [Install Docker](https://docs.docker.com/installation/) (For OSX we recommend [these homebrew instructions](http://penandpants.com/2014/03/09/docker-via-homebrew/))

### Clone
- clone this repo, including the toshi submodule which is on the docker branch until such time that my [pull request](https://github.com/coinbase/toshi/pull/131) is merged into coinbase/toshi
```Batchfile
	git clone --recursive git@github.com:LedgerLock/twoshi.git
	cd twoshi
```
### Launch 
- launch the regtest two-node-network (OSX users: if the following 'make' command causes [this](http://stackoverflow.com/questions/25372781/docker-error-var-run-docker-sock-no-such-file-or-directory) error, add environment variables to sudo as explained [here](http://craiccomputing.blogspot.com/2010/10/setting-environment-variables-for-sudo.html).
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
If you are wondering why we need to run console in the bitcoind container, the reason is the way [docker works](https://docs.docker.com/userguide/dockerizing/). We want to keep the bitconid container running but Docker containers only run as long as the command we specify is active.

### Control
- The Bitcoind shell accepts the alias `rt` for `bitcoind -regtest` so you can use the [bitcoind api](https://bitcoin.org/en/developer-reference#bitcoin-core-apis), for example:
```Batchfile
	root@bitcoind:/# rt getinfo
	root@bitcoind:/# rt getpeerinfo
	root@bitcoind:/# rt setgenerate true 101
	root@bitcoind:/# rt getnewaddress
	root@bitcoind:/# rt sendtoaddress $(rt getnewaddress) 1
	...........
```
Of course, this is not the way to do it, you want to control it programatically.

- connect to the bitcoind node with RPC using a [bitcoin rpc client](https://en.bitcoin.it/wiki/API_reference_(JSON-RPC)#Ruby). You can use the [example implementation](/examples/bitcoin_rpc.rb) that connects you directly to the bitcoind in twoshi.
For example, in the twoshi root directory you can launch an IRB console and type

```Ruby
	require './examples/bitcoin_rpc.rb'
	node = BitcoinRPC.new
	node.getinfo
	node.setgenerate(true,101)
	node.sendtoaddress(node.getnewaddress,123.456)
	........
```

- use the toshi [api](https://toshi.io/docs/), for example, find the [balance in an address](https://toshi.io/docs/#get-address-balance)
```Batchfile
	GET https://localhost:5000/api/<version>/addresses/<hash>
```
- subscribe to toshi transactions and blocks [websocket notifications](https://toshi.io/docs/#websockets) with the following connection URL
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

```Ruby
2.0.0-p481 :007 > "new event [{\"subscription\":\"transactions\",\"data\":{\"hash\":....]"

```

### Stop
- hit **CTRL+D** in the bitcoind CMD prompt you were left with in the host terminal where you typed **make twoshi**
- you can also type in a **host** terminal window
```Batchfile
	sudo docker stop bitcoind
```
This stops the bitcoind daemon.
- if you visit localhost:5000 you can see that the toshi client is now offline with 0 peers connected to it

![Alt text](/images/toshioffline.png?raw=true "Toshi cotainer offline")

### Reconnect

- restart the stopped bitcoind container
```Batchfile
	sudo docker restart bitcoind	
```
At the moment, when you do this a new bitcoind damon is launched and automatically connects to toshi, and as a consequence toshi will **register a new peer** (not sure this matters).

![Alt text](/images/toshibackonline.png?raw=true "Toshi cotainer back online, connected to the restarted bitcoind container counted as a new peer")

- You can attach to the container's terminal
```Batchfile
	sudo docker attach bitcoind
```

### Cleanup
- The first time you do this you need to give the scripts exec permissions
```Batchfile
	sudo chmod a+wx scripts/cleardocker*.sh
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

try to increase the 5 seconds delay in [bitcoind-regtest/bitcoind_launch](/bitcoind-regtest/bitcoind_launch.sh)
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
