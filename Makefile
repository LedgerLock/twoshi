BITCOIND_IMG=assafshomer/bitcoind-regtest
TOSHI_IMG=assafshomer/toshi-regtest
BITCOIND_DOCKERFILE_DIR=bitcoind-regtest
TOSHI_DOCKERFILE_DIR=toshi

DOCKER_RUN=sudo docker run
DOCKER_ALICE=$(DOCKER_RUN) -t -p 20444:18444 -p 20332:18332 --name=alice --hostname=alice
DOCKER_BOB  =$(DOCKER_RUN) -t -p 19444:18444 -p 19332:18332 --name=bob --hostname=bob

DOCKER_DB_TOSHI		=$(DOCKER_RUN) -d --name toshi_db postgres
DOCKER_REDIS_TOSHI=$(DOCKER_RUN) -d --name toshi_redis redis
DOCKER_TOSHI 			=$(DOCKER_RUN) -t -p 5000:5000 --name toshi --hostname toshi --link toshi_db:db --link toshi_redis:redis
DOCKER_BITCOIND   =$(DOCKER_RUN) -t -p 18444:18444 -p 18332:18332 --name=bitcoind --hostname=bitcoind --link toshi:toshi

RUN_DAEMON=bitcoind -regtest -rpcallowip=* -printtoconsole
RUN_SHELL=bash


customize_toshi_dockerfile: 
	cp custom_toshi_dockerfile toshi/Dockerfile
	cp toshi_launch.sh toshi/

build_bitcoind:
	sudo docker build -t=$(BITCOIND_IMG) $(BITCOIND_DOCKERFILE_DIR)

build_toshi: customize_toshi_dockerfile
	sudo docker build -t=$(TOSHI_IMG) $(TOSHI_DOCKERFILE_DIR)
	
build_regtest: build_toshi build_bitcoind

rm_bitcoind:
	-sudo docker rm -f bitcoind	

rm_alice:
	-sudo docker rm -f alice

rm_bob:
	-sudo docker rm -f bob

rm_toshi:
	-sudo docker rm -f toshi

rm_toshi_redis:
	-sudo docker rm -f toshi_redis

rm_toshi_db:
	-sudo docker rm -f toshi_db

alice_daemon: rm_alice
	$(DOCKER_ALICE) -d=true $(BITCOIND_IMG) $(RUN_DAEMON)

alice_shell: rm_alice
	$(DOCKER_ALICE) -i $(BITCOIND_IMG) $(RUN_SHELL)

bob_daemon: rm_bob
	$(DOCKER_BOB) -d=true $(BITCOIND_IMG) $(RUN_DAEMON)

bob_shell: rm_bob
	$(DOCKER_BOB) -i $(BITCOIND_IMG) $(RUN_SHELL)

bitcoind_shell: rm_bitcoind
	$(DOCKER_BITCOIND) -i $(BITCOIND_IMG) $(RUN_SHELL)

launch_toshi_db: 
	$(DOCKER_DB_TOSHI)

launch_toshi_redis: 
	$(DOCKER_REDIS_TOSHI)

toshi_shell: rm_toshi rm_toshi_redis rm_toshi_db launch_toshi_db launch_toshi_redis
	$(DOCKER_TOSHI) -i $(TOSHI_IMG)

bitcoind: rm_bitcoind
	$(DOCKER_BITCOIND) -i $(BITCOIND_IMG)

toshi_daemon: rm_toshi rm_toshi_redis rm_toshi_db launch_toshi_db launch_toshi_redis
	$(DOCKER_TOSHI) -d=true $(TOSHI_IMG) /bin/bash toshi_launch.sh
	sleep "5"
	sudo docker start toshi

bitcoind_daemon: rm_bitcoind
	$(DOCKER_BITCOIND) -d=true $(BITCOIND_IMG) /bin/bash bitcoind_launch.sh
	sleep "5"
	sudo docker start bitcoind