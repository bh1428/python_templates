#
# makefile for python_templates
#

# Make targets (can be used when calling make):
#   init                  alias for initial setup of virtual env
#   upgrade_pip_tools     upgrade pip and the pip-tools package
#   upgrade_requirements  upgrade *requirements.txt files without installing
#   upgrade_venv          upgrade pip-tools, *requirements.txt and install packages
#   sync                  synchronize venv with *requirements.txt
#   info                  show list of installed packages in the venv
#   clean                 remove virtual environment
#   build                 build templates

# names (directories & files)
VENV_DIR := venv
VENV_CLEAN_DIRS := .mypy_cache __pycache__

# binaries / executables
CMD := "C:\Windows\System32\cmd.exe"
PYTHON := "C:\Program Files\Python39\python.exe"
VENV := .\$(VENV_DIR)\Scripts
VENV_ACTIVATE := $(VENV)\activate.bat
VENV_PYTHON := $(VENV)\python.exe
PIP := $(VENV)\pip.exe
PIP_SYNC := $(VENV)\pip-sync.exe
PIP_COMPILE := $(VENV)\pip-compile.exe

all: build

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
	$(PIP_SYNC) requirements.txt --pip-args '--no-deps'

requirements.txt: $(VENV_ACTIVATE) requirements.in
	$(PIP_COMPILE) requirements.in

.PHONY: upgrade_pip_tools
upgrade_pip_tools: $(VENV_ACTIVATE)
	$(VENV_PYTHON) -m pip install pip --upgrade
	$(VENV_PYTHON) -m pip install pip-tools --upgrade

.PHONY: upgrade_requirements
upgrade_requirements: $(VENV_ACTIVATE)
	$(PIP_COMPILE) requirements.in --upgrade

.PHONY: sync
sync: $(VENV_ACTIVATE) requirements.txt
	$(PIP_SYNC) requirements.txt --pip-args '--no-deps'

.PHONY: upgrade_venv
upgrade_venv: upgrade_pip_tools upgrade_requirements sync
    
.PHONY: info
info: $(VENV_ACTIVATE)
	$(PIP) list

.PHONY: clean
clean:
	$(CMD) /c "FOR %%F IN ($(VENV_DIR) $(VENV_CLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"

.PHONY: build
build: $(VENV_ACTIVATE) dot_gitignore.jinja2 update_gitignore.py
	$(VENV_PYTHON) update_gitignore.py