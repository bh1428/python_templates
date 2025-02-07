#
# makefile for Visual Studio Code (VSC) based Python projects
#

# Make targets:
#   init                  initial setup virtual env
#   upgrade_uv            upgrade uv
#   upgrade_requirements  upgrade requirements.txt files without installing
#   upgrade_all           upgrade uv, requirements.txt and installed packages
#   sync                  synchronize venv with requirements.txt
#   list                  show list of installed packages in the venv

# names (directories & files)
VENV_DIR := .venv
UV := uv

# executables for each supported OS
ifeq ($(OS),Windows_NT)
	SHELL := powershell.exe
	.SHELLFLAGS := -NoProfile -Command
	VENV := .\$(VENV_DIR)\Scripts
	VENV_ACTIVATE := $(VENV)\activate.bat
	VENV_PYTHON := $(VENV)\python.exe
else
	SHELL := bash
	VENV := ./$(VENV_DIR)/bin
	VENV_ACTIVATE := $(VENV)/activate
	VENV_PYTHON := $(VENV)/python
endif

all: sync

.NOTPARALLEL:

init: $(VENV_ACTIVATE)

$(VENV_ACTIVATE):
	$(UV) venv
    ifeq (,$(wildcard requirements.txt))
		$(UV) pip compile pyproject.toml -o requirements.txt
    endif
    ifeq (,$(wildcard dev-requirements.txt))
		$(UV) pip compile pyproject.toml --extra dev -o dev-requirements.txt
    endif
	$(UV) pip sync dev-requirements.txt --allow-empty-requirements

requirements.txt: $(VENV_ACTIVATE) pyproject.toml
	$(UV) pip compile pyproject.toml -o requirements.txt

dev-requirements.txt: $(VENV_ACTIVATE) pyproject.toml
	$(UV) pip compile pyproject.toml --extra dev -o dev-requirements.txt

.PHONY: upgrade_uv
upgrade_uv: $(VENV_ACTIVATE)
	$(UV) self update

.PHONY: upgrade_requirements
upgrade_requirements: $(VENV_ACTIVATE)
	$(UV) pip compile pyproject.toml --upgrade -o requirements.txt
	$(UV) pip compile pyproject.toml --upgrade --extra dev -o dev-requirements.txt

.PHONY: upgrade_all
upgrade_all: upgrade_uv upgrade_requirements sync

.PHONY: sync
sync: $(VENV_ACTIVATE) requirements.txt dev-requirements.txt
	$(UV) pip sync --allow-empty-requirements dev-requirements.txt

.PHONY: list
list: $(VENV_ACTIVATE)
	$(UV) pip list
