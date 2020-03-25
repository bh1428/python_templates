# Python Templates for Windows projects

## Templates
This repository contains templates for Python development projects (on Windows):
  * __windows_standalone_exe__: standalone (Windows) executable using venv (pip-tools), VSCode, make and pyinstaller (with a working example how the combination of `click`, `logging` (both to file and console) and `pyinstaller` can be used)
  * __windows_vsc__: basic (Windows) VSCode template using venv (pip-tools), VSCode and make

The templates are based on a [pip-tools](https://pypi.org/project/pip-tools/) work flow with a defined Python version.

## make
Templates 'abuse' `make` for managing the virtual environment and/or building an executable. In case you need `make` for Windows: use [GnuWin](http://gnuwin32.sourceforge.net/). You can either install the entire set or just [make](http://gnuwin32.sourceforge.net/packages/make.htm). In fact, you only need these files (unpack form the zips and put them somewhere in your path):
  * From the [Binaries](http://gnuwin32.sourceforge.net/downlinks/make-bin-zip.php) zip:
      * `bin/make.exe`
  * From the [Dependencies](http://gnuwin32.sourceforge.net/downlinks/make-dep-zip.php) zip:
      * `bin/libiconv2.dll`
      * `bin/libintl3.dll`

 For documentation: the [Documentation](http://gnuwin32.sourceforge.net/downlinks/make-doc-zip.php) zip contains an excellent `make.pdf` with everything you ever want to know about `make`.

Please note: in a `makefile` a `<TAB>` has a different meaning than one or more `<SPACE>`s:
   * Commands must be preceded by `<TAB>`s
   * `make` directives can be indented by `<SPACE>`s.

You can use this to visually align a `make` directive like `ifeq` with commands.
