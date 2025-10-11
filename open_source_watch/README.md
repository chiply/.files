# Open Source Watch Generator

A parametric 3D-printed watch system that generates STL files from YAML configuration.

## Features

- YAML-based watch configuration
- Parametric case, dial, and hands generation
- Multiple movement support
- 3D printer optimized designs
- Assembly instructions generation

## Quick Start

1. Install dependencies:
   ```bash
   make dev-install
   ```

2. Configure your watch in `config/watch_config.yaml`

3. Generate the watch:
   ```bash
   poetry run python src/generator.py config/watch_config.yaml
   ```

4. Print the generated STL files in `output/generated_models/`

## Project Structure

- `config/` - YAML configuration files
- `templates/` - OpenSCAD template files
- `src/` - Python generation scripts
- `parts_library/` - Component specifications
- `output/` - Generated 3D models
- `examples/` - Example configurations

## Requirements

- Python 3.11+
- OpenSCAD
- 3D Printer (FDM or Resin)

## License

MIT License - See LICENSE file
