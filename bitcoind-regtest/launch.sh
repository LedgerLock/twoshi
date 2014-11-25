echo "this is launch sh"
export tmp=${TOSHI_PORT/tcp:\/\//}
export TOSHI_IP=${tmp/:*/}
bitcoind -regtest -daemon -printtoconsole
sleep "5"
echo "Adding Toshi node at IP:"$TOSHI_IP
bitcoind -regtest addnode $TOSHI_IP onetry
bitcoind -regtest setgenerate true 101
pause
# root@bitcoind:/# T=${TOSHI_PORT/tcp:\/\//}
# root@bitcoind:/# echo $T
# 172.17.0.67:5000
# root@bitcoind:/# S=${T/:*/}
# root@bitcoind:/# echo $S
# 172.17.0.67
# root@bitcoind:/# echo $S
