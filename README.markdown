# Local bitcoin network with bitcoind docker images 
Based on this [blog post](http://geraldkaszuba.com/creating-your-own-experimental-bitcoin-network/)

* `alice_shell`, or `bob_shell` to get a bash console of the local nodes
* `rt -daemon -printtoconsole` to get each node running
* you can skip this by running `alice_daemon` or `bob_daemon` from the start
* `ip addr` to find the ip address of each node, it should look something like this
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
6: eth0: <BROADCAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 02:42:ac:11:00:03 brd ff:ff:ff:ff:ff:ff
    inet``` **172.17.0.3/16** ```scope global eth0
    inet6 fe80::42:acff:fe11:3/64 scope link 
       valid_lft forever preferred_lft forever
```