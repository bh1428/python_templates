#
# makefile for {{ cookiecutter.repo_name }}
#

# Make targets:
#   init                    initial setup virtual env
#   upgrade_uv              upgrade uv
#   upgrade_requirements    upgrade *requirements.txt files without installing
#   upgrade_all             upgrade uv, *requirements.txt and install packages
#   sync                    ynchronize venv with dev-requirements.txt
#   list                    show list of installed packages in the venv
#   build                   build executable

# project / build properties
SCRIPT_NAME := {{ cookiecutter.repo_name }}
ICON_FILE := images/python.ico
VENV_DIR := .venv
BUILD_DIR := build
BUILD_TARGET_DIR := dist
BUILD_INFO := build_info.txt
PRE_BUILD_CLEAN := @("$(BUILD_DIR)", "$(BUILD_TARGET_DIR)", "$(SCRIPT_NAME).spec", "$(SCRIPT_NAME)_info.txt")
CMDLINE_OPTIONS := cmdline_options.txt

# binaries / executables
SHELL := powershell.exe
.SHELLFLAGS := -NoProfile -Command
OUT_NEW := | Out-File -Encoding default
OUT_APP := | Out-File -Encoding default -Append
UV := uv
VENV := .\$(VENV_DIR)\Scripts
VENV_ACTIVATE := $(VENV)\activate.ps1
VENV_PYTHON := $(VENV)\python.exe
PYINSTALLER := $(VENV)\pyinstaller.exe

all: build

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

.PHONY: build
build: $(VENV_ACTIVATE)
	foreach ($$item in $(PRE_BUILD_CLEAN)) { if (Test-Path -LiteralPath $$item) { Remove-Item -LiteralPath $$item -Force -Recurse }}
	$(VENV_PYTHON) mk_file_version_info.py --out "$(SCRIPT_NAME)_info.txt" "$(SCRIPT_NAME).py"
	$(PYINSTALLER) --version-file "$(SCRIPT_NAME)_info.txt" --onefile --icon="$(ICON_FILE)" "$(SCRIPT_NAME).py"
	$(VENV_PYTHON) -c "import sys; import datetime; print(f'Python {sys.version}'); print(f'Build time: {datetime.datetime.now().astimezone()}\n')" $(OUT_NEW) "$(BUILD_INFO)"
	$(UV) pip list $(OUT_APP) "$(BUILD_INFO)"
	Move-Item -LiteralPath "$(BUILD_INFO)" -Destination "$(BUILD_TARGET_DIR)"
	$(VENV_PYTHON) $(SCRIPT_NAME).py --help $(OUT_NEW) "$(CMDLINE_OPTIONS)"
	Move-Item -LiteralPath "$(CMDLINE_OPTIONS)" -Destination "$(BUILD_TARGET_DIR)"
