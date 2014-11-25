BITCOIND_IMG=assafshomer/bitcoind-regtest
TOSHI_IMG=assafshomer/toshi-regtest
BITCOIND_DOCKERFILE_DIR=bitcoind-regtest
TOSHI_DOCKERFILE_DIR=../toshi

DOCKER_RUN=sudo docker run
DOCKER_ALICE=$(DOCKER_RUN) -t -p 20444:18444 -p 20332:18332 --name=alice --hostname=alice
DOCKER_BOB  =$(DOCKER_RUN) -t -p 19444:18444 -p 19332:18332 --name=bob --hostname=bob

DOCKER_DB_TOSHI		=$(DOCKER_RUN) -d --name toshi_db postgres
DOCKER_REDIS_TOSHI=$(DOCKER_RUN) -d --name toshi_redis redis
DOCKER_TOSHI 			=$(DOCKER_RUN) -t -p 5000:5000 --name toshi --link toshi_db:db --link toshi_redis:redis
DOCKER_BITCOIND   =$(DOCKER_RUN) -t -p 18444:18444 -p 18332:18332 --name=bitcoind --hostname=bitcoind --link toshi:toshi

RUN_DAEMON=bitcoind -regtest -rpcallowip=* -printtoconsole
RUN_SHELL=bash

build_bitcoind:
	sudo docker build -t=$(BITCOIND_IMG) $(BITCOIND_DOCKERFILE_DIR)

build_bd_example:
	sudo docker build -t=example $(BITCOIND_DOCKERFILE_DIR)

# this relies on a clone of the toshi repo along side this repo, with the corrected docker file that is currently only in my 'docker' branch
build_toshi: 
	sudo docker build -t=$(TOSHI_IMG) $(TOSHI_DOCKERFILE_DIR)
	
rm_bitcoind:
	-sudo docker rm -f bitcoind	

alice_rm:
	-sudo docker rm -f alice

bob_rm:
	-sudo docker rm -f bob

rm_toshi:
	-sudo docker rm -f toshi

rm_toshi_redis:
	-sudo docker rm -f toshi_redis

rm_toshi_db:
	-sudo docker rm -f toshi_db

alice_daemon: alice_rm
	$(DOCKER_ALICE) -d=true $(BITCOIND_IMG) $(RUN_DAEMON)

alice_shell: alice_rm
	$(DOCKER_ALICE) -i $(BITCOIND_IMG) $(RUN_SHELL)

bob_daemon: bob_rm
	$(DOCKER_BOB) -d=true $(BITCOIND_IMG) $(RUN_DAEMON)

bob_shell: bob_rm
	$(DOCKER_BOB) -i $(BITCOIND_IMG) $(RUN_SHELL)

bob_example: bob_rm
	$(DOCKER_BOB) -i $(BITCOIND_IMG) $(RUN_SHELL) 

bitcoind_shell: rm_bitcoind
	$(DOCKER_BITCOIND) -i $(BITCOIND_IMG) $(RUN_SHELL)

launch_toshi_db: 
	$(DOCKER_DB_TOSHI)
launch_toshi_redis: 
	$(DOCKER_REDIS_TOSHI)

toshi_shell: rm_toshi rm_toshi_redis rm_toshi_db launch_toshi_db launch_toshi_redis
	$(DOCKER_TOSHI) -i $(TOSHI_IMG)