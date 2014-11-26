# Local bitcoin network 
## with one [bitcoind](https://en.bitcoin.it/wiki/Bitcoind) node and one [toshi](https://toshi.io) node
Based on 
- [toshi docker image](http://www.soroushjp.com/2014/10/15/deploying-your-own-toshi-api-bitcoin-node-using-coreos-docker-aws/)
- [creating-your-own-experimental-bitcoin-network](http://geraldkaszuba.com/creating-your-own-experimental-bitcoin-network/)

## How to run the network
### Clone
- clone this repo, including the toshi submodule which is on the docker branch until such time that my [pull request](https://github.com/coinbase/toshi/pull/131) is merged into coinbase/toshi
```Batchfile
	git clone --recursive git@github.com:assafshomer/regtest-docker.git
	cd regtest-docker 	
```
### Launch 
- launch the regtest 2 node network with tohsi daemonized, bitcoind shell
```Batchfile
	make regtest
```
The first time you run this it will take a little while to build the images. After that it will be very fast.

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

### Stop
- hit CTRL+D in the bitcoind CMD prompt you were left with in the host terminal where you typed **make regtest**

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

### TODO
- connect to toshi tx stream