# Local bitcoin network 
## with one [bitcoind](https://en.bitcoin.it/wiki/Bitcoind) node and one [toshi](https://toshi.io) node
Based on 
- [toshi docker image](http://www.soroushjp.com/2014/10/15/deploying-your-own-toshi-api-bitcoin-node-using-coreos-docker-aws/)
- [creating-your-own-experimental-bitcoin-network](http://geraldkaszuba.com/creating-your-own-experimental-bitcoin-network/)

### to run the network
- clone this repo, including the toshi submodule which is on the docker branch until such time that my [pull request](https://github.com/coinbase/toshi/pull/131) is merged into coinbase/toshi
```Batchfile
	git clone --recursive git@github.com:assafshomer/regtest-docker.git 	
```
- cd into this repo and launch the regtest 2 node network
```Batchfile
	cd regtest-docker
	make regtest
```
- visit localhost:5000, you should see a new the toshi client with one node connected to it. Unfortunately, at the moment the bitcoind client shuts down immediatly


### TODO
- daemonize the bitcoind client without it shutting down
- connect to both with RPC