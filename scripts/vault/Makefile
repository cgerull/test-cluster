# define the name of the virtual environment directory
REGISTRY := https://helm.releases.hashicorp.com

# default target, when make executed without arguments
help:           ## Show this help.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install:	## Install vault via helm
	helm install -n vault vault hashicorp/vault --set "server.dev.enabled=true"

helm-repo:	## Add hashicorp repository
	helm repo add hashicorp https://helm.releases.hashicorp.com
	helm repo update

clean:		## Clean all artefacts
	helm uninstall -n vault vault

all: helm-repo install    ## Run all commands



.PHONY: all helm-repo install clean
