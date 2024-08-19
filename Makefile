.PHONY: all main keys

# Replace with github username
GITHUB_ACCOUNT="logicwax"

EXECUTABLES = ansible git curl
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH)))

SHELL=/bin/bash

default: all

all: main keys

main:
	sudo ansible-playbook --extra-vars user=$(USER) --connection=local playbook.yml

keys:

	sudo ansible-playbook --extra-vars user=$(USER) --extra-vars github_account=$(GITHUB_ACCOUNT) --connection=local ssh_key.yml
