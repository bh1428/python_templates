# Python Templates for Windows projects

## Templates
This repository contains [Cookiecutter](https://cookiecutter.readthedocs.io/) templates for Python development projects (on Windows and limited Linux support). All templates use a combination of make with [uv](https://docs.astral.sh/uv/) to manage a virtual environment. `uv` and `make` MUST be preinstalled in the OS. These templates are available:
  * __windows_package__: minimal Python package setup.
  * __windows_qt__: basic Qt / PySide6 application (using VSCode and QT Designer).
  * __windows_standalone_exe__: standalone (Windows) executable (with an example how the combination of `click`, `logging` (both to file and console) and `pyinstaller` can be used).
  * __vscode__: basic VSCode template.

On Windows, you can use the PowerShell script `cookiecutter.ps1` to create new projects from the templates:
  - Copy `cookiecutter.ps1` to your main project directory (projects will be created as sub-directories).
  - Adapt configuration in `cookiecutter.ps1`:
    * `COOKIECUTTER`: location of the `cookiecutter.exe` executable (must be somewhere installed in a Python (virtual) environment)
    * `TEMPLATE_DIRS`: templates should be sub-directories of this folder
  - Run `cookiecutter.ps1` and use the menu to select the template

## uv / pip-tools
Initially the templates were based on the wonderful [pip-tools](https://pip-tools.readthedocs.io/en/latest/). However the world is changed when [uv](https://docs.astral.sh/uv/) was released and although the workflow from `pip-tools` is still valid, the speed of `uv` makes handling packages and virtual environments a lot more convenient. Currently the templates are based on [uv](https://docs.astral.sh/uv/) although a workflow comparable to [pip-tools](https://pip-tools.readthedocs.io/en/latest/) is still implemented. In short:
  * `pyproject.toml` contains a list of prerequisites (`project.dependencies` and/or `project.optional-dependencies`).
  * `pyproject.toml` fixes the Python version to a patch release (e.g. 3.13.1).
  * `uv venv` creates a virtual environment (comparable to `python -m venv`).
  * `uv pip compile` is used to pin package versions in `requirements.txt` and/or `dev-requirements.txt` (comparable to `pip-compile`).
  * `uv pip sync` keeps the virtual environment in sync with the pinned versions either in `requirements.txt` or `dev-requirements.txt` (comparable to `pip-sync`).

Note: things like `.python-version` or `uv.lock` are not used. If you have a previously created `requirements.txt` you can still do a `pip install -r requirements.txt`.

## make
Templates 'abuse' `make` for managing the virtual environment and/or building an executable. In case you need `make` for Windows: use [GnuWin](http://gnuwin32.sourceforge.net/). You can either install the entire set or just [make](http://gnuwin32.sourceforge.net/packages/make.htm). In fact, you only need these files (unpack from the zips and put them somewhere in your path):
  * [Binaries](http://gnuwin32.sourceforge.net/downlinks/make-bin-zip.php) zip:
      * `bin/make.exe`
  * [Dependencies](http://gnuwin32.sourceforge.net/downlinks/make-dep-zip.php) zip:
      * `bin/libiconv2.dll`
      * `bin/libintl3.dll`

 For documentation: the [Documentation](http://gnuwin32.sourceforge.net/downlinks/make-doc-zip.php) zip contains an excellent `make.pdf` with everything you ever want to know about `make`.

Please note: in a `makefile` a `<TAB>` has a different meaning than one or more `<SPACE>`s:
   * Commands must be preceded by `<TAB>`s
   * `make` directives can be indented by `<SPACE>`s.

You can use this to visually align a `make` directive like `ifeq` with commands.
