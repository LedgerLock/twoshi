# name of the docker bitcoind image
BITCOIND_IMG=assafshomer/bitcoind-regtest
# name of the docker toshi image
TOSHI_IMG=assafshomer/toshi-regtest
# directory of bitcoind dockerfile
BITCOIND_DOCKERFILE_DIR=bitcoind
# directory of toshi dockerfile
TOSHI_DOCKERFILE_DIR=toshi

# useful aliases
DOCKER_RUN=sudo docker run
RUN_DAEMON=bitcoind -regtest -rpcallowip=* -printtoconsole
RUN_SHELL=bash

# setup docker images
DOCKER_DB_TOSHI		=$(DOCKER_RUN) -d --name toshi_db postgres
DOCKER_REDIS_TOSHI=$(DOCKER_RUN) -d --name toshi_redis redis
DOCKER_TOSHI 			=$(DOCKER_RUN) -t -p 5000:5000 --name toshi --hostname toshi --link toshi_db:db --link toshi_redis:redis
DOCKER_BITCOIND   =$(DOCKER_RUN) -t -p 18444:18444 -p 18332:18332 --name=bitcoind --hostname=bitcoind --link toshi:toshi

customize_toshi_dockerfile: 
	cp custom_toshi_dockerfile toshi/Dockerfile
	cp scripts/toshi_launch.sh toshi/

build_bitcoind:
	sudo docker build -t=$(BITCOIND_IMG) $(BITCOIND_DOCKERFILE_DIR)

build_toshi: customize_toshi_dockerfile
	sudo docker build -t=$(TOSHI_IMG) $(TOSHI_DOCKERFILE_DIR)
	
build_regtest: build_toshi build_bitcoind

rm_bitcoind:
	-sudo docker rm -f bitcoind	

rm_toshi:
	-sudo docker rm -f toshi

rm_toshi_redis:
	-sudo docker rm -f toshi_redis

launch_toshi_redis: 
	$(DOCKER_REDIS_TOSHI)

rm_toshi_db:
	-sudo docker rm -f toshi_db

launch_toshi_db: 
	$(DOCKER_DB_TOSHI)

toshi_shell: rm_toshi rm_toshi_redis rm_toshi_db launch_toshi_db launch_toshi_redis
	$(DOCKER_TOSHI) -i $(TOSHI_IMG)

toshi_daemon: rm_toshi rm_toshi_redis rm_toshi_db launch_toshi_db launch_toshi_redis
	$(DOCKER_TOSHI) -d=true $(TOSHI_IMG) /bin/bash toshi_launch.sh
	sleep "5"
	sudo docker start toshi

bitcoind_shell: rm_bitcoind build_bitcoind
	$(DOCKER_BITCOIND) -i $(BITCOIND_IMG) $(RUN_SHELL)

bitcoind_daemon: rm_bitcoind
	$(DOCKER_BITCOIND) -d=true $(BITCOIND_IMG) /bin/bash bitcoind_launch.sh
	sleep "5"
	sudo docker start bitcoind
	sudo docker attach bitcoind

regtest_daemon: build_regtest toshi_daemon bitcoind_daemon

twoshi: build_regtest toshi_daemon bitcoind_shell

cleanup:
	sudo ./scripts/cleardocker.sh

twoshi_clean: cleanup twoshi


# DOCKER_ALICE=$(DOCKER_RUN) -t -p 20444:18444 -p 20332:18332 --name=alice --hostname=alice
# DOCKER_BOB  =$(DOCKER_RUN) -t -p 19444:18444 -p 19332:18332 --name=bob --hostname=bob

# rm_alice:
# 	-sudo docker rm -f alice

# rm_bob:
# 	-sudo docker rm -f bob

# alice_daemon: rm_alice
# 	$(DOCKER_ALICE) -d=true $(BITCOIND_IMG) $(RUN_DAEMON)

# alice_shell: rm_alice
# 	$(DOCKER_ALICE) -i $(BITCOIND_IMG) $(RUN_SHELL)

# bob_daemon: rm_bob
# 	$(DOCKER_BOB) -d=true $(BITCOIND_IMG) $(RUN_DAEMON)

# bob_shell: rm_bob
# 	$(DOCKER_BOB) -i $(BITCOIND_IMG) $(RUN_SHELL)