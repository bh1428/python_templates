#
# makefile for python_templates
#

# Make targets (can be used when calling make):
#   init                  alias for initial setup of virtual env
#   upgrade_uv            upgrade pip and the uv package
#   upgrade_requirements  upgrade *requirements.txt files without installing
#   upgrade_venv          upgrade uv, requirements.txt and install packages
#   sync                  synchronize venv with *requirements.txt
#   list                  show list of installed packages in the venv
#   clean                 remove virtual environment
#   build                 build templates

# names (directories & files)
VENV_DIR := .venv
VENV_CLEAN_DIRS := __pycache__
VERSION_FILE := VERSION

# executables for each supported OS
ifeq ($(OS),Windows_NT)
	# Windows
	CMD := "C:\Windows\System32\cmd.exe"
	PYTHON := "C:\Program Files\Python313\python.exe"
	VENV := .\$(VENV_DIR)\Scripts
	VENV_ACTIVATE := $(VENV)\activate.bat
	VENV_PYTHON := $(VENV)\python.exe
	PIP := $(VENV)\pip.exe
	UV := $(VENV)\uv.exe
else
	# Linux
	PYTHON := "/usr/bin/python3.13"
	VENV := ./$(VENV_DIR)/bin
	VENV_ACTIVATE := $(VENV)/activate
	VENV_PYTHON := $(VENV)/python
	PIP := $(VENV)/pip
	UV := $(VENV)/uv
endif


all: build

.NOTPARALLEL:

init: $(VENV_ACTIVATE)

$(VENV_ACTIVATE):
	$(PYTHON) -m venv $(VENV_DIR)
	$(VENV_PYTHON) -m pip install pip --upgrade
	$(VENV_PYTHON) -m pip install wheel
	$(VENV_PYTHON) -m pip install uv
    ifeq (,$(wildcard requirements.txt))
		$(UV) pip compile -o requirements.txt pyproject.toml
    endif
	$(UV) pip sync requirements.txt

requirements.txt: $(VENV_ACTIVATE) pyproject.toml
	$(UV) pip compile -o requirements.txt pyproject.toml

.PHONY: upgrade_uv
upgrade_uv: $(VENV_ACTIVATE)
	$(VENV_PYTHON) -m pip install pip --upgrade
	$(VENV_PYTHON) -m pip install uv --upgrade

.PHONY: upgrade_requirements
upgrade_requirements: $(VENV_ACTIVATE)
	$(UV) pip compile --upgrade -o requirements.txt pyproject.toml

.PHONY: sync
sync: $(VENV_ACTIVATE) requirements.txt
	$(UV) pip sync requirements.txt

.PHONY: upgrade_venv
upgrade_venv: upgrade_uv upgrade_requirements sync

.PHONY: list
list: $(VENV_ACTIVATE)
	$(UV) pip list

.PHONY: clean
clean:
    ifeq ($(OS),Windows_NT)
		$(CMD) /c "FOR %%F IN ($(VENV_DIR) $(VENV_CLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"
    else
		rm -rf $(VENV_DIR) $(VENV_CLEAN_DIRS)
    endif

.PHONY: build
build: $(VENV_ACTIVATE) dot_gitignore.jinja2 update_gitignore.py
	$(VENV_PYTHON) update_gitignore.py
	$(VENV_PYTHON) -c "import datetime; d=datetime.date.today(); print(f'VERSION=""{d.year:d}.{d.month:d}.{d.day:d}""')" > "$(VERSION_FILE)"
