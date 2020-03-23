.ONESHELL: #run all the make session in the same shell, ensuring the change of folder will work
.DEFAULT_GOAL := help

APP_NAME=fah-petrobras

.PHONY: help
help:
	@echo ''
	@echo 'Usage: make [TARGET] [EXTRA_ARGUMENTS]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ''

build: ## build the container
	docker build --tag "${APP_NAME}" -f ./build/Dockerfile ./build/

clean: ## remove rhe docker image
	docker rmi "${APP_NAME}"

run-cpu: ## run F@H docker image only with CPU support
	docker run  -e ENABLE_GPU=false --name="${APP_NAME}" "${APP_NAME}"

run-gpu: ## run F@H docker image with GPU support
	docker run -e ENABLE_GPU=true --name="${APP_NAME}" "${APP_NAME}"

stop: ## stop and remove the running container
	docker stop "$(APP_NAME)"; docker rm "$(APP_NAME)"

### Singularity related commands

dockerfile2singulatiry: ## convert the Dockerfile to Singularity
	cd build
	spython recipe Dockerfile Singularity
	echo "TODO: remove comments from Singularity file. They are unsupported when running multiline command!"
	sed -i "s/#.*//g" Singularity

singularity-build: ## build the singularity image
	cd build
	sudo singularity build $(APP_NAME).simg Singularity

singularity-run-cpu: ## run  F@H singularity image only with CPU support
	SINGULARITYENV_ENABLE_GPU=false singularity run build/$(APP_NAME).simg