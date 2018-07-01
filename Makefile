# Task runner

.PHONY: help build

.DEFAULT_GOAL := help

SHELL := /bin/bash

# App version is the tag attached to this commit, if there is one. If there is not, APP_VERSION is empty. If there are
# multiple, they are concatenated using the " " (space) character.
#
# See http://stackoverflow.com/questions/4545370/how-to-list-all-tags-pointing-to-a-specific-commit-in-git
# See http://stackoverflow.com/questions/1404796/how-to-get-the-latest-tag-name-in-current-branch-in-git
APP_VERSION  := $(shell git show-ref --dereference --tags | grep ^`git rev-parse HEAD` | sed -e 's,.* refs/tags/,,' -e 's/\^{}//')
GIT_HASH     := $(shell git rev-parse --short HEAD)

ANSI_TITLE        := '\e[1;32m'
ANSI_CMD          := '\e[0;32m'
ANSI_TITLE        := '\e[0;33m'
ANSI_SUBTITLE     := '\e[0;37m'
ANSI_WARNING      := '\e[1;31m'
ANSI_OFF          := '\e[0m'

PATH_DOCS                := $(shell pwd)/docs
PATH_BUILD_CONFIGURATION := $(shell pwd)/build

TIMESTAMP := $(shell date "+%s")

help: ## Show this menu
	@echo -e $(ANSI_TITLE)snipe-it$(ANSI_OFF)$(ANSI_SUBTITLE)" - Open source asset management"$(ANSI_OFF)
	@echo -e "\nUsage: $ make \$${COMMAND} \n"
	@echo -e "Variables use the \$${VARIABLE} syntax, and are supplied as environment variables before the command. For example, \n"
	@echo -e "  \$$ VARIABLE="foo" make help\n"
	@echo -e $(ANSI_TITLE)Commands:$(ANSI_OFF)
	@grep -E '^[a-zA-Z_-%]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "    \033[32m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: container.build
container.build: ## Builds the container, tagging it at the version defined in APP_VERSION
	[[ ! -z "$(APP_VERSION)" ]] && \
	    export TAG="$(APP_VERSION)" || \
	    export TAG="$(GIT_HASH)" && \
	docker build \
	    --file ./Dockerfile \
	    --tag quay.io/littlemanco/snipe-it:latest \
	    --tag quay.io/littlemanco/snipe-it:$${TAG} \
	    --squash \
	    $$(pwd)

.PHONY: container.test
container.test: ## Runs any tests against the container that may be appropriate
	# Verify the container works
	curl https://localhost \
	    --head \
	    --insecure

.PHONY: container.push
container.push: ## Pushes the container to a remote host
	[[ ! -z "$(APP_VERSION)" ]] && \
            export TAG="$(APP_VERSION)" || \
            export TAG="$(GIT_HASH)" && \
	docker push quay.io/littlemanco/snipe-it:${TAG}
	docker push quay.io/littlemanco/snipe-it:latest

.PHONY: dockercompose.start
dockercompose.start: ## Brings up the docker compose environment
	docker-compose up -d --force-recreate

.PHONY: dockercompose.stop
dockercompose.stop: ## Stops (and cleans) the docker-compose environment
	docker-compose rm \
	    --stop \
	    --force

.PHONY: dockercompose.snipeit.shell
dockercompose.snipeit.shell: ## Gives a shell in the snipe container
	docker-compose exec snipe bin/bash

dockercompose.mysql.shell: ## Gives a shell inside the MYSQL container
	docker-compose exec mysql mysql -u root -pthisisthemysqlrootpassword
