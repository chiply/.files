#!/usr/bin/env python3
"""
Configuration validator for Open Source Watch Generator
"""

import jsonschema
import sys
import click

class WatchConfigValidator:
    def __init__(self, config):
        self.config = config
        
        # Define the schema for validation
        self.schema = {
            "type": "object",
            "required": ["watch_config"],
            "properties": {
                "watch_config": {
                    "type": "object",
                    "required": ["metadata", "case", "movement", "dial", "hands", "crystal"],
                    "properties": {
                        "metadata": {
                            "type": "object",
                            "required": ["name", "version"],
                            "properties": {
                                "name": {"type": "string"},
                                "designer": {"type": "string"},
                                "version": {"type": "string"}
                            }
                        },
                        "case": {
                            "type": "object",
                            "required": ["diameter", "thickness", "lug_width"],
                            "properties": {
                                "diameter": {"type": "number", "minimum": 20, "maximum": 60},
                                "thickness": {"type": "number", "minimum": 5, "maximum": 25},
                                "lug_width": {"type": "number", "minimum": 10, "maximum": 30},
                                "lug_to_lug": {"type": "number", "minimum": 30, "maximum": 80},
                                "crown_position": {"type": "integer", "minimum": 1, "maximum": 12},
                                "crown_diameter": {"type": "number", "minimum": 3, "maximum": 10}
                            }
                        },
                        "movement": {
                            "type": "object",
                            "required": ["type", "diameter", "thickness"],
                            "properties": {
                                "type": {"type": "string", "enum": ["quartz", "mechanical", "automatic"]},
                                "diameter": {"type": "number", "minimum": 15, "maximum": 40},
                                "thickness": {"type": "number", "minimum": 2, "maximum": 15},
                                "brand": {"type": "string"},
                                "model": {"type": "string"}
                            }
                        },
                        "dial": {
                            "type": "object",
                            "required": ["diameter", "markers"],
                            "properties": {
                                "diameter": {"type": "number", "minimum": 15, "maximum": 50},
                                "thickness": {"type": "number", "minimum": 0.5, "maximum": 3},
                                "markers": {"type": "string", "enum": ["indices", "numerals", "dots", "batons"]},
                                "color": {"type": "string"}
                            }
                        },
                        "hands": {
                            "type": "object",
                            "required": ["style", "hour_length", "minute_length"],
                            "properties": {
                                "style": {"type": "string", "enum": ["sword", "baton", "arrow", "mercedes"]},
                                "hour_length": {"type": "number", "minimum": 5, "maximum": 25},
                                "minute_length": {"type": "number", "minimum": 8, "maximum": 30},
                                "second_hand": {"type": "boolean"},
                                "second_length": {"type": "number", "minimum": 10, "maximum": 35}
                            }
                        },
                        "crystal": {
                            "type": "object",
                            "required": ["diameter", "thickness", "type"],
                            "properties": {
                                "diameter": {"type": "number", "minimum": 20, "maximum": 55},
                                "thickness": {"type": "number", "minimum": 1, "maximum": 5},
                                "type": {"type": "string", "enum": ["mineral", "sapphire", "acrylic"]}
                            }
                        }
                    }
                }
            }
        }
    
    def validate(self):
        """Validate the configuration against the schema"""
        try:
            jsonschema.validate(self.config, self.schema)
            self._validate_dimensional_constraints()
            return True
        except jsonschema.ValidationError as e:
            click.echo(f"Configuration validation error: {e.message}")
            sys.exit(1)
        except Exception as e:
            click.echo(f"Validation error: {e}")
            sys.exit(1)
    
    def _validate_dimensional_constraints(self):
        """Additional validation for dimensional relationships"""
        config = self.config['watch_config']
        
        # Check that movement fits in case
        case_diameter = config['case']['diameter']
        movement_diameter = config['movement']['diameter']
        
        if movement_diameter >= case_diameter - 4:
            raise ValueError(f"Movement diameter ({movement_diameter}mm) too large for case diameter ({case_diameter}mm)")
        
        # Check that dial fits between movement and case
        dial_diameter = config['dial']['diameter']
        if dial_diameter >= case_diameter - 2:
            raise ValueError(f"Dial diameter ({dial_diameter}mm) too large for case diameter ({case_diameter}mm)")
        
        if dial_diameter <= movement_diameter:
            raise ValueError(f"Dial diameter ({dial_diameter}mm) must be larger than movement diameter ({movement_diameter}mm)")
        
        # Check crystal size
        crystal_diameter = config['crystal']['diameter']
        if crystal_diameter >= case_diameter:
            raise ValueError(f"Crystal diameter ({crystal_diameter}mm) too large for case diameter ({case_diameter}mm)")
        
        # Check hand lengths don't exceed dial radius
        dial_radius = dial_diameter / 2
        if config['hands']['hour_length'] >= dial_radius:
            raise ValueError(f"Hour hand too long for dial size")
        
        if config['hands']['minute_length'] >= dial_radius:
            raise ValueError(f"Minute hand too long for dial size")
        
        if config['hands'].get('second_hand') and config['hands']['second_length'] >= dial_radius:
            raise ValueError(f"Second hand too long for dial size")
        
        click.echo("✓ Configuration validation passed")

def main():
    """Standalone validator for testing"""
    import yaml
    
    if len(sys.argv) != 2:
        click.echo("Usage: python validator.py <config_file>")
        sys.exit(1)
    
    config_file = sys.argv[1]
    
    try:
        with open(config_file, 'r') as f:
            config = yaml.safe_load(f)
        
        validator = WatchConfigValidator(config)
        validator.validate()
        
        click.echo("Configuration is valid!")
        
    except Exception as e:
        click.echo(f"Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
