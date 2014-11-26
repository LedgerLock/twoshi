# Local bitcoin network 
## with one [bitcoind](https://en.bitcoin.it/wiki/Bitcoind) node and one [toshi](https://toshi.io) node
Based on 
- [toshi docker image](http://www.soroushjp.com/2014/10/15/deploying-your-own-toshi-api-bitcoin-node-using-coreos-docker-aws/)
- [creating-your-own-experimental-bitcoin-network](http://geraldkaszuba.com/creating-your-own-experimental-bitcoin-network/)

### to run the network
#### create node images
- clone this repo, and init the toshi submodule which is on the docker branch until such time that my [pull request](https://github.com/coinbase/toshi/pull/131) is merged into coinbase/toshi
```Batchfile
	git clone git@github.com:assafshomer/regtest-docker.git 	
	cd regtest-docker
	git submodule init
	git submodule update	
```
- cd back into this repo and build the toshi and bitcoind images
```Batchfile
	cd regtest-docker
	make build_regtest_images
```
- If no change was made to one of the images you can create only one or the other (or none)
```Batchfile
	make build_bitcoind
	make build_toshi
```
#### launch node containers
- launch the toshi container 
```Batchfile
	make toshi
```
- from the CMD prompt of the toshi container, run a script that will set appropriate environment variables, migrate the postgres db and launch the toshi node
```Batchfile
	./toshi_launch.sh
```
- launch a web broswer and visit localhost:5000, you should see the toshi regtest client
- from a new terminal window on your machine launch the bitcoind container
```Batchfile
	make bitcoind
```
- from the CMD prompt of the bitcoind container run a script that will launch the bitcoind node, connect the two peers, and mine 101 blocks
```Batchfile
	./bitcoind_launch.sh 
```
- visit localhost:5000, you should see the new 101 blocks in the toshi client



### TODO
- automate the "paste into CMD" parts
- ~~include toshi as a git submodule instead of manually cloaning it along side this repo~~
- daemonize both containers
- connect to both with RPC