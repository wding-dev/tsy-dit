#!/usr/bin/env python3
"""
Script to convert Control-M XML job definitions to JSON format
"""

import os
import json
import xml.etree.ElementTree as ET
from pathlib import Path

def xml_to_dict(element):
    """Convert XML element to dictionary"""
    result = {}
    
    # Add element text if it exists and is not just whitespace
    if element.text and element.text.strip():
        result['text'] = element.text.strip()
    
    # Add attributes
    if element.attrib:
        result['attributes'] = element.attrib
    
    # Add child elements
    for child in element:
        child_data = xml_to_dict(child)
        
        if child.tag in result:
            # If tag already exists, convert to list
            if not isinstance(result[child.tag], list):
                result[child.tag] = [result[child.tag]]
            result[child.tag].append(child_data)
        else:
            result[child.tag] = child_data
    
    return result

def convert_controlm_xml_to_json(xml_file_path, json_file_path):
    """Convert a single Control-M XML file to JSON"""
    try:
        # Parse XML
        tree = ET.parse(xml_file_path)
        root = tree.getroot()
        
        # Convert to dictionary
        job_dict = xml_to_dict(root)
        
        # Create a more structured JSON format for Control-M jobs
        if root.tag == 'Job':
            structured_job = {
                'job_definition': {
                    'name': job_dict.get('JOBNAME', {}).get('text', ''),
                    'application': job_dict.get('APPLICATION', {}).get('text', ''),
                    'command': job_dict.get('COMMAND', {}).get('text', ''),
                    'node_id': job_dict.get('NODEID', {}).get('text', ''),
                    'time': job_dict.get('TIME', {}).get('text', ''),
                    'description': job_dict.get('DESCRIPTION', {}).get('text', '')
                },
                'original_xml_structure': job_dict
            }
        else:
            structured_job = job_dict
        
        # Write JSON file
        with open(json_file_path, 'w', encoding='utf-8') as json_file:
            json.dump(structured_job, json_file, indent=2, ensure_ascii=False)
        
        print(f"Converted: {xml_file_path} -> {json_file_path}")
        return True
        
    except Exception as e:
        print(f"Error converting {xml_file_path}: {str(e)}")
        return False

def main():
    """Main function to convert all Control-M XML files to JSON"""
    # Define paths
    controlm_dir = Path("controlm")
    
    if not controlm_dir.exists():
        print("Error: controlm directory not found")
        return
    
    # Find all XML files in controlm directory
    xml_files = list(controlm_dir.rglob("*.xml"))
    
    if not xml_files:
        print("No XML files found in controlm directory")
        return
    
    print(f"Found {len(xml_files)} XML files to convert")
    
    converted_count = 0
    
    # Convert each XML file to JSON
    for xml_file in xml_files:
        # Create corresponding JSON file path
        json_file = xml_file.with_suffix('.json')
        
        # Ensure the directory exists
        json_file.parent.mkdir(parents=True, exist_ok=True)
        
        # Convert the file
        if convert_controlm_xml_to_json(xml_file, json_file):
            converted_count += 1
    
    print(f"\nConversion complete: {converted_count}/{len(xml_files)} files converted successfully")

if __name__ == "__main__":
    main()