# Python Templates for Windows projects

## Templates
This repository contains [Cookiecutter](https://cookiecutter.readthedocs.io/) templates for Python development projects (on Windows). All templates use a combination of make with [pip-tools](https://pypi.org/project/pip-tools/) to manage a virtual environment:
  * __windows_qt__: basic Qt / PySide2 application (using VSCode and QT Designer)
  * __windows_standalone_exe__: standalone (Windows) executable (with an example how the combination of `click`, `logging` (both to file and console) and `pyinstaller` can be used)
  * __windows_vsc__: basic VSCode template.

You can use the PowerShell script `cookiecutter.ps1` to create new projects from the templates:
  - Copy `cookiecutter.ps1` to your main project directory (projects will be created as sub-directories).
  - Adapt configuration in `cookiecutter.ps1`:
    * `COOKIECUTTER`: location of the `cookiecutter.exe` executable
    * `TEMPLATE_DIRS`: templates should be sub-directories of this folder
  - Run `cookiecutter.ps1` and use the menu to select the template

## Visual Studio Code
In case you want to use Visual Studio Code for Python development, the following set of extensions might be handy (in alphabetical order):
  * autoDocstring
  * Code Spell Checker
  * ctags
  * Git Graph
  * Git History
  * GitLens
  * Material Icon Theme
  * Pylance
  * Python
  * SQLite
  * Visual Studio IntelliCode
  * XML Tools

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
