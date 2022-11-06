"""Create version info file"""
import datetime as dt
import re
import os.path
import textwrap
import time

import click

__version__ = "2020.3.27"

# constants
COMPANY = "My Company"
COPYRIGHT_YEARS = f"2020-{dt.datetime.now():%Y}"
VERSION_RESOURCE_FILENAME = "file_version_info.txt"


def _mk_version_tuple(version):
    """Create a version tuple as required by a version info file.

    Note: non-numeric parts of the version are stripped entirely and
          empty numbers are replaced by zero's (1..1 -> 1.0.1)

    Args:
        version: a version string, e.g. '1', '1.2', '1.2.3', '1.2.dev3'

    Returns:
        tuple with a cleaned up 3 digit version and a string with a
        4 digit version 'tuple', e.g.:
            '1'        -> ('1.0.0', '(1, 0, 0, 0)')
            '1.2'      -> ('1.2.0', '(1, 2, 0, 0)')
            '1.2.3'    -> ('1.2.3', '(1, 2, 3, 0)')
            '1.2.dev3' -> ('1.2.3', '(1, 2, 3, 0)')
            '1.2.3.4'  -> ('1.2.3', '(1, 2, 3, 4)')
            '1..3.4'   -> ('1.0.3', '(1, 0, 3, 4)')
    """
    version = [re.sub("[^0-9]", "", n) for n in version.split(".")[:4]]
    version = [int(n) if n else 0 for n in version]
    if len(version) < 4:
        version.extend([0] * (4 - len(version)))
    version_text = ".".join([str(n) for n in version[:3]])
    version_tuple = ", ".join([str(n) for n in version])
    return version_text, f"({version_tuple})"


def create_version_resource_file(product, version, company, copyright_years):
    """Create a Windows Version Resource File.

    The Version Info File is usable for `pyi-set_version` contained in
    the `pyinstaller` package (`pyi-set_version` can be used to add
    Windows Version information to an executable).

    See also:
        http://pyinstaller.readthedocs.io/en/stable/usage.html#capturing-windows-version-data
        http://msdn.microsoft.com/en-us/library/ms646997.aspx

    Args:
        product:         name of the product (str)
        version:         version of the product (str), e.g. '1.2.3'
        company:         company name (str), e.g. 'My Company'
        copyright_years: years part of copyright (str), e.g. '2018', '2016-2018', etc.

    Returns:
        string with embedded newlines which can be used as a Version
        Resource File
    """
    template = textwrap.dedent(
        """\
        # UTF-8
        #
        # For more details about fixed file info 'ffi' see:
        # http://msdn.microsoft.com/en-us/library/ms646997.aspx
        VSVersionInfo(
          ffi=FixedFileInfo(
            # filevers and prodvers should be always a tuple with four items: (1, 2, 3, 4)
            # Set not needed items to zero 0.
            filevers={filevers_tuple},
            prodvers={prodvers_tuple},
            # Contains a bitmask that specifies the valid bits 'flags'r
            mask=0x3f,
            # Contains a bitmask that specifies the Boolean attributes of the file.
            flags=0x0,
            # The operating system for which this file was designed.
            # 0x4 - NT and there is no need to change it.
            OS=0x4,
            # The general type of file.
            # 0x1 - the file is an application.
            fileType=0x1,
            # The function of the file.
            # 0x0 - the function is not defined for this fileType
            subtype=0x0,
            # Creation date and time stamp.
            date=(0, 0)
            ),
          kids=[
            StringFileInfo(
              [
              StringTable(
                u'000004b0',
                [StringStruct(u'CompanyName', u'{company}'),
                StringStruct(u'FileDescription', u'{product}'),
                StringStruct(u'FileVersion', u'{filevers}'),
                StringStruct(u'InternalName', u'{product}'),
                StringStruct(u'LegalCopyright', u'Copyright © {copyright_years} {company}'),
                StringStruct(u'OriginalFilename', u'{product}.exe'),
                StringStruct(u'ProductName', u'{product}'),
                StringStruct(u'ProductVersion', u'{prodvers}')])
              ]),
            VarFileInfo([VarStruct(u'Translation', [0, 1200])])
          ]
        )
    """
    )

    # add the current time to the file version
    prodvers, prodvers_tuple = _mk_version_tuple(version)
    now = time.localtime()
    filevers = f"{prodvers}.{now.tm_hour:02d}{now.tm_min:02d}"
    _, filevers_tuple = _mk_version_tuple(filevers)

    return template.format(
        filevers_tuple=filevers_tuple,
        prodvers_tuple=prodvers_tuple,
        company=company.strip(),
        product=product.strip(),
        filevers=filevers.strip(),
        prodvers=prodvers.strip(),
        copyright_years=copyright_years.strip(),
    )


@click.command()
@click.argument("py_script")
@click.option("--company", default=COMPANY, help=f"company for Version Resource (default: '{COMPANY}'")
@click.option(
    "--copyright_years",
    default=COPYRIGHT_YEARS,
    help=f"years for the copyright statement (default: '{COPYRIGHT_YEARS}'",
)
@click.option(
    "-o",
    "--out",
    default=VERSION_RESOURCE_FILENAME,
    help=f"name of the Version Resource file (default: '{VERSION_RESOURCE_FILENAME}')",
)
@click.version_option(version=__version__, message=f"%(prog)s V%(version)s")
def click_main(py_script, company, copyright_years, out):
    """Create a Version Resource file for 'pyi-set_version' (pyinstaller).

    PY_SCRIPT: name of the script for which to create a Version Resource file
    """
    # read the version from the python script
    re_version = re.compile(r"^\s*__version__\s*\=\s*(\'|\")(?P<version>[^.]+\.[^.]+\.[^.]+)(\'|\")")
    version = None
    with open(py_script) as fh_in:
        for line in fh_in:
            match = re_version.match(line)
            if match:
                version = match.group("version")
                break
    if version is None:
        click.echo(f"ERROR: could not get '__version__' from '{py_script}'")
        raise click.Abort()

    # determine product
    product = os.path.splitext(os.path.split(py_script)[-1])[0]

    # create version resource file
    version_resource_file = create_version_resource_file(product, version, company, copyright_years)
    with open(out, "w", encoding="UTF-8") as fh_out:
        fh_out.write(version_resource_file)
    click.echo(f"Version Resource File written as '{out}'.")


if __name__ == "__main__":
    # pylint: disable=no-value-for-parameter
    click_main()
