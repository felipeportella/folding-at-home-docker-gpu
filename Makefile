.ONESHELL: #run all the make session in the same shell, ensuring the change of folder will work
.DEFAULT_GOAL := help

APP_NAME=fahpetrobras
CONTAINER_ENGINE="docker"



.PHONY: help
help:
	@echo ''
	@echo 'Usage: make [TARGET] [EXTRA_ARGUMENTS]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ''

builddir:
	mkdir -p ./build

docker-build: builddir ## build the container
	$(CONTAINER_ENGINE) build --tag "${APP_NAME}" -f ./docker/Dockerfile ./docker

docker-tar-image: docker-build #create container image
	$(CONTAINER_ENGINE) save $(APP_NAME):latest -o ./build/$(APP_NAME).tar

docker-tar-image-clean:
	rm -f ./build/$(APP_NAME).tar

docker-clean: ## remove the docker image
	$(CONTAINER_ENGINE) rmi -f "${APP_NAME}"

docker-run-cpu: ## run F@H docker image only with CPU support
	$(CONTAINER_ENGINE) run  -e ENABLE_GPU=false --name="${APP_NAME}" "${APP_NAME}"

docker-run-gpu: ## run F@H docker image with GPU support
	$(CONTAINER_ENGINE) run --gpus all -e ENABLE_GPU=true --name="${APP_NAME}" "${APP_NAME}"

stop: ## stop and remove the running container
	$(CONTAINER_ENGINE) stop "$(APP_NAME)"; docker rm "$(APP_NAME)"

### Singularity related commands

singularity-build: docker-tar-image ## build the singularity image
	singularity build ./build/$(APP_NAME).sif docker-archive:./build/$(APP_NAME).tar

singularity-clean: ## remove the singularity image (.simg)
	rm -f ./build/$(APP_NAME).sif

singularity-run-cpu: ## run F@H singularity image only with CPU support
	SINGULARITYENV_ENABLE_GPU=false singularity run ./build/$(APP_NAME).sif

singularity-run-gpu: ## run F@H singularity image with GPU support
	SINGULARITYENV_ENABLE_GPU=true singularity run --nv ./build/$(APP_NAME).sif

clean: singularity-clean docker-clean docker-tar-image-clean
	rm -r ./build
