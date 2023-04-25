#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Basic setup.py for {{ cookiecutter.package_name }}

Build steps:
  1) Update version in {{ cookiecutter.package_name }}.__init__.__version__.
  2) Run 'make' or 'make build', the result will be a wheel (.whl) file in the 'dist' directory.
  3) If all goes well, commit to the repository and tag new version.
"""
from setuptools import find_packages, setup
from {{ cookiecutter.package_name }} import __version__


def get_requirements(requirements_file):
    """Get requirements from a requirements.txt file"""
    requirements = []
    with open(requirements_file, encoding="utf-8") as fh_in:
        for line in fh_in:
            if (hash_pos := line.find("#")) > -1:
                line = line[:hash_pos]
            line = line.strip()
            if line:
                requirements.append(line)
    return sorted(requirements, key=str.upper)


with open("README.md", encoding="utf-8") as f:
    readme = f.read()

with open("LICENSE", encoding="utf-8") as f:
    package_license = f.read()


setup(
    name="{{ cookiecutter.package_name }}",
    version=__version__,
    author="{{ cookiecutter.copyright_author }}",
    author_email="{{ cookiecutter.author_email }}",
    description="{{ cookiecutter.package_description }}",
    long_description=readme,
    license=package_license,
    install_requires=get_requirements("requirements.in"),
    packages=find_packages(exclude=("tests", "tests.*")),
    classifiers=[
        "Development Status :: 1 - Planning",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.11",
        "License :: OSI Approved :: MIT License",
        "Operating System :: Microsoft :: Windows",
    ],
)
