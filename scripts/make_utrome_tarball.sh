#!/usr/bin/env bash -l
UTROME_PARAMS="e30.t5.gc39.pas3.f0.9999.w500"
MERGE_PARAMS="m200"

GTF_FILE="utrome.${UTROME_PARAMS}.gtf"
MERGE_FILE="utrome.${UTROME_PARAMS}.${MERGE_PARAMS}.tsv"
KDX_FILE="utrome.${UTROME_PARAMS}.kdx"
TAR_FILE="utrome.${UTROME_PARAMS}.tar.gz"

GFF_PATH="../data/gff"
KDX_PATH="../data/kdx"

## copy files
cp "${GFF_PATH}/${GTF_FILE}" .
cp "${GFF_PATH}/${MERGE_FILE}" .
cp "${KDX_PATH}/${KDX_FILE}" .

## tar files
tar -czvf "${TAR_FILE}" "${GTF_FILE}" "${MERGE_FILE}" "${KDX_FILE}"
