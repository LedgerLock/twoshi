### BEGIN INIT INFO
# Provides:          scriptname
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by daemon.
### END INIT INFO
echo "this is bitcoind launch"
echo "exporting env vars"
export tmp=${TOSHI_PORT/tcp:\/\//}
export TOSHI_IP=${tmp/:*/}
echo "launching bitcoind daemon in regtest mode"
bitcoind -regtest -daemon -rpcallowip=* -printtoconsole
sleep "5"
echo "Adding Toshi node at IP:"$TOSHI_IP
bitcoind -regtest addnode $TOSHI_IP onetry
# echo "Mining 101 blocks"
# bitcoind -regtest setgenerate true 101