DOCKER_RUN=sudo docker run
DOCKER_ALICE=$(DOCKER_RUN) -t -p 18444:18444 -p 18332:18332 --name=alice --hostname=alice
DOCKER_BOB  =$(DOCKER_RUN) -t -p 19444:18444 -p 19332:18332 --name=bob --hostname=bob

BITCOIND_IMG=assafshomer/regtest
TOSHI_IMG=assafshomer/toshi

DOCKER_DB_TOSHI		=$(DOCKER_RUN) -d --name toshi_db postgres
DOCKER_REDIS_TOSHI=$(DOCKER_RUN) -d --name toshi_redis redis
DOCKER_TOSHI 			=$(DOCKER_RUN) -t -p 5000:5000 --name toshi --link toshi_db:db --link toshi_redis:redis

RUN_DAEMON=bitcoind -regtest -rpcallowip=* -printtoconsole
RUN_SHELL=bash

build:
	sudo docker build -t=assafshomer/regtest bitcoin-regtest
	
alice_rm:
	-sudo docker rm -f alice

bob_rm:
	-sudo docker rm -f bob

toshi_rm:
	-sudo docker rm -f toshi

toshi_redis_rm:
	-sudo docker rm -f toshi_redis

toshi_db_rm:
	-sudo docker rm -f toshi_db

alice_daemon: alice_rm
	$(DOCKER_ALICE) -d=true $(BITCOIND_IMG) $(RUN_DAEMON)

alice_shell: alice_rm
	$(DOCKER_ALICE) -i $(BITCOIND_IMG) $(RUN_SHELL)

bob_daemon: bob_rm
	$(DOCKER_BOB) -d=true $(BITCOIND_IMG) $(RUN_DAEMON)

bob_shell: bob_rm
	$(DOCKER_BOB) -i $(BITCOIND_IMG) $(RUN_SHELL)

launch_toshi_db: 
	$(DOCKER_DB_TOSHI)
launch_toshi_redis: 
	$(DOCKER_REDIS_TOSHI)

toshi_shell: toshi_rm toshi_redis_rm toshi_db_rm launch_toshi_db launch_toshi_redis
	$(DOCKER_TOSHI) -i $(TOSHI_IMG) $(RUN_SHELL)
