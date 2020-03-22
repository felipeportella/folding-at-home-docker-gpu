.PHONY: help
help:
	@echo ''
	@echo 'Usage: make [TARGET] [EXTRA_ARGUMENTS]'
	@echo 'Targets:'
	@echo '  build          build the docker image '
	@echo '  run-cpu        run F@H docker image only with CPU support '
	@echo '  run-gpu        run F@H docker image with GPU support '
	@echo ''
	@echo 'Extra arguments:'
	@echo '  user=:         the F@H user, the default is Anonymous'


build:
	docker build --tag "foldingathomedockergpu:latest" -f ./Docker/Dockerfile ./Docker/

run-cpu:
	docker run  -e ENABLE_GPU=false "foldingathomedockergpu:latest"

run-gpu: ## test locally
	docker run -e ENABLE_GPU=true "foldingathomedockergpu:latest"

clean:
	docker rmi "foldingathomedockergpu:latest"