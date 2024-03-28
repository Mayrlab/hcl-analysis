[![DOI](https://zenodo.org/badge/645059782.svg)](https://zenodo.org/doi/10.5281/zenodo.10892181)

## Overview

This repository provides analysis of the human cleavage site annotation resulting from running 
the pipeline at https://github.com/Mayrlab/hcl-utrome. It characterizes cleavage sites with respect 
to number of cell types in which they are detected, presence of cleavage factor motifs, PhastCons 
conservation scores, and APARENT2 scores. It is particularly concerned with comparing cleavage
sites in common between GENCODE annotations and detected in Microwell-seq data, and those only
found in either GENCODE or Microwell-seq data.

It also contains some preprocessing code that created the metadata tables used in the pipeline.

A preprint of the results are reported in [Fansler et al., bioRxiv, 2023](https://www.biorxiv.org/content/10.1101/2021.11.22.469635v2).

## Organization
The folders in the repository have the following purposes:

- `analysis` - primary source code and rendered HTMLs of R Markdown or IPython notebooks
- `envs` - Conda environment YAML files for recreating the execution environment
- `img` - *output* images
- `metadata` - *output* tables used in pipeline
- `qc` - quality control data from the pipeline outputs
- `scripts` - miscellaneous scripts for data format conversions

All code is expected to be executed with this repository as the present working
directory. If opening as an R Project in RStudio, make sure to set the Project 
folder as the working directory.

### Source Code
The primary source code is found in the `analysis` folder. 
Files are numbered in the original order of execution, though the order does not 
imply strict necessity (most analyses here can be independently executed).

The `analysis/processing/reformat_annots.Rmd` was run *before* 
[the pipeline](https://github.com/Mayrlab/hcl-utrome), and 
generated `metadata` outputs that were used in the pipeline.

### Execution Environments
The R instances used to execute the files was captured both in the rendered RMDs themselves
(see **Runtime Details** section in HTMLs) and provided as YAML files in the `envs` folder.

To recreate on arbitrary platforms (Linux or MacOS), we recommend using 
[Micromamba](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html#)
and the minimal YAML (`*.min.yaml`):

```bash
micromamba create -n bioc_3_16 -f envs/bioc_3_16.min.yaml
micromamba activate bioc_3_16
```

A fully-solved environment capture is also provided (`*.full.yaml`). This is only 
expected to recreate on the **osx-64** platform and is primarly intended for *exact* 
replication and a statement of record.

