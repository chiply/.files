# Getting Started with Open Source Watch Generator

## Prerequisites

1. **Python 3.8+** - Required for the generator scripts
2. **OpenSCAD** - Required to generate STL files from SCAD code
3. **3D Printer** - FDM or resin printer for creating parts

## Installation

1. Clone or download the project:
   ```bash
   cd ~/source_code/open_source_watch
   ```

2. Install Python dependencies:
   ```bash
   make install
   ```

3. Install OpenSCAD:
   - **Ubuntu/Debian**: `sudo apt install openscad`
   - **macOS**: `brew install openscad`
   - **Windows**: Download from https://openscad.org/

## Quick Start

1. **Generate your first watch**:
   ```bash
   make generate
   ```
   This creates files in `output/generated_models/`

2. **Try example configurations**:
   ```bash
   make example
   ```
   This generates dive watch and dress watch variants

3. **Customize your watch**:
   - Edit `config/watch_config.yaml`
   - Modify dimensions, materials, styles
   - Run `make generate` again

## Configuration Guide

### Basic Parameters

```yaml
case:
  diameter: 40.0    # Case diameter in mm
  thickness: 12.0   # Case thickness in mm
  lug_width: 20.0   # Strap width in mm

movement:
  type: "quartz"    # quartz, automatic, mechanical
  brand: "miyota"
  model: "2035"

dial:
  markers: "indices"  # indices, numerals, dots
  color: "black"
```

### Advanced Options

- **Materials**: Choose PLA, PETG, or Resin
- **Tolerances**: Adjust fit for your printer
- **Print Settings**: Layer height, infill, supports

## 3D Printing Guide

### Recommended Settings

**FDM Printers (Case/Dial)**:
- Material: PLA or PETG
- Layer Height: 0.2mm
- Infill: 20-30%
- Supports: Yes (for overhangs)

**Resin Printers (Hands)**:
- Material: Standard resin
- Layer Height: 0.05mm
- Exposure: Per resin specifications

### Print Orientation

- **Case**: Face up (dial opening up)
- **Dial**: Face up
- **Hands**: Flat on build plate
- **Case Back**: Face down

## Assembly

1. **Clean printed parts** - Remove supports, sand if needed
2. **Test fit movement** - Should slide in snugly
3. **Install dial** - Align with movement dial feet
4. **Mount hands** - Hour first, then minute, then second
5. **Install crystal** - Press fit carefully
6. **Close case** - Thread case back on
7. **Install crown** - Screw onto stem
8. **Add strap** - Use spring bars

## Troubleshooting

### Common Issues

**Movement doesn't fit**:
- Check `movement_fit` tolerance in config
- Increase value for looser fit

**Hands hit dial or each other**:
- Adjust hand lengths in configuration
- Check dial thickness setting

**Poor print quality**:
- Reduce layer height
- Increase infill percentage
- Check printer calibration

### Getting Help

1. Check the assembly guide: `output/generated_models/assembly_guide.md`
2. Review parts list: `output/generated_models/parts_list.md`
3. Validate configuration: `make validate`

## Next Steps

1. **Experiment with designs** - Try different case sizes, hand styles
2. **Create custom configurations** - Make your own YAML files
3. **Share your designs** - Contribute back to the project
4. **Advanced modifications** - Edit OpenSCAD templates directly

Happy watch building! 🕐
