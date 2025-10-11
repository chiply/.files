#!/usr/bin/env python3
"""
Open Source Watch Generator
Main script to generate 3D printable watch components from YAML configuration
"""

import yaml
import jinja2
import subprocess
import os
import sys
import click
from pathlib import Path
from validator import WatchConfigValidator

class WatchGenerator:
    def __init__(self, config_path, output_dir="output/generated_models"):
        """Initialize the watch generator with configuration"""
        self.config_path = Path(config_path)
        self.output_dir = Path(output_dir)
        self.templates_dir = Path("templates")
        
        # Load and validate configuration
        self.config = self.load_config()
        self.validator = WatchConfigValidator(self.config)
        self.validator.validate()
        
        # Setup Jinja2 environment
        self.jinja_env = jinja2.Environment(
            loader=jinja2.FileSystemLoader(self.templates_dir),
            trim_blocks=True,
            lstrip_blocks=True
        )
        
        # Ensure output directory exists
        self.output_dir.mkdir(parents=True, exist_ok=True)
    
    def load_config(self):
        """Load YAML configuration file"""
        try:
            with open(self.config_path, 'r') as f:
                return yaml.safe_load(f)
        except FileNotFoundError:
            click.echo(f"Error: Configuration file {self.config_path} not found")
            sys.exit(1)
        except yaml.YAMLError as e:
            click.echo(f"Error parsing YAML: {e}")
            sys.exit(1)
    
    def generate_scad_file(self, template_name, output_name):
        """Generate OpenSCAD file from template"""
        try:
            template = self.jinja_env.get_template(template_name)
            scad_content = template.render(config=self.config['watch_config'])
            
            output_path = self.output_dir / f"{output_name}.scad"
            with open(output_path, 'w') as f:
                f.write(scad_content)
            
            click.echo(f"Generated {output_path}")
            return output_path
        except Exception as e:
            click.echo(f"Error generating {template_name}: {e}")
            return None
    
    def generate_stl_file(self, scad_path):
        """Convert OpenSCAD file to STL using OpenSCAD CLI"""
        if not scad_path:
            return None
            
        stl_path = scad_path.with_suffix('.stl')
        
        try:
            # Check if OpenSCAD is available
            subprocess.run(['openscad', '--version'], 
                         capture_output=True, check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            click.echo("Warning: OpenSCAD not found. Only .scad files will be generated.")
            click.echo("Install OpenSCAD to generate STL files automatically.")
            return None
        
        try:
            # Generate STL file
            cmd = [
                'openscad',
                '--export-format=binstl',
                '-o', str(stl_path),
                str(scad_path)
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                click.echo(f"Generated {stl_path}")
                return stl_path
            else:
                click.echo(f"Error generating STL: {result.stderr}")
                return None
                
        except Exception as e:
            click.echo(f"Error running OpenSCAD: {e}")
            return None
    
    def generate_all_components(self):
        """Generate all watch components"""
        components = [
            ('case.scad.j2', 'case'),
            ('dial.scad.j2', 'dial'),
            ('hands.scad.j2', 'hands'),
            ('case_back.scad.j2', 'case_back')
        ]
        
        generated_files = []
        
        click.echo(f"Generating watch: {self.config['watch_config']['metadata']['name']}")
        click.echo("=" * 50)
        
        for template, component in components:
            click.echo(f"Generating {component}...")
            scad_file = self.generate_scad_file(template, component)
            
            if scad_file:
                generated_files.append(scad_file)
                # Try to generate STL
                stl_file = self.generate_stl_file(scad_file)
                if stl_file:
                    generated_files.append(stl_file)
        
        # Generate assembly instructions
        self.generate_assembly_guide()
        
        # Generate parts list
        self.generate_parts_list()
        
        click.echo("=" * 50)
        click.echo(f"Generation complete! Files saved to: {self.output_dir}")
        return generated_files
    
    def generate_assembly_guide(self):
        """Generate assembly instructions"""
        guide_content = f"""# Assembly Guide: {self.config['watch_config']['metadata']['name']}

## Required Components

### 3D Printed Parts:
- case.stl (Main watch case)
- dial.stl (Watch face)
- hands.stl (Hour, minute, second hands)
- case_back.stl (Case back)

### Purchased Parts:
- Movement: {self.config['watch_config']['movement']['brand']} {self.config['watch_config']['movement']['model']}
- Crystal: {self.config['watch_config']['crystal']['diameter']}mm {self.config['watch_config']['crystal']['type']}
- Crown: {self.config['watch_config']['case']['crown_diameter']}mm
- Spring bars: {self.config['watch_config']['strap']['lug_width']}mm
- Watch strap: {self.config['watch_config']['strap']['lug_width']}mm

## Assembly Steps:

1. **Prepare the case**: Clean all 3D printed parts, remove supports
2. **Install movement**: Press-fit movement into case cavity
3. **Mount dial**: Align dial feet with movement, secure carefully
4. **Install hands**: Mount hour hand first, then minute, then second
5. **Install crystal**: Press crystal into case bezel
6. **Close case**: Thread case back into position
7. **Install crown**: Screw crown onto movement stem
8. **Attach strap**: Install spring bars and attach strap

## Tools Required:
- Small screwdrivers
- Case opener tool
- Hand setting tools
- Crystal press (or careful manual pressure)

## Notes:
- Handle movement with care
- Ensure hands don't touch dial or each other
- Test crown function before final assembly
"""
        
        guide_path = self.output_dir / "assembly_guide.md"
        with open(guide_path, 'w') as f:
            f.write(guide_content)
        
        click.echo(f"Generated assembly guide: {guide_path}")
    
    def generate_parts_list(self):
        """Generate parts and materials list"""
        config = self.config['watch_config']
        
        parts_content = f"""# Parts List: {config['metadata']['name']}

## 3D Printing Materials:
- Case: {config['materials']['case']}
- Dial: {config['materials']['dial']}
- Hands: {config['materials']['hands']}

## Print Settings:
- Layer Height: {config['print_settings']['layer_height']}mm
- Infill: {config['print_settings']['infill']}%
- Supports: {'Required' if config['print_settings']['supports'] else 'Not required'}

## Components to Purchase:
- Movement: {config['movement']['brand']} {config['movement']['model']}
- Crystal: {config['crystal']['diameter']}mm {config['crystal']['type']}
- Crown: {config['case']['crown_diameter']}mm diameter
- Spring bars: {config['strap']['lug_width']}mm width
- Watch strap: {config['strap']['lug_width']}mm lug width

## Estimated Costs:
- Movement: $10-30
- Crystal: $5-15
- Crown: $3-8
- Spring bars: $2-5
- Strap: $10-50
- Filament: $2-5

Total estimated cost: $32-113 (excluding 3D printing time)
"""
        
        parts_path = self.output_dir / "parts_list.md"
        with open(parts_path, 'w') as f:
            f.write(parts_content)
        
        click.echo(f"Generated parts list: {parts_path}")

@click.command()
@click.argument('config_file', type=click.Path(exists=True))
@click.option('--output', '-o', default='output/generated_models', 
              help='Output directory for generated files')
@click.option('--stl-only', is_flag=True, help='Generate only STL files (skip SCAD)')
def main(config_file, output, stl_only):
    """Generate 3D printable watch components from YAML configuration"""
    
    # Change to script directory to ensure relative paths work
    os.chdir(Path(__file__).parent.parent)
    
    try:
        generator = WatchGenerator(config_file, output)
        generated_files = generator.generate_all_components()
        
        if generated_files:
            click.echo("\nGenerated files:")
            for file_path in generated_files:
                click.echo(f"  - {file_path}")
        else:
            click.echo("No files were generated successfully.")
            sys.exit(1)
            
    except Exception as e:
        click.echo(f"Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
