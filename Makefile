.PHONY: install test clean help

help:
	@echo "GitNexus Stable Ops - Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make install    Install gni wrapper to ~/.local/bin"
	@echo "  make test       Run unit tests"
	@echo "  make clean      Remove temporary files"
	@echo "  make help       Show this help message"

install:
	@echo "Installing gni wrapper..."
	@mkdir -p $(HOME)/.local/bin
	@ln -sf $(PWD)/bin/gni $(HOME)/.local/bin/gni
	@chmod +x bin/*
	@chmod +x lib/parse_graph_meta.py
	@echo "✓ Installed gni to $(HOME)/.local/bin/gni"
	@echo "  Ensure $(HOME)/.local/bin is in your PATH"

test:
	@echo "Running tests..."
	@bash tests/test_common.sh

clean:
	@echo "Cleaning temporary files..."
	@rm -f /tmp/gitnexus-*.log
	@rm -f /tmp/graph-meta-update.log
	@echo "✓ Cleaned"
