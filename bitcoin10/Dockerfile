FROM ubuntu:trusty

RUN apt-get -y update
RUN apt-get install -y software-properties-common nano curl

RUN add-apt-repository ppa:bitcoin/bitcoin
RUN apt-get update
RUN apt-get install -y bitcoind
RUN apt-get remove -y bitcoind

RUN curl -SL https://s3-us-west-2.amazonaws.com/bitcoin-regtest-image/bitcoin-regtest.tar.gz \
    | tar zxvf - 
RUN cp bitcoin-regtest/bin/* /usr/local/bin/
RUN cp bitcoin-regtest/include/* /usr/local/include/
RUN cp bitcoin-regtest/lib/* /usr/local/lib/

RUN mkdir ~/.bitcoin
RUN echo "rpcuser=test\nrpcpassword=test\n" > ~/.bitcoin/bitcoin.conf

RUN echo "alias rt='bitcoin-cli -regtest'" >> ~/.bashrc

ADD bitcoind_launch.sh /etc/init.d/
RUN chmod 755 /etc/init.d/bitcoind_launch.sh
RUN update-rc.d bitcoind_launch.sh defaults

RUN printf "\n/etc/init.d/bitcoind_launch.sh" >> /etc/bash.bashrc
