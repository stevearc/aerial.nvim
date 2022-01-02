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
DOC = os.path.join(ROOT, "doc", "aerial.txt")


def indent(lines: List[str], amount: int) -> List[str]:
    ret = []
    for line in lines:
        if amount >= 0:
            ret.append(" " * amount + line)
        else:
            space = re.match(r"[ \t]+", line)
            if space:
                ret.append(line[min(abs(amount), space.span()[1]) :])
            else:
                ret.append(line)
    return ret


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
    language_lines = ["\n"] + [f"- {l}\n" for l in languages] + ["\n"]
    replace_section(
        README, r"^\s*<summary>Supported languages", r"^[^\s\-]", language_lines
    )


def update_config_options():
    config_file = os.path.join(ROOT, "lua", "aerial", "config.lua")
    opt_lines = read_section(config_file, r"^\s*local default_options =", r"^}$")
    replace_section(
        README,
        r"^\-\- Call the setup function",
        r"^}\)$",
        ['require("aerial").setup({\n'] + opt_lines,
    )
    replace_section(
        DOC, r'^\s*require\("aerial"\)\.setup', r"^\s*}\)$", indent(opt_lines, 4)
    )


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
    lhs = []
    rhs = []
    for keys, _command, desc in bindings:
        if not isinstance(keys, list):
            keys = [keys]
        lhs.append("/".join([f"`{key}`" for key in keys]))
        rhs.append(desc)
    max_lhs = max(map(len, lhs))
    max_rhs = max(map(len, rhs))
    lhs.insert(0, "-" * max_lhs)
    rhs.insert(0, "-" * max_rhs)
    lines = [
        "| " + left.ljust(max_lhs) + " | " + right.ljust(max_rhs) + " |\n"
        for left, right in zip(lhs, rhs)
    ]
    replace_section(README, r"^\|\s*Key.*Command", r"^\s*$", lines)


def main() -> None:
    """Update the README"""
    update_treesitter_languages()
    update_config_options()
    update_default_bindings()


if __name__ == "__main__":
    main()
