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
bitcoind -regtest -server -daemon -rpcallowip=0/0 -printtoconsole
# increase the number of seconds to more than 5 if bitcoind didn't manage to connect to toshi
sleep "5"
echo "Adding Toshi node at IP:"$TOSHI_IP
bitcoin-cli -regtest addnode $TOSHI_IP onetry
export BNUM="$(bitcoin-cli -regtest getblockcount)"
if [ $BNUM -eq 0 ] 
	then
		echo "Mining 101 blocks"
		bitcoin-cli -regtest setgenerate true 101
	else
		echo "Not mining any more blocks, " $BNUM " blocks already found"
fi
# rm /etc/init.d/bitcoind_launch.sh
