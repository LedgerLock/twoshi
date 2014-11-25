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