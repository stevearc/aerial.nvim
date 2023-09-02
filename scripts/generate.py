import os
import os.path
import re
from functools import lru_cache
from typing import List

from nvim_doc_tools import (
    Command,
    Vimdoc,
    VimdocSection,
    commands_from_json,
    format_md_commands,
    format_vimdoc_commands,
    generate_md_toc,
    indent,
    parse_functions,
    read_nvim_json,
    read_section,
    render_md_api,
    render_vimdoc_api,
    replace_section,
)

HERE = os.path.dirname(__file__)
ROOT = os.path.abspath(os.path.join(HERE, os.path.pardir))
README = os.path.join(ROOT, "README.md")
DOC = os.path.join(ROOT, "doc")
VIMDOC = os.path.join(DOC, "aerial.txt")


def update_treesitter_languages():
    languages = sorted(os.listdir(os.path.join(ROOT, "queries")))
    language_lines = ["\n"] + [f"- {l}\n" for l in languages] + ["\n"]
    replace_section(
        README,
        r"^\s*<summary>Supported treesitter languages",
        r"^[^\s\-]",
        language_lines,
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
        VIMDOC, r'^\s*require\("aerial"\)\.setup', r"^\s*}\)$", indent(opt_lines, 4)
    )


def add_md_link_path(path: str, lines: List[str]) -> List[str]:
    ret = []
    for line in lines:
        ret.append(re.sub(r"(\(#)", "(" + path + "#", line))
    return ret


def update_md_api():
    funcs = parse_functions(os.path.join(ROOT, "lua", "aerial", "init.lua"))
    lines = ["\n"] + render_md_api(funcs, 2) + ["\n"]
    api_doc = os.path.join(DOC, "api.md")
    replace_section(
        api_doc,
        r"^<!-- API -->$",
        r"^<!-- /API -->$",
        lines,
    )
    toc = ["\n"] + generate_md_toc(api_doc) + ["\n"]
    replace_section(
        api_doc,
        r"^<!-- TOC -->$",
        r"^<!-- /TOC -->$",
        toc,
    )
    toc = add_md_link_path("doc/api.md", toc)
    replace_section(
        README,
        r"^<!-- API -->$",
        r"^<!-- /API -->$",
        toc,
    )


def update_readme_toc():
    toc = ["\n"] + generate_md_toc(README) + ["\n"]
    replace_section(
        README,
        r"^<!-- TOC -->$",
        r"^<!-- /TOC -->$",
        toc,
    )


@lru_cache
def get_commands() -> List[Command]:
    return commands_from_json(read_nvim_json('require("aerial").get_all_commands()'))


def update_md_commands():
    commands = get_commands()
    lines = ["\n"] + format_md_commands(commands) + ["\n"]
    replace_section(
        README,
        r"^## Commands",
        r"^#",
        lines,
    )


def get_options_vimdoc() -> "VimdocSection":
    section = VimdocSection("options", "aerial-options")
    config_file = os.path.join(ROOT, "lua", "aerial", "config.lua")
    opt_lines = read_section(config_file, r"^local default_options =", r"^}$")
    lines = ["\n", ">lua\n", '    require("aerial").setup({\n']
    lines.extend(indent(opt_lines, 4))
    lines.extend(["    })\n", "<\n"])
    section.body = lines
    return section


def get_commands_vimdoc() -> "VimdocSection":
    section = VimdocSection("Commands", "aerial-commands", ["\n"])
    commands = get_commands()
    section.body.extend(format_vimdoc_commands(commands))
    return section


def get_notes_vimdoc() -> "VimdocSection":
    section = VimdocSection("Notes", "aerial-notes")
    section.body.extend(read_section(VIMDOC, "^NOTES", r"^[=\-]"))
    return section


def generate_vimdoc():
    doc = Vimdoc("aerial.txt", "aerial")
    funcs = parse_functions(os.path.join(ROOT, "lua", "aerial", "init.lua"))
    doc.sections.extend(
        [
            get_options_vimdoc(),
            get_commands_vimdoc(),
            VimdocSection("API", "aerial-api", render_vimdoc_api("aerial", funcs)),
            get_notes_vimdoc(),
        ]
    )

    with open(VIMDOC, "w", encoding="utf-8") as ofile:
        ofile.writelines(doc.render())


def main() -> None:
    """Update the README"""
    update_treesitter_languages()
    update_config_options()
    update_md_commands()
    update_md_api()
    update_readme_toc()
    generate_vimdoc()
