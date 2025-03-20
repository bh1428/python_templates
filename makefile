#
# makefile for python_templates
#

# Make targets:
#   init                  initial setup virtual env
#   upgrade_uv            upgrade uv
#   upgrade_requirements  upgrade requirements.txt files without installing
#   upgrade_all           upgrade uv, requirements.txt and installed packages
#   sync                  synchronize venv with requirements.txt
#   list                  show list of installed packages in the venv
#   build                 build templates

# names (directories & files)
VENV_DIR := .venv
UV := uv
VERSION_FILE := VERSION

# executables for each supported OS
ifeq ($(OS),Windows_NT)
	SHELL := powershell.exe
	.SHELLFLAGS := -NoProfile -Command
	OUT_NEW := | Out-File -Encoding default
	VENV := .\$(VENV_DIR)\Scripts
	VENV_ACTIVATE := $(VENV)\activate.bat
	VENV_PYTHON := $(VENV)\python.exe
else
	SHELL := bash
	OUT_NEW := >
	VENV := ./$(VENV_DIR)/bin
	VENV_ACTIVATE := $(VENV)/activate
	VENV_PYTHON := $(VENV)/python
endif

all: build

.NOTPARALLEL:

init: $(VENV_ACTIVATE)

$(VENV_ACTIVATE):
	$(UV) venv
    ifeq (,$(wildcard requirements.txt))
		$(UV) pip compile pyproject.toml -o requirements.txt
    endif
	$(UV) pip sync requirements.txt

requirements.txt: $(VENV_ACTIVATE) pyproject.toml
	$(UV) pip compile pyproject.toml -o requirements.txt

.PHONY: upgrade_all
upgrade_all: upgrade_uv upgrade_requirements sync

.PHONY: upgrade_uv
upgrade_uv: $(VENV_ACTIVATE)
	$(UV) self update

.PHONY: upgrade_requirements
upgrade_requirements: $(VENV_ACTIVATE)
	$(UV) pip compile pyproject.toml --upgrade -o requirements.txt

.PHONY: sync
sync: $(VENV_ACTIVATE) requirements.txt
	$(UV) pip sync requirements.txt

.PHONY: list
list: $(VENV_ACTIVATE)
	$(UV) pip list

.PHONY: build
build: $(VENV_ACTIVATE) dot_gitignore.jinja2 update_gitignore.py
	$(VENV_PYTHON) update_gitignore.py
	$(VENV_PYTHON) -c "import datetime as dt; dq=chr(34); d=dt.date.today(); print(f'VERSION={dq}{d.year:d}.{d.month:d}.{d.day:d}{dq}')" $(OUT_NEW) $(VERSION_FILE)
