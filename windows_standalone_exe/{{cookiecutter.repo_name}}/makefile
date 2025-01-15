#
# makefile for {{ cookiecutter.repo_name }}
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
#  7) Perform a build by executing: `make build`
#  8) If all goes well: `.exe` will be in the 'dist' directory.

# Make targets:
#   init                  alias for initial setup of virtual environment
#   sync                  synchronize virtual env with *requirements.txt
#   build                 create virtual environment (if required) and build
#                         executable (this is the default target (all))
#   upgrade_uv            upgrade pip and the uv package
#   upgrade_requirements  upgrade *requirements.txt files without installing
#   upgrade_venv          upgrade uv, requirements.txt and install packages
#   list                  show list of installed packages in the venv


# script properties
SCRIPT_NAME := {{ cookiecutter.repo_name }}
ICON_FILE := images/python.ico

# names (directories & files)
VENV_DIR := .venv
BUILD_TARGET := dist
PRE_BUILD_CLEAN_DIRS := build $(BUILD_TARGET)
PRE_BUILD_CLEAN_FILES := $(SCRIPT_NAME).spec $(SCRIPT_NAME)_info.txt
BUILD_INFO := build_info.txt
CMDLINE_OPTIONS := cmdline_options.txt
EXTRA_FILES := $(BUILD_INFO) $(CMDLINE_OPTIONS)

# binaries / executables
CMD := "C:\Windows\System32\cmd.exe"
PYTHON := "C:\Program Files\Python313\python.exe"
VENV := .\$(VENV_DIR)\Scripts
VENV_ACTIVATE := $(VENV)\activate.bat
VENV_PYTHON := $(VENV)\python.exe
UV := $(VENV)\uv.exe
PYINSTALLER := $(VENV)\pyinstaller.exe


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

.PHONY: build
build: $(VENV_ACTIVATE)
	$(CMD) /c "FOR %%F IN ($(PRE_BUILD_CLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"
	$(CMD) /c "FOR %%F IN ($(PRE_BUILD_CLEAN_FILES)) DO IF EXIST %%F del %%F"
	$(VENV_PYTHON) mk_file_version_info.py --out $(SCRIPT_NAME)_info.txt $(SCRIPT_NAME).py
	$(PYINSTALLER) --version-file $(SCRIPT_NAME)_info.txt --onefile --icon=$(ICON_FILE) $(SCRIPT_NAME).py
	$(VENV_PYTHON) -c "import sys; import datetime; print(f'Python {sys.version}'); print(f'Build time: {datetime.datetime.now().astimezone()}\n')" > $(BUILD_INFO)
	$(UV) pip list >> build_info.txt
	$(VENV_PYTHON) $(SCRIPT_NAME).py --help > $(CMDLINE_OPTIONS)
	$(CMD) /c "FOR %%F IN ($(EXTRA_FILES)) DO IF EXIST "%%F" copy "%%F" $(BUILD_TARGET)"
