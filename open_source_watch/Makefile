# Open Source Watch Generator Makefile

.PHONY: install clean test generate example help

# Default target
help:
	@echo "Open Source Watch Generator"
	@echo "Available targets:"
	@echo "  install    - Install Python dependencies"
	@echo "  generate   - Generate watch from default config"
	@echo "  example    - Generate example watches"
	@echo "  clean      - Clean generated files"
	@echo "  test       - Run tests"
	@echo "  validate   - Validate default configuration"

install:
	poetry install --no-root

generate:
	poetry run python src/generator.py config/watch_config.yaml

example:
	poetry run jpython src/generator.py examples/diver_watch.yaml -o output/diver_watch
	poetry run jpython src/generator.py examples/dress_watch.yaml -o output/dress_watch

validate:
	poetry run python src/validator.py config/watch_config.yaml

clean:
	rm -rf output/generated_models/*
	rm -rf output/diver_watch/*
	rm -rf output/dress_watch/*
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -delete

test:
	poetry run pytest tests/ -v

# Development targets
dev-install:
	poetry install --no-root
	poetry run pip install --upgrade python-lsp-server debugpy ipython ruff pytest black flake8

format:
	poetry run black src/

lint:
	poetry run flake8 src/

setup-openscad:
	@echo "Please install OpenSCAD:"
	@echo "  Ubuntu/Debian: sudo apt install openscad"
	@echo "  macOS: brew install openscad"
	@echo "  Windows: Download from https://openscad.org/"
