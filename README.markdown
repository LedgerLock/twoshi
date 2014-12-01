# A local two-node Bitcoin [regtest](https://bitcoin.org/en/developer-examples#regtest-mode) network 
## with one [toshi](https://toshi.io) node and one [bitcoind](https://en.bitcoin.it/wiki/Bitcoind) node, powered by [Docker](https://www.docker.com/)

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
The first time you run this it will take a little while to build the docker images. After that it will be very fast.

- The Toshi docker container is running in the background (daemonized)
- The Bitcoind docker container is running a terminal console (hit enter to see that)

### Control
- visit localhost:5000, you should see a new the toshi client with one node connected to it.
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
[For example](https://github.com/faye/faye-websocket-ruby), subscribing to transactions would involve sending the string
```Ruby
	require 'faye/websocket'
	require 'eventmachine'

	EM.run {
	  ws = Faye::WebSocket::Client.new('ws://localhost:5000')

	  ws.on :open do |event|
	    p [:open]
	    ws.send('{"subscribe":"'+"transactions"+'"}')
	  end

	  ws.on :message do |event|
	    p [:message, event.data]
	  end

	  ws.on :close do |event|
	    p [:close, event.code, event.reason]
	    ws = nil
	  end
	}
```

### Stop
- hit **CTRL+D** in the bitcoind CMD prompt you were left with in the host terminal where you typed **make regtest**

### Reconnect
```Batchfile
	sudo docker restart bitcoind
```

### Cleanup
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