.PHONY: all doc test lint fastlint clean update_snapshots

all: doc lint test

# Regenerate documentation
doc: scripts/nvim_doc_tools
	python scripts/main.py generate

# Run the test suite
test:
	./run_tests.sh

# Update the symbols snapshot files
update_snapshots:
	./run_tests.sh --update

# Run all linters
lint: scripts/nvim-typecheck-action fastlint
	./scripts/nvim-typecheck-action/typecheck.sh --lib https://github.com/folke/snacks.nvim --workdir scripts/nvim-typecheck-action lua

# Run all the fast linters
fastlint: scripts/nvim_doc_tools
	python scripts/main.py lint
	luacheck lua tests --formatter plain
	stylua --check lua tests

scripts/nvim_doc_tools:
	git clone https://github.com/stevearc/nvim_doc_tools scripts/nvim_doc_tools

scripts/nvim-typecheck-action:
	git clone https://github.com/stevearc/nvim-typecheck-action scripts/nvim-typecheck-action

clean:
	rm -rf scripts/nvim_doc_tools scripts/nvim-typecheck-action .testenv
