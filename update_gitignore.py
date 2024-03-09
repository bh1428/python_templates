#!/usr/bin/env python3
"""Update all .gitignore's in the templates."""

import pathlib as pl

import jinja2
import requests

__version__ = "2022.10.20"

template_file = "dot_gitignore.jinja2"

sources = {
    "python_gitignore": "https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore",
    "vscode_gitignore": "https://raw.githubusercontent.com/github/gitignore/main/Global/VisualStudioCode.gitignore",
}

targets = {
    pl.Path("windows_qt") / "{{cookiecutter.repo_name}}" / ".gitignore",
    pl.Path("windows_standalone_exe") / "{{cookiecutter.repo_name}}" / ".gitignore",
    pl.Path("vscode") / "{{cookiecutter.repo_name}}" / ".gitignore",
    pl.Path("windows_package") / "{{cookiecutter.repo_name}}" / ".gitignore",
}

# get .gitignore from the source and build template config
config = {}
for source in sources:
    source_url = sources[source]
    print(f"Fetching {source}: '{source_url}'... ", end="")
    config[f"{source}_url"] = source_url
    content = requests.get(source_url)
    content.raise_for_status()
    config[f"{source}"] = content.text
    print("done")

# render the template
print(f"Rendering template (creating .gitignore content)... ", end="")
jinja2_loader = jinja2.FileSystemLoader(searchpath="./")
jinja2_env = jinja2.Environment(loader=jinja2_loader)
template = jinja2_env.get_template(template_file)
dot_gitignore = template.render(config=config)
print(f"done")

# update .gitignore files
for target in targets:
    with open(target, "w", encoding="utf-8") as fh_out:
        print(f"Writing: '{target}'... ", end="")
        fh_out.write(dot_gitignore)
        print("done")
