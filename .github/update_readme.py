#!/usr/bin/env python
import os
import os.path
import re
from typing import List

HERE = os.path.dirname(__file__)
ROOT = os.path.abspath(os.path.join(HERE, os.path.pardir))
README = os.path.join(ROOT, "README.md")


def replace_section(file: str, start_pat: str, end_pat: str, lines: List[str]) -> None:
    prefix_lines: List[str] = []
    postfix_lines: List[str] = []
    file_lines = prefix_lines
    found_section = False
    with open(file, "r", encoding="utf-8") as ifile:
        inside_section = False
        for line in ifile:
            if inside_section:
                if re.match(end_pat, line):
                    inside_section = False
                    file_lines = postfix_lines
                    file_lines.append(line)
            else:
                if re.match(start_pat, line):
                    inside_section = True
                    found_section = True
                file_lines.append(line)

    if inside_section or not found_section:
        raise Exception(f"could not find file section {start_pat}")

    all_lines = prefix_lines + lines + postfix_lines
    with open(file, "w", encoding="utf-8") as ofile:
        ofile.write("".join(all_lines))


def update_treesitter_languages():
    languages = sorted(os.listdir(os.path.join(ROOT, "queries")))
    language_lines = ["\n"] + [f"  * {l}\n" for l in languages] + ["\n"]
    replace_section(
        README, r"^\s*<summary>Supported languages", r"^[^\s]", language_lines
    )


def update_config_options():
    opt_lines = ["\n", "```lua\n", "vim.g.aerial = {\n"]
    with open(
        os.path.join(ROOT, "lua", "aerial", "config.lua"), "r", encoding="utf-8"
    ) as ifile:
        copying = False
        for line in ifile:
            if copying:
                if re.match(r"^}$", line):
                    break
                opt_lines.append(line)
            elif re.match(r"^\s*local default_options =", line):
                copying = True
    replace_section(README, r"^## Options", r"^}$", opt_lines)


def main() -> None:
    """Update the README"""
    update_treesitter_languages()
    update_config_options()


if __name__ == "__main__":
    main()
