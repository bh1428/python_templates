#
# makefile for {{cookiecutter.repo_name}}
#

# Make targets:
#   init                  alias for initial setup of virtual env
#   upgrade_pip_tools     upgrade pip and the pip-tools package
#   upgrade_requirements  upgrade *requirements.txt files without installing
#   upgrade_venv          upgrade pip-tools, *requirements.txt and install packages
#   sync                  synchronize venv with *requirements.txt (default target)
#   list                  show list of installed packages in the venv
#   clean                 remove virtual environment
#   build                 build project
#   run                   execute script
#   qt_designer           start QT Designer

# names (directories & files)
SCRIPT_NAME := {{cookiecutter.repo_name}}
ICON_NAME := python-icon.svg
VENV_DIR := venv
DIST_DIR := dist
VENV_CLEAN_DIRS := .mypy_cache __pycache__
PRECLEAN_DIRS := $(DIST_DIR)
PRECLEAN_FILES :=
POSTCLEAN_DIRS :=
POSTCLEAN_FILES :=

# binaries / executables
CMD := "C:\Windows\System32\cmd.exe"
PYTHON := "{{cookiecutter.python_path}}"
VENV := .\$(VENV_DIR)\Scripts
VENV_ACTIVATE := $(VENV)\activate.bat
VENV_PYTHON := $(VENV)\python.exe
PIP := $(VENV)\pip.exe
PIP_SYNC := $(VENV)\pip-sync.exe
PIP_SYNC_OPTIONS := --pip-args '--no-deps --require-hashes'
PIP_COMPILE := $(VENV)\pip-compile.exe
PIP_COMPILE_OPTIONS := --resolver=backtracking --generate-hashes
PYSIDE6_UIC := $(VENV)\pyside6-uic.exe
PYSIDE6_RCC := $(VENV)\pyside6-rcc.exe
QT_DESIGNER := $(VENV_DIR)\Lib\site-packages\PySide6\designer.exe

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
    ifeq (,$(wildcard dev-requirements.txt))
		$(PIP_COMPILE) $(PIP_COMPILE_OPTIONS) dev-requirements.in
    endif
	$(PIP_SYNC) $(PIP_SYNC_OPTIONS) dev-requirements.txt

requirements.txt: $(VENV_ACTIVATE) requirements.in
	$(PIP_COMPILE) $(PIP_COMPILE_OPTIONS) requirements.in

dev-requirements.txt: $(VENV_ACTIVATE) dev-requirements.in requirements.txt
	$(PIP_COMPILE) $(PIP_COMPILE_OPTIONS) dev-requirements.in

.PHONY: upgrade_pip_tools
upgrade_pip_tools: $(VENV_ACTIVATE)
	$(VENV_PYTHON) -m pip install pip --upgrade
	$(VENV_PYTHON) -m pip install pip-tools --upgrade

.PHONY: upgrade_requirements
upgrade_requirements: $(VENV_ACTIVATE)
	$(PIP_COMPILE) --upgrade $(PIP_COMPILE_OPTIONS) requirements.in
	$(PIP_COMPILE) --upgrade $(PIP_COMPILE_OPTIONS) dev-requirements.in

.PHONY: sync
sync: $(VENV_ACTIVATE) dev-requirements.txt
	$(PIP_SYNC) $(PIP_SYNC_OPTIONS) dev-requirements.txt

.PHONY: upgrade_venv
upgrade_venv: upgrade_pip_tools upgrade_requirements sync

.PHONY: list
list: $(VENV_ACTIVATE)
	$(PIP) list

.PHONY: clean
clean:
	$(CMD) /c "FOR %%F IN ($(VENV_DIR) $(VENV_CLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"

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

.PHONY: build
build: $(VENV_ACTIVATE) $(SCRIPT_NAME)_ui.py $(SCRIPT_NAME)_rc.py
	$(CMD) /c "FOR %%F IN ($(PRECLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"
	$(CMD) /c "FOR %%F IN ($(PRECLEAN_FILES)) DO IF EXIST %%F del %%F"
	$(CMD) /c "IF NOT EXIST $(DIST_DIR) mkdir $(DIST_DIR)"
	$(CMD) /c "FOR %%F IN ($(SCRIPT_NAME).py $(SCRIPT_NAME)_ui.py $(SCRIPT_NAME)_rc.py) DO IF EXIST "%%F" copy /y "%%F" $(DIST_DIR)"
	$(CMD) /c "FOR %%F IN ($(POSTCLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"
	$(CMD) /c "FOR %%F IN ($(POSTCLEAN_FILES)) DO IF EXIST %%F del %%F"
