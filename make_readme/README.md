## Make FTP readme based on BigQuery schemas

Script to read BigQuery schemas and add file/field descriptions to make a readme file for the FTP.

### Usage
```
python make_readme.py \
  --in_bq "../loaders/bq/bq.*.schema.json" \
  --in_desc input_descriptions.json \
  --out output/ftp_readme
```