.PHONY: build vendor create-git-rev build-image create-container start stop run-wallet


build: vendor create-git-rev build-image create-container

vendor:
	git submodule update --init --recursive --force

create-git-rev:
	# create file for git monkeypatch (see ./scripts/git)
	(cd ./vendor/WalletWasabi && git rev-parse HEAD) > scripts/WalletWasabi-HEAD

build-image:
	docker build -f ./Dockerfile -t coinjoin-backend-image .

create-container:
	if [[ $$(docker ps -q -f name=coinjoin-backend-container) ]]; then docker kill coinjoin-backend-container; else true; fi
	if [[ $$(docker ps -q -a -f name=coinjoin-backend-container) ]]; then docker rm coinjoin-backend-container; else true; fi
	docker create -ti --name coinjoin-backend-container -p 8080:8080 -p 8081:8081 -p 19121:19121 -p 37127:37127 -p 37128:37128 coinjoin-backend-image

start:
	docker start coinjoin-backend-container

stop:
	docker stop coinjoin-backend-container

run-wallet:
	xhost + \
	&& docker run -it \
		--net host \
		-v "/tmp/.X11-unix/":"/tmp/.X11-unix/" \
		-e DISPLAY="${DISPLAY}" \
		coinjoin-backend-image "run-environment && wasabi-wallet"
