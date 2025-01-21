#
# makefile for Visual Studio Code (VSC) based Python projects
#

# Make targets (can be used when calling make):
#   init                  alias for initial setup of virtual env
#   upgrade_uv            upgrade pip and the uv package
#   upgrade_requirements  upgrade *requirements.txt files without installing
#   upgrade_venv          upgrade uv, requirements.txt and install packages
#   sync                  synchronize venv with *requirements.txt (default target)
#   list                  show list of installed packages in the venv

# names (directories & files)
VENV_DIR := .venv
UV := uv

# executables for each supported OS
ifeq ($(OS),Windows_NT)
	# Windows
	VENV := .\$(VENV_DIR)\Scripts
	VENV_ACTIVATE := $(VENV)\activate.bat
	VENV_PYTHON := $(VENV)\python.exe
else
	# Linux
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
		$(UV) pip compile -o requirements.txt pyproject.toml
    endif
    ifeq (,$(wildcard dev-requirements.txt))
		$(UV) pip compile --extra dev -o dev-requirements.txt pyproject.toml
    endif
	$(UV) pip sync --allow-empty-requirements dev-requirements.txt

requirements.txt: $(VENV_ACTIVATE) pyproject.toml
	$(UV) pip compile -o requirements.txt pyproject.toml

dev-requirements.txt: $(VENV_ACTIVATE) pyproject.toml
	$(UV) pip compile --extra dev -o dev-requirements.txt pyproject.toml

.PHONY: upgrade_uv
upgrade_uv: $(VENV_ACTIVATE)
	$(UV) self update

.PHONY: upgrade_requirements
upgrade_requirements: $(VENV_ACTIVATE)
	$(UV) pip compile --upgrade -o requirements.txt pyproject.toml
	$(UV) pip compile --upgrade --extra dev -o dev-requirements.txt pyproject.toml

.PHONY: sync
sync: $(VENV_ACTIVATE) requirements.txt dev-requirements.txt
	$(UV) pip sync --allow-empty-requirements dev-requirements.txt

.PHONY: upgrade_venv
upgrade_venv: upgrade_uv upgrade_requirements sync
    
.PHONY: list
list: $(VENV_ACTIVATE)
	$(UV) pip list
