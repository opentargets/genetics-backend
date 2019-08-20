#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Ed Mountjoy
#


import os
import sys
import json
import argparse
from glob import glob
from collections import OrderedDict
from pprint import pprint
import textwrap

def main():

    # Parse args
    global args
    args = parse_args()

    # Make output directory
    dirname = os.path.dirname(args.out_prefix)
    if dirname:
        os.makedirs(dirname, exist_ok=True)

    # Load file and field descriptions
    with open(args.in_desc, 'r') as inh:
        desc = json.load(inh)
    
    # Load BigQuery schemas, adding file and field descritions
    schemas, missing = load_bq_schemas(args.in_bq, desc)

    # Check for missing descriptions
    outpath = args.out_prefix + '.missing.json'
    check_missing(missing, outpath)

    # Write schemas to json
    outpath = args.out_prefix + '.json'
    with open(outpath, 'w') as outh:
        json.dump(schemas, outh, indent=2)
    
    # Write schemas as text
    outpath = args.out_prefix + '.txt'
    write_schema_to_text(schemas, outpath)

    return 0

def write_schema_to_text(schemas, outpath, width=80):
    ''' Prettify schemas to text file
    '''
    with open(outpath, 'w') as outh:
        for filename in schemas:

            # Write horizontal rule, filename and file description
            outh.write('-' * width + '\n')
            for line in textwrap.wrap('file: ' + filename, width-2):
                outh.write('' + line  + '\n')
                # outh.write('# ' + line  + '\n')
            file_desc = schemas[filename]['file_descrition']
            for line in textwrap.wrap('description: ' + file_desc, width-2):
                outh.write('' + line  + '\n')
                # outh.write('# ' + line  + '\n')
            
            # Write fields
            wrapper = textwrap.TextWrapper(
                initial_indent='- ',
                subsequent_indent='  '
            )
            for field_name, record in schemas[filename]['fields'].items():
                field_str = '{0} ({1}, {2}): {3}'.format(
                    field_name,
                    record['field_type'],
                    record['field_mode'],
                    record['field_description']
                )
                for line in wrapper.wrap(field_str):
                    outh.write(line  + '\n')

            outh.write('\n')
    
    return 0

def load_bq_schemas(in_pattern, desc):
    ''' Loads the BigQuery schemas for each file, adds file and field descriptions
    Args:
        in_pattern (str): glob pattern for BigQuery files
        desc (dict): dictionary of file and field descriptions
    Returns:
        ( schemas with descriptions, missing files and fields )
    '''
    schemas = {}
    missing = {
        'files': set([]),
        'fields': set([])
    }
    for inf in glob(in_pattern):
        
        # Get filename
        fn = os.path.basename(inf).split('.')[1]

        # Load fields from bq schema
        with open(inf, 'r') as inh:
            fields = json.load(inh, object_pairs_hook=OrderedDict)

        # Add file and description to output
        try:
            file_desc = desc['files'][fn]
        except KeyError:
            file_desc = 'MISSING'
            missing['files'].add(fn)
        schemas[fn] = {
            'file_descrition': file_desc,
            'fields': OrderedDict()
        }

        # Add fields and desciptions to output
        for field in fields:

            field_name = field['name'] 

            # Get field description
            try:
                field_desc = desc['fields'][field_name]
            except KeyError:
                field_desc = 'MISSING'
                missing['fields'].add(fn)
            
            # Add to schemas
            schemas[fn]['fields'][field_name] = {
                'field_description': field_desc,
                'field_type': field['type'],
                'field_mode': field['mode']
            }
    
    return schemas, missing

def check_missing(missing_dict, out_missing):
    ''' Check for missing descriptions then quits
    '''
    # Stop if there are any missing descriptions
    if (len(missing_dict['fields']) > 0) or (len(missing_dict['files']) > 0):
        # Write missing fields to file
        with open(out_missing, 'w') as outh:
            json.dump(missing_dict, outh, indent=2, default=json_errors)
        # Raise error and stop
        sys.exit(
            'ERROR: Descriptions are missing from {}. '
            'Writing missing fields to {}.'.format(args.in_desc, out_missing)
        )
    return 0

def json_errors(value):
    ''' Function to encode json errors
    '''
    if isinstance(value, set):
        return list(value)

def parse_args():
    """ Load command line args """
    parser = argparse.ArgumentParser()
    parser.add_argument('--in_bq',
        metavar="<file>",
        help='Pattern to glob all BigQuery schema files',
        type=str,
        default='../loaders/bq/bq.*.schema.json')
    parser.add_argument('--in_desc',
        metavar="<file>",
        help='Input descriptions',
        type=str,
        default='input_descriptions.json')
    parser.add_argument('--out_prefix',
        metavar="<file>",
        help='Output prefix for the readme files (in json and txt)',
        type=str,
        default='output/schemas_w_descriptions')
    
    args = parser.parse_args()
    return args

if __name__ == '__main__':

    main()
