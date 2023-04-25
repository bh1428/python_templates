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
#   clean                 remove virtual environment

# names (directories & files)
PACKAGE := {{ cookiecutter.package_name }}
VENV_DIR := venv
VENV_CLEAN_DIRS := .mypy_cache __pycache__
PRECLEAN_DIRS := build dist {{ cookiecutter.package_name }}.egg-info
PRECLEAN_FILES :=
POSTCLEAN_DIRS := build {{cookiecutter.package_name}}.egg-info
POSTCLEAN_FILES :=
COVERAGE_HTML := coverage_html
EXTRA_CLEAN_FILES := .coverage
PYTEST_CACHE := .pytest_cache

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
PIP_COMPILE_OPTIONS := --resolver=backtracking
PYTEST := $(VENV)\pytest.exe


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
	$(PIP) install -e .

.PHONY: build
build: $(VENV_ACTIVATE)
	$(CMD) /c "FOR %%F IN ($(PRECLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"
	$(CMD) /c "FOR %%F IN ($(PRECLEAN_FILES)) DO IF EXIST %%F del %%F"
	$(VENV_PYTHON) setup.py bdist_wheel
	$(CMD) /c "FOR %%F IN ($(POSTCLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"
	$(CMD) /c "FOR %%F IN ($(POSTCLEAN_FILES)) DO IF EXIST %%F del %%F"
	$(VENV_PYTHON) -c "import sys; import datetime; print(f'Python {sys.version}'); print(f'Build time: {datetime.datetime.now().astimezone()}\n')" > build_info.txt
	$(PIP) list >> build_info.txt
	$(CMD) /c copy build_info.txt dist

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
	$(PIP) install -e .

.PHONY: upgrade_venv
upgrade_venv: upgrade_pip_tools upgrade_requirements sync
    
.PHONY: list
list: $(VENV_ACTIVATE)
	$(PIP) list

.PHONY: clean
clean:
	$(CMD) /c "FOR %%F IN ($(COVERAGE_HTML)) DO IF EXIST %%F rmdir /q /s %%F"
	$(CMD) /c "FOR %%F IN ($(PRECLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"
	$(CMD) /c "FOR %%F IN ($(PRECLEAN_FILES)) DO IF EXIST %%F del %%F"
	$(CMD) /c "FOR %%F IN ($(POSTCLEAN_DIRS)) DO IF EXIST %%F rmdir /q /s %%F"
	$(CMD) /c "FOR %%F IN ($(POSTCLEAN_FILES)) DO IF EXIST %%F del %%F"
	$(CMD) /c "FOR %%F IN ($(VENV_DIR) $(VENV_CLEAN_DIRS) $(PYTEST_CACHE)) DO IF EXIST %%F rmdir /q /s %%F"
	$(CMD) /c "FOR %%F IN ($(EXTRA_CLEAN_FILES)) DO IF EXIST %%F del %%F"
