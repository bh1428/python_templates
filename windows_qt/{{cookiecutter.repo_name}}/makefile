#
# makefile for {{ cookiecutter.repo_name }}
#

# Make targets:
#   init                    initial setup virtual env
#   upgrade_uv              upgrade uv
#   upgrade_requirements    upgrade *requirements.txt files without installing
#   upgrade_all             upgrade uv, *requirements.txt and install packages
#   sync                    synchronize venv with dev-requirements.txt
#   list                    show list of installed packages in the venv
#   build                   build executable
#   run                     execute script
#   qt_designer             start QT Designer


# project properties
SCRIPT_NAME := {{ cookiecutter.repo_name }}
ICON_FILE := python-icon.svg
VENV_DIR := .venv

# binaries / executables
SHELL := powershell.exe
.SHELLFLAGS := -NoProfile -Command
UV := uv
VENV := .\$(VENV_DIR)\Scripts
VENV_ACTIVATE := $(VENV)\activate.ps1
VENV_PYTHON := $(VENV)\python.exe
PYSIDE6_UIC := $(VENV)\pyside6-uic.exe
PYSIDE6_RCC := $(VENV)\pyside6-rcc.exe
QT_DESIGNER := $(VENV_DIR)\Lib\site-packages\PySide6\designer.exe

all: init

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
	$(UV) pip sync dev-requirements.txt --require-hashes --allow-empty-requirements

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
	$(UV) pip sync dev-requirements.txt --require-hashes --allow-empty-requirements

.PHONY: list
list: $(VENV_ACTIVATE)
	$(UV) pip list

.PHONY: qt_designer
qt_designer: $(VENV_ACTIVATE)
	$(QT_DESIGNER) "$(SCRIPT_NAME).ui"

$(SCRIPT_NAME)_ui.py: $(SCRIPT_NAME).ui
	$(PYSIDE6_UIC) -o "$(SCRIPT_NAME)_ui.py" "$(SCRIPT_NAME).ui"

$(SCRIPT_NAME)_rc.py: $(SCRIPT_NAME).qrc $(ICON_FILE)
	$(PYSIDE6_RCC) -o "$(SCRIPT_NAME)_rc.py" "$(SCRIPT_NAME).qrc"

.PHONY: run
run: $(VENV_ACTIVATE) $(SCRIPT_NAME)_ui.py $(SCRIPT_NAME)_rc.py
	$(VENV_PYTHON) "$(SCRIPT_NAME).py"
