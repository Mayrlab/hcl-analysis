#!/bin/bash -l

message () { cat <<< "[INFO] $@" 1>&2; }

check_md5 () {
    message "Verifying $1..."
    local result=$(md5 -q "$1")
    if [[ $result == $2 ]]; then
        message "Success."
    else
        message "MD5 sum mismatch!"
    fi
}

dl () {
    wget -O "$1" "$2"
    check_md5 "$1" "$3"
}

## cell info
dl 'HCL_Fig1_cell_Info.xlsx' 'https://figshare.com/ndownloader/files/21758835' 'fe73a9b7129abb10d09dfcd355c19f12'
