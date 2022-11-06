#
# makefile for Visual Studio Code (VSC) based Python projects
#

# Make targets (can be used when calling make):
#   init                  alias for initial setup of virtual env
#   upgrade_pip_tools     upgrade pip and the pip-tools package
#   upgrade_requirements  upgrade *requirements.txt files without installing
#   upgrade_venv          upgrade pip-tools, *requirements.txt and install packages
#   sync                  synchronize venv with *requirements.txt (default target)
#   list                  show list of installed packages in the venv
#   clean                 remove virtual environment

# names (directories & files)
VENV_DIR := venv
VENV_CLEAN_DIRS := .mypy_cache __pycache__

# executables for each supported OS
ifeq ($(OS),Windows_NT)
	# Windows
	CMD := "C:\Windows\System32\cmd.exe"
	PYTHON := "C:\Program Files\Python310\python.exe"
	VENV_DIR := $(VENV_DIR)_win
	VENV := .\$(VENV_DIR)\Scripts
	VENV_ACTIVATE := $(VENV)\activate.bat
	VENV_PYTHON := $(VENV)\python.exe
	PIP := $(VENV)\pip.exe
	PIP_SYNC := $(VENV)\pip-sync.exe
	PIP_COMPILE := $(VENV)\pip-compile.exe
else
	# Linux
	PYTHON := "/usr/bin/python3.10"
	VENV_DIR := $(VENV_DIR)_linux
	VENV := ./$(VENV_DIR)/bin
	VENV_ACTIVATE := $(VENV)/activate
	VENV_PYTHON := $(VENV)/python
	PIP := $(VENV)/pip
	PIP_SYNC := $(VENV)/pip-sync
	PIP_COMPILE := $(VENV)/pip-compile
endif


all: sync

.NOTPARALLEL:

init: $(VENV_ACTIVATE)

$(VENV_ACTIVATE):
	$(PYTHON) -m venv $(VENV_DIR)
	$(VENV_PYTHON) -m pip install pip --upgrade
	$(VENV_PYTHON) -m pip install wheel
	$(VENV_PYTHON) -m pip install pip-tools
    ifeq (,$(wildcard requirements.txt))
		$(PIP_COMPILE) requirements.in
    endif
    ifeq (,$(wildcard dev-requirements.txt))
		$(PIP_COMPILE) dev-requirements.in
    endif
	$(PIP_SYNC) dev-requirements.txt --pip-args '--no-deps'

requirements.txt: $(VENV_ACTIVATE) requirements.in
	$(PIP_COMPILE) requirements.in

dev-requirements.txt: $(VENV_ACTIVATE) dev-requirements.in requirements.txt
	$(PIP_COMPILE) dev-requirements.in

.PHONY: upgrade_pip_tools
upgrade_pip_tools: $(VENV_ACTIVATE)
	$(VENV_PYTHON) -m pip install pip --upgrade
	$(VENV_PYTHON) -m pip install pip-tools --upgrade

.PHONY: upgrade_requirements
upgrade_requirements: $(VENV_ACTIVATE)
	$(PIP_COMPILE) requirements.in --upgrade
	$(PIP_COMPILE) dev-requirements.in --upgrade

.PHONY: sync
sync: $(VENV_ACTIVATE) dev-requirements.txt
	$(PIP_SYNC) dev-requirements.txt --pip-args '--no-deps'

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
