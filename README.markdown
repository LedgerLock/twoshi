# Local bitcoin network 
## with one [bitcoind](https://en.bitcoin.it/wiki/Bitcoind) node and one [toshi](https://toshi.io) node
Based on 
- [toshi docker image](http://www.soroushjp.com/2014/10/15/deploying-your-own-toshi-api-bitcoin-node-using-coreos-docker-aws/)
- [creating-your-own-experimental-bitcoin-network](http://geraldkaszuba.com/creating-your-own-experimental-bitcoin-network/)

### to run the network
- clone this repo, including the toshi submodule which is on the docker branch until such time that my [pull request](https://github.com/coinbase/toshi/pull/131) is merged into coinbase/toshi
```Batchfile
	git clone --recursive git@github.com:assafshomer/regtest-docker.git
	cd regtest-docker 	
```
- launch the regtest 2 node network
#### fully daemonized
```Batchfile
	make regtest
```
Unfortunately, at the moment the bitcoind client shuts down immediatly

#### toshi daemonized, bitcoind shell
- launch the regtest 2 node network with tohsi 
```Batchfile
	make regtest_shell
```
- in the bitcoind CMD prompt launch the init script
```Batchfile
	./bitcoind_launch.sh
```
- visit localhost:5000, you should see a new the toshi client with one node connected to it.
- you can connect to this node with RPC using a [bitcoin rpc client](https://en.bitcoin.it/wiki/API_reference_(JSON-RPC)#Ruby)
```Ruby
	node = BitcoinRPC.new('http://test:test@127.0.0.1:18332')
	node.getinfo
	node.setgenerate(true,101)
	node.sendtoaddress(node.getnewaddress,123.456)
	........
```


### TODO
- daemonize the bitcoind client without it shutting down
- connect to both with RPC