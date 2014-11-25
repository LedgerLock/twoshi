# Local bitcoin network 
## with one [bitcoind](https://en.bitcoin.it/wiki/Bitcoind) node and one [toshi](https://toshi.io) node
Based on 
- [toshi docker image](http://geraldkaszuba.com/creating-your-own-experimental-bitcoin-network/)
- [creating-your-own-experimental-bitcoin-network](http://geraldkaszuba.com/creating-your-own-experimental-bitcoin-network/)

### to run the network
- clone this repo
- clone the toshi repo's branch with an ammended Docker file, along side this repo
```
	cd ../
	git clone git@github.com:assafshomer/toshi.git --branch docker
```
- cd back into this repo and build the toshi and bitcoind images
```
	cd regtest-docker
	make build_regtest_images
```
- launch the toshi container 
```
	make toshi
```
- paste this code into the CMD prompt of the toshi container
```
	export DATABASE_URL=postgres://postgres:@$DB_PORT_5432_TCP_ADDR:$DB_PORT_5432_TCP_PORT
	export REDIS_URL=redis://$REDIS_PORT_6379_TCP_ADDR:$REDIS_PORT_6379_TCP_PORT
	export TOSHI_ENV=test
	export TOSHI_NETWORK=regtest
	export NODE_ACCEPT_INCOMING=true
	export NODE_LISTEN_PORT=18444
	bundle exec rake db:migrate
	foreman start -c web=1,block_worker=1,transaction_worker=1,peer_manager=1
```
- launch a web broswer and visit localhost:5000, you should see the toshi regtest client

