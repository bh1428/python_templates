#
# makefile for Visual Studio Code (VSC) based Python package
#

# Make targets:
#   init                    initial setup virtual env
#   upgrade_uv              upgrade uv
#   upgrade_requirements    upgrade *requirements.txt files without installing
#   upgrade_all             upgrade uv, *requirements.txt and install packages
#   sync                    synchronize venv with dev-requirements.txt
#   list                    show list of installed packages in the venv
#   test                    run unittests
#   coverage                run unittests with coverage and make report
#   build                   build package

# project / build properties
PACKAGE := {{ cookiecutter.package_name }}
PYTHON_VERSION := {{ cookiecutter.python_version }}
VENV_DIR := .venv
BUILD_DIR := build
BUILD_TARGET_DIR := dist
BUILD_INFO := build_info.txt
COVERAGE_HTML := coverage_html
PRE_BUILD_CLEAN := @("$(BUILD_DIR)", "$(BUILD_TARGET_DIR)", "$(PACKAGE).egg-info")

# binaries / executables
SHELL := powershell.exe
.SHELLFLAGS := -NoProfile -Command
OUT_NEW := | Out-File -Encoding default
OUT_APP := | Out-File -Encoding default -Append
UV := uv
VENV := .\$(VENV_DIR)\Scripts
VENV_ACTIVATE := $(VENV)\activate.ps1
VENV_PYTHON := $(VENV)\python.exe
PYTEST := $(VENV)\pytest.exe

all: build

.NOTPARALLEL:

init: $(VENV_ACTIVATE)

$(VENV_ACTIVATE):
	$(UV) python pin $(PYTHON_VERSION)
	$(UV) venv
    ifeq (,$(wildcard requirements.txt))
		$(UV) pip compile pyproject.toml -o requirements.txt
    endif
    ifeq (,$(wildcard dev-requirements.txt))
		$(UV) pip compile pyproject.toml --extra dev -o dev-requirements.txt
    endif
	$(UV) pip sync dev-requirements.txt --allow-empty-requirements
	$(UV) pip install -e .

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
	$(UV) pip sync dev-requirements.txt --allow-empty-requirements
	$(UV) pip install -e .

.PHONY: list
list: $(VENV_ACTIVATE)
	$(UV) pip list

.PHONY: test
test: $(VENV_ACTIVATE)
	$(PYTEST) tests

.PHONY: coverage
coverage: $(VENV_ACTIVATE)
	$(VENV_PYTHON) -m coverage erase
	if (Test-Path -LiteralPath $(COVERAGE_HTML)) { Remove-Item -LiteralPath $(COVERAGE_HTML) -Force -Recurse }
	$(PYTEST) --cov=$(PACKAGE) tests
	$(VENV_PYTHON) -m coverage html -d $(COVERAGE_HTML)
	start $(COVERAGE_HTML)\index.html

.PHONY: build
build: $(VENV_ACTIVATE)
	foreach ($$item in $(PRE_BUILD_CLEAN)) { if (Test-Path -LiteralPath $$item) { Remove-Item -LiteralPath $$item -Force -Recurse }}
	$(UV) build --wheel
	$(VENV_PYTHON) -c "import sys; import datetime; print(f'Python {sys.version}'); print(f'Build time: {datetime.datetime.now().astimezone()}\n')" $(OUT_NEW) $(BUILD_INFO)
	$(UV) pip list $(OUT_APP) $(BUILD_INFO)
	Move-Item -LiteralPath $(BUILD_INFO) -Destination $(BUILD_TARGET_DIR)
