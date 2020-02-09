# Makefile are used to abstract all used tools at this project.

# Defaults variables
resource-dir-terraform = /polkadot-automator/terraform/$(resource)
resource-dir-ansible = /polkadot-automator/ansible

# All the defaults configurations to use inside your container.
base-docker-run = docker run \
	--env GCP_TOKEN \
	--rm \
	--volume $(shell pwd):/polkadot-automator \
	--volume $(HOME)/.ssh/:/home/polkadot/.ssh/:ro \

# Verification if some variable are not set
guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Variable '$*' not set"; \
		exit 1; \
	fi

terraform-docker-run = $(base-docker-run) \
	--interactive \
	--tty \
	--workdir $(resource-dir-terraform) \
	polkadot-automator

ansible-docker-run = $(base-docker-run) \
	--interactive \
	--tty \
	--workdir $(resource-dir-ansible)\
	polkadot-automator

.PHONY: bash
bash: ##@ run the project container on interactive mode for debug
	@$(base-docker-run) -it polkadot-automator /bin/bash

# Terraform commands

.PHONY: terraform-apply
terraform-apply: guard-resource ##@terraform Build polkadot environment
	@echo "Building terrform environment..."
	@$(terraform-docker-run) \
	terraform apply \
	-auto-approve=true \
	.

.PHONY: terraform-destroy
terraform-destroy: guard-resource ##@terraform Destroy polkadot environment
	@echo "Destroying terrform environment..."
	@$(terraform-docker-run) \
	terraform destroy \
	-auto-approve=true \
	-parallelism=100 \
	.

.PHONY: terraform-init
terraform-init: guard-resource ##@terraform Initialize polkadot environment
	@echo "Starting terrform environment..."
	@$(terraform-docker-run) \
	terraform init \
	.

.PHONY: terraform-fmt
terraform-fmt: ##@terraform Rewrite configuration files to a canonical format and style
	@$(base-docker-run) \
	--workdir /polkadot-automator/terraform/ \
	polkadot-automator \
	terraform fmt

.PHONY: build-all
build-all: ##@deploy all resources on GCP at once.
	make terraform-init resource=main && \
	make terraform-apply resource=main && \
	make terraform-init resource=compute && \
	make terraform-apply resource=compute

.PHONY: destroy-all
destroy-all: ##@destroy all the resources GCP at once.
	make terraform-destroy resource=compute && \
	make terraform-destroy resource=main

# Ansbile commands

.PHONY: ansible-playbook
ansible-playbook: guard-playbook
	@echo "Provisioning environment with ansible..."
	 $(ansible-docker-run) \
			ansible-playbook $(playbook).yml \
				-i inventory.gcp.yml \
				-u polkadot \
				-vvv

# Default setup

.PHONY: setup
setup: ##@setup Build and copy the tools needed to run this project
	@echo "Copying git hooks"
	cp -v githooks/pre-commit .git/hooks/pre-commit && \
	chmod +x .git/hooks/pre-commit
	@echo "Building docker image"
	docker build . -t polkadot-automator
	@echo "Done!"
