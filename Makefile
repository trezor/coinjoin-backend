.PHONY: build vendor build-image create-container start stop run-wallet

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

build: build-image create-container

vendor:
	git submodule update --init --recursive --force

build-image: Dockerfile
	docker build -t coinjoin-backend-image .

create-container:
	if [[ $$(docker ps -q -f name=coinjoin-backend-container) ]]; then docker kill coinjoin-backend-container; else true; fi
	if [[ $$(docker ps -q -a -f name=coinjoin-backend-container) ]]; then docker rm coinjoin-backend-container; else true; fi
	docker create -ti --name coinjoin-backend-container --net host --volume "${ROOT_DIR}/shared":"/mnt/shared" coinjoin-backend-image

start:
	docker start coinjoin-backend-container

stop:
	docker stop coinjoin-backend-container

run-wallet:
	docker run -it \
		--net host \
		-v "/tmp/.X11-unix/":"/tmp/.X11-unix/" \
		-e DISPLAY="${DISPLAY}" \
		coinjoin-backend-image "run-environment && wasabi-wallet"
