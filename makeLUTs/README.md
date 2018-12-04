# Generate files suitable for Genetics Portal backend and Open Targets pipeline

## Installation

```
conda env create -f environment.yaml
conda activate genetics-backend
```

## Usage

```
usage: create_genes_dictionary.py [-h] [-o PATH] [-e] [-z]
                                  [-n ENSEMBL_DATABASE]

Genetics Portal backend data processing

optional arguments:
  -h, --help            show this help message and exit
  -o PATH, --output-path PATH
                        The name of the output folder, default ./
  -e, --enable-platform-mode
                        Dump gene information needed for the Open Targets
                        pipeline, default False
  -z, --enable-compression
                        Enable gzip compression for the produced file, default
                        True
  -n ENSEMBL_DATABASE, --ensembl-database ENSEMBL_DATABASE
                        Use the specified Ensembl database, default is
                        homo_sapiens_core_93_37


```

### Genes dictionary

```
python create_genes_dictionary.py -o path
```

will output a `genes.json` file that can be uploaded to the right storage bucket

### Specifying the Ensembl database to use

The `--ensembl-database` option can be used to specify the Ensembl database to use, e.g.

```
python create_genes_dictionary.py -n homo_sapiens_core_93_37
```

The correct Ensembl public database server port will be selected depending on the assembly version of the database.
If this option is _not_ specified, the default database used is `homo_sapiens_core_93_37`

### Dumping Ensembl gene information for the Open Targets pipeline

An optional argument can be used to specify a file to which gene information required by opentargets/data_pipeline is written:

```
python create_genes_dictionary.py -o "./" -e -z -n homo_sapiens_core_93_38
```

Note that if the filename ends in `.gz` the output will be automatically `gzip`-compressed.
