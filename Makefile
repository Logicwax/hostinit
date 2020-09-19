.PHONY: all


EXECUTABLES = ansible git 
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH)))

SHELL=/bin/bash

default: yubikey


yubikey:
	ansible-playbook --extra-vars user=$(USER) --connection=local playbook.yml
