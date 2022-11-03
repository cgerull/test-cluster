# define the name of the virtual environment directory
REGISTRY := https://helm.releases.hashicorp.com

# default target, when make executed without arguments
help:           ## Show this help.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install-vault: helm-repo	## Install vault via helm
	helm install -n vault vault hashicorp/vault --set "server.dev.enabled=true"

cluster-keys.json: 	## Initialize vault
	kubectl exec -n vault vault-0 -- vault operator init \
    		-key-shares=1 \
    		-key-threshold=1 \
    		-format=json > cluster-keys.json; 

unseal-vault: cluster-keys.json 	## Unseal vault with stored key
	kubectl exec -n vault vault-0 -- vault operator unseal $(shell jq -r ".unseal_keys_b64[]" cluster-keys.json)

helm-repo:	## Add hashicorp repository
	helm repo add hashicorp https://helm.releases.hashicorp.com
	helm repo update

clean:		## Clean all artefacts
	helm uninstall -n vault vault

all: helm-repo install-vault unseal-vault    ## Run all commands



.PHONY: all helm-repo install clean
