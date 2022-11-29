---
name: Feature request (treesitter language)
about: Request support for treesitter backend for a new language
title: ''
labels: enhancement
assignees: stevearc

---

**Language**: [your language here]

Please provide a minimal file in your language that includes all of the language constructs that you would like to see listed by aerial. Here is an example for lua: [lua_test.lua](https://github.com/stevearc/aerial.nvim/blob/master/tests/treesitter/lua_test.lua). Examples for other languages are in the same directory.

```
[minimal code here]
```

If it is not obvious how each of the language constructs should map to a [LSP SymbolKind](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind), please specify which SymbolKind to use for each of them.
