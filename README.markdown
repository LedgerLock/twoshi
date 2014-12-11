# A local two-node Bitcoin [regtest](https://bitcoin.org/en/developer-examples#regtest-mode) network. 
## One [toshi](https://toshi.io) node, one [bitcoind](https://en.bitcoin.it/wiki/Bitcoind) node, [Dockerized](https://www.docker.com/).

Inspired by
- [toshi docker image](http://www.soroushjp.com/2014/10/15/deploying-your-own-toshi-api-bitcoin-node-using-coreos-docker-aws/)
- [creating-your-own-experimental-bitcoin-network](http://geraldkaszuba.com/creating-your-own-experimental-bitcoin-network/)

# How to use twoshi
### Docker
- [Install Docker](https://docs.docker.com/installation/)

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
If you are wondering why we need to run console in the bitcoind container, the reason is the way [docker works](https://docs.docker.com/userguide/dockerizing/). We want to keep the bitconid container running but Docker containers only run as long as the command we specify is active.

### Control
- The Bitcoind shell accepts the alias `rt` for `bitcoind -regtest` so you can use the [bitcoind api](https://bitcoin.org/en/developer-reference#bitcoin-core-apis), for example:
```Batchfile
	root@bitcoind:/# rt getinfo
	root@bitcoind:/# rt getpeerinfo
	root@bitcoind:/# rt setgenerate true 101
	root@bitcoind:/# rt getnewaddress
	...........
```
Of course, this is not the way to do it, you want to control it programatically.

- connect to the bitcoind node with RPC using a [bitcoin rpc client](https://en.bitcoin.it/wiki/API_reference_(JSON-RPC)#Ruby)
```Ruby
	node = BitcoinRPC.new('http://test:test@127.0.0.1:18332')
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
[For example](https://github.com/faye/faye-websocket-ruby), subscribing to transactions:
```Ruby
	require 'faye/websocket'
	require 'eventmachine'

	EM.run {
	  ws = Faye::WebSocket::Client.new('ws://localhost:5000')

	  ws.on :open do |event|
	    p [:open]
	    ws.send('{"subscribe":"'+"transactions"+'"}')
	  end

	  .......
	}
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

### Debug
- If after cloning you type `make twoshi` and it just doesn't work, make sure you cloned recursively
<pre>
git clone <b>--recursive</b> git@github.com:LedgerLock/twoshi.git
</pre>