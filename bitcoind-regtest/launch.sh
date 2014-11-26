echo "this is launch sh"
export tmp=${TOSHI_PORT/tcp:\/\//}
export TOSHI_IP=${tmp/:*/}
bitcoind -regtest -daemon -printtoconsole
sleep "5"
echo "Adding Toshi node at IP:"$TOSHI_IP
bitcoind -regtest addnode $TOSHI_IP onetry
bitcoind -regtest setgenerate true 101