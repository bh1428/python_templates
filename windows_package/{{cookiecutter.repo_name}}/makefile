#
# makefile for Visual Studio Code (VSC) based Python package
#

# Make targets (can be used when calling make):
#   init                  alias for initial setup of virtual env
#   upgrade_pip_tools     upgrade pip and the pip-tools package
#   upgrade_requirements  upgrade *requirements.txt files without installing
#   upgrade_venv          upgrade pip-tools, *requirements.txt and install packages
#   sync                  synchronize venv with *requirements.txt (default target)
#   list                  show list of installed packages in the venv

# names (directories & files)
PACKAGE := {{ cookiecutter.package_name }}
VENV_DIR := .venv
BUILD_TARGET := build
PRE_BUILD_CLEAN_DIRS := build $(BUILD_TARGET) {{ cookiecutter.package_name }}.egg-info
PRE_BUILD_CLEAN_FILES :=
COVERAGE_HTML := coverage_html
EXTRA_CLEAN_FILES := .coverage

# binaries / executables
CMD := "C:\Windows\System32\cmd.exe"
PYTHON := "C:\Program Files\Python313\python.exe"
VENV := .\$(VENV_DIR)\Scripts
VENV_ACTIVATE := $(VENV)\activate.bat
VENV_PYTHON := $(VENV)\python.exe
UV := $(VENV)\uv.exe
PYTEST := $(VENV)\pytest.exe


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
	$(UV) pip install -e .

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

.PHONY: test
test: $(VENV_ACTIVATE)
	$(PYTEST) tests

.PHONY: coverage
coverage: $(VENV_ACTIVATE)
	$(VENV_PYTHON) -m coverage erase
	$(CMD) /c "FOR %%F IN ($(COVERAGE_HTML)) DO IF EXIST %%F rmdir /q /s %%F"
	$(PYTEST) --cov=$(PACKAGE) tests
	$(VENV_PYTHON) -m coverage html -d $(COVERAGE_HTML)
	$(CMD) /c start $(COVERAGE_HTML)\index.html

.PHONY: build
build: $(VENV_ACTIVATE)
	$(CMD) /c "FOR %%F IN ($(PRE_BUILD_CLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"
	$(CMD) /c "FOR %%F IN ($(PRE_BUILD_CLEAN_FILES)) DO IF EXIST %%F del %%F"
	$(VENV_PYTHON) -m build --wheel
	$(CMD) /c "FOR %%F IN ($(POSTCLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"
	$(CMD) /c "FOR %%F IN ($(POSTCLEAN_FILES)) DO IF EXIST %%F del %%F"
	$(VENV_PYTHON) -c "import sys; import datetime; print(f'Python {sys.version}'); print(f'Build time: {datetime.datetime.now().astimezone()}\n')" > build_info.txt
	$(UV) pip list >> build_info.txt
	$(CMD) /c copy build_info.txt dist
