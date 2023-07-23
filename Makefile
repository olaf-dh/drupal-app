#!/usr/bin/make

# You are encouraged to simplify/modify/update this file with your suggestions.

# Read the environments variable used for this project setup.
# Your project commands can rely on different kinds of environment variables.
# These can be mostly not Application based, but infrastucture specific.
# Ex. `DATABASE_USER`, the database user of your environment.
# Import config
-include .env
-include docker/.env
-include docker/.env.local
export

# This is a clever trick to mimick --help like functionality.
# Execute `make`, `make help` or `make list` to list all command comments that are commented with a double # symbol.
# Ex. `app-init: ## Compiles and runs the application`.
.PHONY: help
.PHONY: list
no_targets__:
list help:
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS="([a-z|:]) ## "} {printf "\033[36m%-50s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help

# Determine the operating system. The default operating system is Unix.
# Use this variable to differentiate command executions based on the OS.
ifeq ($(OS),Windows_NT)
	OS=WIN
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		OS=LINUX
	endif
	ifeq ($(UNAME_S),Darwin)
		OS=MAC
	endif
endif

##
## Parameter
##

UID = $(id -u)
GID = $(id -g)

# Split all arguments for easier use in commands.
# Known issue: make exec <service> <command> -> command doesnt allow --option=value!
# @see https://stackoverflow.com/questions/2214575/passing-arguments-to-make-run#answer-45003119
ARGS = $(filter-out $@,$(MAKECMDGOALS))
ARG_1 = $(word 1, ${ARGS})
ARG_2 = $(word 2, ${ARGS})
ARG_3 = $(word 3, ${ARGS})
ARG_REST = $(wordlist 2, 100, ${ARGS})

# We use several docker-compose files to differiate between functionalities and OS.
# Custom logic can further be added here in case necessary.
COMPOSE_FILES = -f docker/docker-compose.yml
COMPOSE_FILES += -f docker/docker-compose.override.yml

# Add Xdebug if `XDEBUG=TRUE` is set in the `.env.local`.
ifeq ($(XDEBUG),TRUE)
	COMPOSE_FILES += -f docker/docker-compose-xdebug.yml
endif

# Add NFS support if `NFS=TRUE` is set in the `.env.local`.
ifeq ($(NFS),TRUE)
	COMPOSE_FILES += -f docker/docker-compose-nfs.yml
else
	COMPOSE_FILES += -f docker/docker-compose-volumes.yml
endif

# Shortcut for docker-compose.
DC = docker-compose --env-file .env ${COMPOSE_FILES}

##
## DOCKER COMPOSE TASKS
##

dc: ## Run a docker compose option: `make dc [options]`.
	${DC} ${ARGS}

up: ## Start all services use: `make up [<service-name>]`.
	${DC} up -d --force-recreate --remove-orphans ${ARGS}

down: ## Remove all services use: `make down`.
	${DC} down --remove-orphans -v

start: ## Start all services: `make start [<service-name>]`.
	${DC} start ${ARGS}

restart: ## Restart all services: `make restart [<service-name>]`.
	${DC} restart ${ARGS}

stop: ## Stop all services use: `make stop [<service-name>]`.
	${DC} stop ${ARGS}

rm: ## Remove services use `make rm [<service-name>]`.
	${DC} rm -f -s -v ${ARGS}

pull: ## Pull all service-images use: `make pull [<service-name>]`.
	${DC} pull ${ARGS}

build: ## Build all services use: `make pull [<service-name>]`.
	make pull ${ARGS}
	${DC} build ${ARGS}

##
## Docker Stats
##

image-size: ## Show the size of all service-images.
	${DC} images

ps: ## Show information for all running services use: `make ps [<service-name>]`.
	${DC} ps ${ARGS}

stats: ## Show service statistics.
	docker stats

top: ## Show service processe use `make top [<service-name>]`.
	${DC} top ${ARGS}

##
## DOCKER CLEAN UP
##

system-prune: ## Run a docker system prune.
	docker system prune

reset-project: ## !!WARNING!! Remove everything, clear docker and re-init the project.
	rm git-clean clear-container clear-images clear-volumes clear-networks init

git-clean-dry: ## !!WARNING!! Show which files that are untracked would be deleted.
	git clean -dfXn

git-clean: ## !!WARNING!! Clear all untracked files (gitignored).
	git clean -dfX

clear-container: ## !!WARNING!! remove all containers.
	docker rm -f $$(docker ps -a -q)

clear-images: ## !!WARNING!! Remove all images.
	docker rmi -f $$(docker images -a -q)

clear-images-soft: ## !!WARNING!! Force delete all images from the last 24 hours.
	docker images | grep -E "(minutes|hours) ago" | awk '{print $3}' | xargs docker image rm -f

clear-volumes: ## !!WARNING!!  Remove all volumes.
	docker volume rm $$(docker volume ls -q)

clear-networks: # !!WARNING!! Remove all networks.
	docker network rm $$(docker network ls | tail -n+2 | awk '{if($2 !~ /bridge|none|host/){ print $1 }}')

##
## Utility commands
##

logs: ## Show service logs use: `make logs <service-name>`.
	${DC} logs --tail="all" -f ${ARGS}

exec: ## Run a command inside a container use: `make exec <service-name> "<command>"` - f.e. make exec app "ls -lah".
	docker exec ${COMPOSE_PROJECT_NAME}_${ARG_1} /bin/sh -c "${ARG_REST}"

inspect: ## Get service configuration use: `make inspect [<service-name>]`.
	docker inspect ${COMPOSE_FILES} ps -q ${ARGS}

bash: ## Open a shell inside a running container use: `make bash <service-name>`.
	${DC} exec ${ARG_1} bash -l

##
## Workaround for Makefile
## @see https://stackoverflow.com/a/6273809/1826109
##
%:
	@:

##
## Include more commands
##

include Makefile.tools.mk
