import csv
import json
import sys

csvfile = open(sys.argv[1], 'r+')
jsonfile = open(sys.argv[2], 'w+')

fields = ["study_id", "pmid", "pub_date", "pub_journal", "pub_title", "pub_author", "trait_reported", "trait_code", "n_initial", "n_replication", "n_cases", "trait_category"]

fields_array = ["trait_efos", "ancestry_initial", "ancestry_replication"]
def remove_if_empty(line, fields):
    for field in fields:
        if field in line and len(line[field]) == 0:
            del(line[field])
    return line

def string_to_list(line, fields, sep=';'):
    for field in fields:
        if field in line and len(line[field]) > 0:
            tokens = line[field].split(sep)
            line[field] = map(lambda(el): el.strip(), tokens)
        else:
            line[field] = []
    return line

reader = csv.DictReader(csvfile, delimiter="\t")
for row in reader:
    cleaned_line = string_to_list(remove_if_empty(row,fields),fields_array)
    json.dump(row, jsonfile)
    jsonfile.write('\n')
