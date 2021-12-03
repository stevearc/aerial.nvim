#!/usr/bin/env python
import json
import os
import os.path
import re
import subprocess
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


def read_section(filename: str, start_pat: str, end_pat: str) -> List[str]:
    lines = []
    with open(filename, "r", encoding="utf-8") as ifile:
        inside_section = False
        for line in ifile:
            if inside_section:
                if re.match(end_pat, line):
                    break
                lines.append(line)
            elif re.match(start_pat, line):
                inside_section = True
    return lines


def update_treesitter_languages():
    languages = sorted(os.listdir(os.path.join(ROOT, "queries")))
    language_lines = ["\n"] + [f"  * {l}\n" for l in languages] + ["\n"]
    replace_section(
        README, r"^\s*<summary>Supported languages", r"^[^\s]", language_lines
    )


def update_config_options():
    config_file = os.path.join(ROOT, "lua", "aerial", "config.lua")
    opt_lines = ["\n", "```lua\n", "vim.g.aerial = {\n"]
    opt_lines += read_section(config_file, r"^\s*local default_options =", r"^}$")
    replace_section(README, r"^## Options", r"^}$", opt_lines)


def update_default_bindings():
    code, txt = subprocess.getstatusoutput(
        """nvim --headless --noplugin -u /dev/null -c 'set runtimepath+=.' -c 'lua print(vim.json.encode(require("aerial.bindings").keys))' +qall"""
    )
    if code != 0:
        raise Exception(f"Error updating default bindings: {txt}")
    try:
        bindings = json.loads(txt)
    except json.JSONDecodeError as e:
        raise Exception(f"Json decode error: {txt}") from e
    lhs = ["---"]
    rhs = ["-------"]
    for keys, _command, desc in bindings:
        if not isinstance(keys, list):
            keys = [keys]
        lhs.append("/".join([f"`{key}`" for key in keys]))
        rhs.append(desc)
    max_lhs = max(map(len, lhs))
    lines = [
        left.ljust(max_lhs) + " | " + right + "\n" for left, right in zip(lhs, rhs)
    ]
    replace_section(README, r"^Key.*Command", r"^\s*$", lines)


def main() -> None:
    """Update the README"""
    update_treesitter_languages()
    update_config_options()
    update_default_bindings()


if __name__ == "__main__":
    main()
