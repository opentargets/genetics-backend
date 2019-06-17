#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
'''
Adds composite (source, feature) fields that had to be hacked for June 2019 release
'''

import sys
import json
from pprint import pprint

def main():

    # Args
    in_latest = '../latest/biofeature_lut_190328.json'
    in_composites = 'list_of_composite_features.json'
    output_json = '../latest/biofeature_lut_190328.w_composites.json'

    # Load composite data
    composite = []
    with open(in_composites, 'r') as in_h:
        for line in in_h:
            composite.append(json.loads(line))
    
    # Load exisitng lines and code to display label map
    existing = []
    label_map = {}
    with open(in_latest, 'r') as in_h:
        for line in in_h:
            d = json.loads(line)
            existing.append(d)
            label_map[d['biofeature_code']] = d['label']

    # Write new file with additional lines
    with open(output_json, 'w') as out_h:

        # Write existing
        for line in existing:
            out_h.write(json.dumps(line) + '\n')
        
        # Write new lines
        for line in composite:

            # Split study and tissue name from 'feature'
            study, tissue = line['feature'].split('-', 1)

            # Make data
            out_row = {
                'original_source': 'composite_source_feature_hack',
                'biofeature_string': line['feature'],
                'biofeature_code': line['feature'],
                'label': '{} ({})'.format(
                    label_map[tissue],
                    study.replace('_', ' ')
                )
            }

            # Write
            out_h.write(json.dumps(out_row) + '\n')


    


    return 0


if __name__ == '__main__':

    main()
