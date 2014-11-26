FROM ubuntu:precise

RUN apt-get -y update
RUN apt-get install -y python-software-properties nano

RUN add-apt-repository ppa:bitcoin/bitcoin
RUN apt-get update
RUN apt-get install -y bitcoind

RUN mkdir ~/.bitcoin
RUN echo "rpcuser=test\nrpcpassword=test\n" > ~/.bitcoin/bitcoin.conf

RUN echo "alias rt='bitcoind -regtest'" >> ~/.bashrc

ADD bitcoind_launch.sh ./
RUN chmod a+wx bitcoind_launch.sh

ADD bitcoind_launch.sh /etc/init.d/
RUN chmod 755 /etc/init.d/bitcoind_launch.sh
RUN update-rc.d bitcoind_launch.sh defaults

RUN printf "\n/etc/init.d/bitcoind_launch.sh" >> /etc/bash.bashrc