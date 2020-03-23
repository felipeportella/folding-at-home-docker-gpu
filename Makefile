.ONESHELL: #run all the make session in the same shell, ensuring the change of folder will work
.DEFAULT_GOAL := help

APP_NAME=fahpetrobras

.PHONY: help
help:
	@echo ''
	@echo 'Usage: make [TARGET] [EXTRA_ARGUMENTS]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ''

docker-build: ## build the container
	docker build --tag "${APP_NAME}" -f ./build/Dockerfile ./build/

docker-clean: ## remove the docker image
	docker rmi "${APP_NAME}"

docker-run-cpu: ## run F@H docker image only with CPU support
	docker run  -e ENABLE_GPU=false --name="${APP_NAME}" "${APP_NAME}"

docker-run-gpu: ## run F@H docker image with GPU support
	docker run -e ENABLE_GPU=true --name="${APP_NAME}" "${APP_NAME}"

stop: ## stop and remove the running container
	docker stop "$(APP_NAME)"; docker rm "$(APP_NAME)"

### Singularity related commands

singularity-build: docker-build ## build the singularity image
	sudo singularity build ./build/$(APP_NAME).simg docker-daemon://$(APP_NAME):latest

singularity-clean: ## remove the singularity image (.simg)
	rm -f ./build/$(APP_NAME).simg

singularity-run-cpu: ## run F@H singularity image only with CPU support
	SINGULARITYENV_ENABLE_GPU=false singularity run ./build/$(APP_NAME).simg

singularity-run-gpu: ## run F@H singularity image with GPU support
	SINGULARITYENV_ENABLE_GPU=true singularity run ./build/$(APP_NAME).simg
