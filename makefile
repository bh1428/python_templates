#
# makefile for python_templates
#

# Make targets (can be used when calling make):
#   init                  alias for initial setup of virtual env
#   upgrade_pip_tools     upgrade pip and the pip-tools package
#   upgrade_requirements  upgrade *requirements.txt files without installing
#   upgrade_venv          upgrade pip-tools, *requirements.txt and install packages
#   sync                  synchronize venv with *requirements.txt
#   list                  show list of installed packages in the venv
#   clean                 remove virtual environment
#   build                 build templates

# names (directories & files)
VENV_DIR := venv
VENV_CLEAN_DIRS := .mypy_cache __pycache__

# executables for each supported OS
ifeq ($(OS),Windows_NT)
	# Windows
	CMD := "C:\Windows\System32\cmd.exe"
	PYTHON := "C:\Program Files\Python311\python.exe"
	VENV := .\$(VENV_DIR)\Scripts
	VENV_ACTIVATE := $(VENV)\activate.bat
	VENV_PYTHON := $(VENV)\python.exe
	PIP := $(VENV)\pip.exe
	PIP_SYNC := $(VENV)\pip-sync.exe
	PIP_COMPILE := $(VENV)\pip-compile.exe
else
	# Linux
	PYTHON := "/usr/bin/python3.11"
	VENV := ./$(VENV_DIR)/bin
	VENV_ACTIVATE := $(VENV)/activate
	VENV_PYTHON := $(VENV)/python
	PIP := $(VENV)/pip
	PIP_SYNC := $(VENV)/pip-sync
	PIP_COMPILE := $(VENV)/pip-compile
endif

# options
PIP_SYNC_OPTIONS := --pip-args --no-deps
PIP_COMPILE_OPTIONS := --resolver=backtracking --strip-extras

all: build

.NOTPARALLEL:

init: $(VENV_ACTIVATE)

$(VENV_ACTIVATE):
	$(PYTHON) -m venv $(VENV_DIR)
	$(VENV_PYTHON) -m pip install pip --upgrade
	$(VENV_PYTHON) -m pip install wheel
	$(VENV_PYTHON) -m pip install pip-tools
    ifeq (,$(wildcard requirements.txt))
		$(PIP_COMPILE) $(PIP_COMPILE_OPTIONS) requirements.in
    endif
	$(PIP_SYNC) $(PIP_SYNC_OPTIONS) requirements.txt

requirements.txt: $(VENV_ACTIVATE) requirements.in
	$(PIP_COMPILE) $(PIP_COMPILE_OPTIONS) requirements.in

.PHONY: upgrade_pip_tools
upgrade_pip_tools: $(VENV_ACTIVATE)
	$(VENV_PYTHON) -m pip install pip --upgrade
	$(VENV_PYTHON) -m pip install pip-tools --upgrade

.PHONY: upgrade_requirements
upgrade_requirements: $(VENV_ACTIVATE)
	$(PIP_COMPILE) --upgrade $(PIP_COMPILE_OPTIONS) requirements.in

.PHONY: sync
sync: $(VENV_ACTIVATE) requirements.txt
	$(PIP_SYNC) $(PIP_SYNC_OPTIONS) requirements.txt

.PHONY: upgrade_venv
upgrade_venv: upgrade_pip_tools upgrade_requirements sync
    
.PHONY: list
list: $(VENV_ACTIVATE)
	$(PIP) list

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