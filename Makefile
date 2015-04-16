# DOCKER IMAGE NAMING
# ==================
# name of the docker bitcoind IMAGE
BITCOIND_IMG=assafshomer/bitcoind-regtest
# name of the docker bitcoind - v10 IMAGE
BITCOIND_V10_IMG=assafshomer/bitcoin-v10-regtest
# name of the docker toshi IMAGE
TOSHI_IMG=assafshomer/toshi-regtest

# DEFAULT ARGUMENTS
# ================
DEFAULT_VERSION=10
VERSION ?= $(DEFAULT_VERSION)

# DOCKER CONTAINER NAMING
# ======================
# name of the bitcoind CONTAINER
BITCOIND_CONTAINER_NAME=bitcoind
# name of the toshi CONTAINER
TOSHI_CONTAINER_NAME=toshi

# DOCKERFILE DIRECTORY LOCATIONS
# ==============================
# DIRECTORY of bitcoind dockerfile
BITCOIND_DOCKERFILE_DIR=bitcoind
# DIRECTORY of bitcoind - v10 dockerfile
BITCOIND_V10_DOCKERFILE_DIR=bitcoin10
# DIRECTORY of toshi dockerfile
TOSHI_DOCKERFILE_DIR=toshi

# ALIASES
# =======
DOCKER_RUN=docker run
RUN_DAEMON=bitcoind -regtest -rpcallowip=* -printtoconsole
RUN_SHELL=bash

# DOCKER IMAGE SETUP
# ==================
DOCKER_DB_TOSHI		=$(DOCKER_RUN) -d --name toshi_db postgres
DOCKER_REDIS_TOSHI=$(DOCKER_RUN) -d --name toshi_redis redis
DOCKER_TOSHI 			=$(DOCKER_RUN) -t -p 5000:5000 --name $(TOSHI_CONTAINER_NAME) --hostname $(TOSHI_CONTAINER_NAME) --link toshi_db:db --link toshi_redis:redis
DOCKER_BITCOIND   =$(DOCKER_RUN) -t -p 18444:18444 -p 18332:18332 --name=$(BITCOIND_CONTAINER_NAME) --hostname=$(BITCOIND_CONTAINER_NAME) --link toshi:toshi -e DELAY=$(DELAY)

customize_toshi_dockerfile: 
	cp custom_toshi_dockerfile toshi/Dockerfile
	cp scripts/toshi_launch.sh toshi/

build_bitcoind:
ifeq ($(VERSION),10)
	docker build -t=$(BITCOIND_V10_IMG) $(BITCOIND_V10_DOCKERFILE_DIR)
else
	docker build -t=$(BITCOIND_IMG) $(BITCOIND_DOCKERFILE_DIR)
endif	

build_toshi: customize_toshi_dockerfile
	docker build -t=$(TOSHI_IMG) $(TOSHI_DOCKERFILE_DIR)
	
build_regtest: build_toshi build_bitcoind

rm_bitcoind:
	-docker rm -f $(BITCOIND_CONTAINER_NAME)	

rm_toshi:
	-docker rm -f $(TOSHI_CONTAINER_NAME)

rm_toshi_redis:
	-docker rm -f toshi_redis

launch_toshi_redis: 
	$(DOCKER_REDIS_TOSHI)

rm_toshi_db:
	-docker rm -f toshi_db

launch_toshi_db: 
	$(DOCKER_DB_TOSHI)

toshi_shell: rm_toshi rm_toshi_redis rm_toshi_db launch_toshi_db launch_toshi_redis
	$(DOCKER_TOSHI) -i $(TOSHI_IMG)

toshi_daemon: rm_toshi rm_toshi_redis rm_toshi_db launch_toshi_db launch_toshi_redis
	$(DOCKER_TOSHI) -d=true $(TOSHI_IMG) /bin/bash toshi_launch.sh
	sleep "5"
	docker start toshi

bitcoind_shell: rm_bitcoind
ifeq ($(VERSION),10)
	$(DOCKER_BITCOIND) -i $(BITCOIND_V10_IMG) $(RUN_SHELL)
else
	$(DOCKER_BITCOIND) -i $(BITCOIND_IMG) $(RUN_SHELL)
endif	

bitcoind_daemon: rm_bitcoind
ifeq ($(VERSION),10)
	$(DOCKER_BITCOIND) -d $(BITCOIND_V10_IMG) $(RUN_SHELL)
else
	$(DOCKER_BITCOIND) -d $(BITCOIND_IMG) $(RUN_SHELL)
endif	
	sleep "5"
	docker start bitcoind

regtest_daemon: build_regtest toshi_daemon bitcoind_daemon

twoshi: build_regtest toshi_daemon bitcoind_daemon

cleanup:
	./scripts/cleardocker.sh

twoshi_clean: cleanup twoshi

run:
ifeq ($(CLEAN),TRUE)
	make twoshi_clean
else
	make twoshi
endif		
