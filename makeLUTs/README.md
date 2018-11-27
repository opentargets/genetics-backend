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

### Dumping Ensembl gene information for the Open Targets pipeline

An optional argument can be used to specify a file to which gene information required by opentargets/data_pipeline is written:

```
pipenv run python create_genes_dictionary.py --pipeline ensembl_genes.json
```
