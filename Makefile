.PHONY: all

SSH_KEY_URL="https://github.com/logicwax.keys"

EXECUTABLES = ansible git curl
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH)))

SHELL=/bin/bash

default: yubikey

yubikey:
	sudo ansible-playbook --extra-vars user=$(USER) --extra-vars ssh_key_url=$(SSH_KEY_URL) --connection=local playbook.yml
