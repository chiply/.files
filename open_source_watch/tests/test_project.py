#!/usr/bin/env python3
"""
Simple test script to verify the Open Source Watch Generator works
"""

import os
import sys
import subprocess
from pathlib import Path

def test_validation():
    """Test configuration validation"""
    print("Testing configuration validation...")
    result = subprocess.run([
        sys.executable, 'src/validator.py', 'config/watch_config.yaml'
    ], capture_output=True, text=True)
    
    if result.returncode == 0:
        print("✓ Configuration validation passed")
        return True
    else:
        print(f"✗ Configuration validation failed: {result.stderr}")
        return False

def test_generation():
    """Test OpenSCAD file generation"""
    print("Testing watch generation...")
    result = subprocess.run([
        sys.executable, 'src/generator.py', 'config/watch_config.yaml'
    ], capture_output=True, text=True)
    
    if result.returncode == 0:
        print("✓ Watch generation completed")
        
        # Check if files were created
        output_dir = Path('output/generated_models')
        expected_files = ['case.scad', 'dial.scad', 'hands.scad', 'case_back.scad']
        
        all_files_exist = True
        for filename in expected_files:
            filepath = output_dir / filename
            if filepath.exists():
                print(f"✓ Generated {filename}")
            else:
                print(f"✗ Missing {filename}")
                all_files_exist = False
        
        return all_files_exist
    else:
        print(f"✗ Watch generation failed: {result.stderr}")
        return False

def test_examples():
    """Test example configurations"""
    print("Testing example configurations...")
    examples = ['examples/diver_watch.yaml', 'examples/dress_watch.yaml']
    
    for example in examples:
        print(f"Testing {example}...")
        result = subprocess.run([
            sys.executable, 'src/validator.py', example
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"✓ {example} validation passed")
        else:
            print(f"✗ {example} validation failed")
            return False
    
    return True

def main():
    print("Open Source Watch Generator Test Suite")
    print("=" * 50)
    
    # Change to project directory
    os.chdir(Path(__file__).parent)
    
    tests = [
        ("Configuration Validation", test_validation),
        ("Watch Generation", test_generation),
        ("Example Configurations", test_examples)
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n{test_name}:")
        print("-" * 30)
        if test_func():
            passed += 1
            print(f"✓ {test_name} PASSED")
        else:
            print(f"✗ {test_name} FAILED")
    
    print("\n" + "=" * 50)
    print(f"Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! The watch generator is working correctly.")
        return 0
    else:
        print("❌ Some tests failed. Check the output above for details.")
        return 1

if __name__ == '__main__':
    sys.exit(main())
