#! /bin/bash
echo "This is toshi launch"
echo "Setting up evn vars"
export DATABASE_URL=postgres://postgres:@$DB_PORT_5432_TCP_ADDR:$DB_PORT_5432_TCP_PORT
export REDIS_URL=redis://$REDIS_PORT_6379_TCP_ADDR:$REDIS_PORT_6379_TCP_PORT
export TOSHI_ENV=test
export TOSHI_NETWORK=regtest
export NODE_ACCEPT_INCOMING=true
export NODE_LISTEN_PORT=18444
echo "Migrating postgres db"
bundle exec rake db:migrate
echo "Starting toshi node, go visit localhost:5000"
foreman start -c web=1,block_worker=1,transaction_worker=1,peer_manager=1