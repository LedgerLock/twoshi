FROM ubuntu:trusty

RUN apt-get -y update
RUN apt-get install -y software-properties-common nano curl

RUN add-apt-repository ppa:bitcoin/bitcoin
RUN apt-get update
RUN apt-get install -y bitcoind
RUN apt-get remove -y bitcoind

RUN curl -SL https://bitcoin.org/bin/0.10.0/test/bitcoin-0.10.0rc3-linux64.tar.gz \
    | tar zxvf - 
RUN cp bitcoin-0.10.0/bin/* /usr/local/bin/
RUN cp bitcoin-0.10.0/include/* /usr/local/include/
RUN cp bitcoin-0.10.0/lib/* /usr/local/lib/

RUN mkdir ~/.bitcoin
RUN echo "rpcuser=test\nrpcpassword=test\n" > ~/.bitcoin/bitcoin.conf

RUN echo "alias rt='bitcoin-cli -regtest'" >> ~/.bashrc

ADD bitcoind_launch.sh /etc/init.d/
RUN chmod 755 /etc/init.d/bitcoind_launch.sh
RUN update-rc.d bitcoind_launch.sh defaults

RUN printf "\n/etc/init.d/bitcoind_launch.sh" >> /etc/bash.bashrc
