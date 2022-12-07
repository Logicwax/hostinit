.PHONY: all main sshkeys

# Replace with URL to your own pgp public key file
SSH_KEY_URL="https://github.com/logicwax.keys"

EXECUTABLES = ansible git curl
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH)))

SHELL=/bin/bash

default: all

all: main sshkeys

main:
	sudo ansible-playbook --extra-vars user=$(USER) --connection=local playbook.yml

sshkeys: main

	sudo ansible-playbook --extra-vars user=$(USER) --extra-vars ssh_key_url=$(SSH_KEY_URL) --connection=local ssh_key.yml
