#
# makefile for {{cookiecutter.repo_name}}
#

# Build executable / development:
#  1) Develop and test script until it is ready for deployment / packaging.
#  2) Add required packages to 'requirements.in'.
#  3) If development specific packages are required: add them to
#     'dev-requirements.in' (normally not required).
#  4) To process package changes run: 'make' (or 'make sync')
#  5) If required: add extra files (to be copied to 'dist' directory)
#     to EXTRA_FILES
#  6) Change icon if required (variable ICON_FILE).
#  7) Perform a build by executing: make
#  8) If all goes well: .exe will be in the 'dist' directory.

# Make targets (can be used when calling make):
#   init                  alias for initial setup of virtual env
#   build                 create virtual environment (if required) and build
#                         executable (this is the default target (all))
#   upgrade_pip_tools     upgrade pip and the pip-tools package
#   upgrade_requirements  upgrade *requirements.txt files without installing
#   upgrade_venv          upgrade pip-tools, *requirements.txt and install packages
#   sync                  synchronize venv with *requirements.txt
#   list                  show list of installed packages in the venv
#   clean                 remove all temporary files and directories
#   clean_venv            remove virtual environment

# script properties
SCRIPT_NAME := {{cookiecutter.repo_name}}
ICON_FILE := images/python.ico

# names (directories & files)
VENV_DIR := .venv
VENV_CLEAN_DIRS := __pycache__
PRE_BUILD_CLEAN_DIRS := build dist
PRE_BUILD_CLEAN_FILES := $(SCRIPT_NAME).spec $(SCRIPT_NAME)_info.txt
POST_BUILD_CLEAN_DIRS := build
POST_BUILD_CLEAN_FILES :=
BUILD_INFO := build_info.txt
CMDLINE_OPTIONS := cmdline_options.txt
EXTRA_FILES := $(BUILD_INFO) $(CMDLINE_OPTIONS)

# binaries / executables
CMD := "C:\Windows\System32\cmd.exe"
PYTHON := "{{ cookiecutter.python_path }}"
VENV := .\$(VENV_DIR)\Scripts
VENV_ACTIVATE := $(VENV)\activate.bat
VENV_PYTHON := $(VENV)\python.exe
PIP := $(VENV)\pip.exe
PIP_SYNC := $(VENV)\pip-sync.exe
PIP_SYNC_OPTIONS := --pip-args '--no-deps'
PIP_COMPILE := $(VENV)\pip-compile.exe
PIP_COMPILE_OPTIONS := --resolver=backtracking --strip-extras
PYINSTALLER := $(VENV)\pyinstaller.exe

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

.PHONY: pre_build_exe_clean
pre_build_exe_clean:
	$(CMD) /c "FOR %%F IN ($(PRE_BUILD_CLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"
	$(CMD) /c "FOR %%F IN ($(PRE_BUILD_CLEAN_FILES)) DO IF EXIST %%F del %%F"

$(SCRIPT_NAME)_info.txt: $(VENV_ACTIVATE) $(SCRIPT_NAME).py
	$(VENV_PYTHON) mk_file_version_info.py --out $(SCRIPT_NAME)_info.txt $(SCRIPT_NAME).py

.PHONY: pre_build_exe
pre_build_exe: pre_build_exe_clean $(SCRIPT_NAME)_info.txt

.PHONY: build_exe
build_exe: $(VENV_ACTIVATE) pre_build_exe
	$(PYINSTALLER) --version-file $(SCRIPT_NAME)_info.txt --onefile --icon=$(ICON_FILE) $(SCRIPT_NAME).py

.PHONY: post_build_exe
post_build_exe: build_exe
	$(VENV_PYTHON) -c "import sys; import datetime; print(f'Python {sys.version}'); print(f'Build time: {datetime.datetime.now().astimezone()}\n')" > $(BUILD_INFO)
	$(PIP) list >> $(BUILD_INFO)
	$(VENV_PYTHON) $(SCRIPT_NAME).py --help > $(CMDLINE_OPTIONS)
	$(CMD) /c "FOR %%F IN ($(EXTRA_FILES)) DO IF EXIST "%%F" copy "%%F" dist"
	$(CMD) /c "FOR %%F IN ($(POST_BUILD_CLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"
	$(CMD) /c "FOR %%F IN ($(POST_BUILD_CLEAN_FILES)) DO IF EXIST %%F del %%F"

.PHONY: build
build: post_build_exe

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

.PHONY: clean_venv
clean_venv:
	$(CMD) /c "FOR %%F IN ($(VENV_DIR) $(VENV_CLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"

.PHONY: clean
clean:
	$(CMD) /c "FOR %%F IN ($(PRE_BUILD_CLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"
	$(CMD) /c "FOR %%F IN ($(PRE_BUILD_CLEAN_FILES)) DO IF EXIST %%F del %%F"
	$(CMD) /c "FOR %%F IN ($(POST_BUILD_CLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"
	$(CMD) /c "FOR %%F IN ($(POST_BUILD_CLEAN_FILES)) DO IF EXIST %%F del %%F"
	$(CMD) /c "FOR %%F IN ($(VENV_DIR) $(VENV_CLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"
