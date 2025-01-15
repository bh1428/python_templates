#
# makefile for {{ cookiecutter.repo_name }}
#

# Make targets:
#   init                  alias for initial setup of virtual env
#   upgrade_uv            upgrade pip and the uv package
#   upgrade_requirements  upgrade *requirements.txt files without installing
#   upgrade_venv          upgrade uv, requirements.txt and install packages
#   sync                  synchronize venv with *requirements.txt (default target)
#   list                  show list of installed packages in the venv
#   build                 build project
#   run                   execute script
#   qt_designer           start QT Designer

# names (directories & files)
SCRIPT_NAME := {{ cookiecutter.repo_name }}
ICON_NAME := python-icon.svg
VENV_DIR := .venv

# binaries / executables
CMD := "C:\Windows\System32\cmd.exe"
PYTHON := "C:\Program Files\Python313\python.exe"
VENV := .\$(VENV_DIR)\Scripts
VENV_ACTIVATE := $(VENV)\activate.bat
VENV_PYTHON := $(VENV)\python.exe
UV := $(VENV)\uv.exe
PYSIDE6_UIC := $(VENV)\pyside6-uic.exe
PYSIDE6_RCC := $(VENV)\pyside6-rcc.exe
QT_DESIGNER := $(VENV_DIR)\Lib\site-packages\PySide6\designer.exe


all: init

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
	$(VENV_PYTHON) -m pip install pip --upgrade
	$(VENV_PYTHON) -m pip install uv --upgrade

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

.PHONY: qt_designer
qt_designer: $(VENV_ACTIVATE)
	$(QT_DESIGNER) $(SCRIPT_NAME).ui

$(SCRIPT_NAME)_ui.py: $(SCRIPT_NAME).ui
	$(PYSIDE6_UIC) -o $(SCRIPT_NAME)_ui.py $(SCRIPT_NAME).ui

$(SCRIPT_NAME)_rc.py: $(SCRIPT_NAME).qrc $(ICON_NAME)
	$(PYSIDE6_RCC) -o $(SCRIPT_NAME)_rc.py $(SCRIPT_NAME).qrc

.PHONY: run
run: $(VENV_ACTIVATE) $(SCRIPT_NAME)_ui.py $(SCRIPT_NAME)_rc.py
	$(VENV_PYTHON) $(SCRIPT_NAME).py
