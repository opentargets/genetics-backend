# Generate files suitable for Genetics Portal backend and Open Targets pipeline

## Installation

[Install pipenv with homebrew or your method of choice](https://pipenv.readthedocs.io/en/latest/install/#installing-pipenv), then

```
pipenv install
```

## Usage

### Genes dictionary

```
pipenv run python create_genes_dictionary.py
```

will output a `genes.json` file that can be uploaded to the right storage bucket

### Specifying the Ensembl database to use

The `--ensembl-database` option can be used to specify the Ensembl database to use, e.g.

```
python create_genes_dictionary.py --ensembl-database homo_sapiens_core_93_38
```

The correct Ensembl public database server port will be selected depending on the assembly version of the database.
If this option is _not_ specified, the default database used is `homo_sapiens_core_93_37`

### Dumping Ensembl gene information for the Open Targets pipeline

An optional argument can be used to specify a file to which gene information required by opentargets/data_pipeline is written:

```
pipenv run python create_genes_dictionary.py --pipeline ensembl_genes.json
```

Note that if the filename ends in `.gz` the output will be automatically `gzip`-compressed.
