#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
'''
Creates a json look-up table to map bio_feature strings, to codes, to labels
'''

import json
import re

def main():

    # Args
    output_json = 'biofeature_lut_190208.json'

    data = []

    # Load gtex
    data = data + load_gtex('inputs/gtex7_bio_feature_map.csv')

    # Load Javierre 2016
    data = data + load_javierre('inputs/javierre2016_bio_feature_map.csv')

    # Load eqtl DB
    data = data + eqtl_db_v1()

    # Write output
    with open(output_json, 'w') as out_h:
        for record in data:
            out_h.write(json.dumps(record) + '\n')

    return 0

def eqtl_db_v1():
    l = []
    cells = ['B-cell_CD19', 'LCL', 'T-cell', 'T-cell_CD4', 'T-cell_CD8',
             'blood', 'fat', 'fibroblast', 'iPSC', 'ileum', 'macrophage_IFNg',
             'macrophage_IFNg+Salmonella', 'macrophage_Listeria',
             'macrophage_Salmonella', 'macrophage_naive', 'monocyte',
             'monocyte_CD14', 'monocyte_IAV', 'monocyte_IFN24', 'monocyte_LPS',
             'monocyte_LPS2', 'monocyte_LPS24', 'monocyte_Pam3CSK4',
             'monocyte_R848', 'monocyte_naive', 'neutrophil', 'neutrophil_CD15',
             'neutrophil_CD16', 'pancreatic_islet', 'platelet', 'rectum',
             'sensory_neuron', 'skin', 'transverse_colon']
    for cell in cells:
        l.append({'original_source': 'ebi_eqtl_db_v1',
                  'biofeature_string': cell,
                  'label': cell.replace('_', ' ').capitalize(),
                  'biofeature_code': re.sub('[^0-9a-zA-Z]+', '_', cell).upper()})
    return l

def load_javierre(inf):
    l = []
    with open(inf, 'r') as in_h:
        in_h.readline()
        for line in in_h:
            parts = line.rstrip().split(',')
            l.append({'original_source': 'javierre2016',
                      'biofeature_string': parts[0],
                      'label': parts[0].replace('_', ' '),
                      'biofeature_code': parts[0].upper() })
    return l

def load_gtex(inf):
    l = []
    with open(inf, 'r') as in_h:
        in_h.readline()
        for line in in_h:
            parts = line.rstrip().split(',')
            l.append({'original_source': 'GTEXv7',
                      'biofeature_string': parts[0],
                      'label': parts[1].capitalize().replace('_', ' '),
                      'biofeature_code': parts[2] })
    return l

if __name__ == '__main__':

    main()
