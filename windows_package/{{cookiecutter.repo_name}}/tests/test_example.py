#!/usr/bin/env python3
"""Example of a test for {{ cookiecutter.package_name }}"""

import unittest

import {{ cookiecutter.package_name }}

# pylint: disable=missing-class-docstring, missing-function-docstring
# pylint: disable=line-too-long,, too-many-lines, too-many-public-methods


class TestExample(unittest.TestCase):
    def test0010_version(self):
        self.assertEqual({{ cookiecutter.package_name }}.__version__, "{{ cookiecutter.package_version }}")


if __name__ == "__main__":
    unittest.main()  # pragma: no cover
