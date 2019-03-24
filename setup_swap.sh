#!/usr/bin/env bash

# Setup a 4GB swapfile

set -ue

swapfile_path="/var/swap"
swapfile_size="4G"

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
fi

if [[ -e "${swapfile_path}" ]]; then
    read -p "Disable and delete ${swapfile_path}? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        if [[ ! -z "$(swapon -s | grep "${swapfile_path}")" ]]; then
            echo "Disabling swap file ${swapfile_path}" >&2
            swapoff "${swapfile_path}"
        fi

        rm "${swapfile_path}"
    else
        exit 1
    fi
fi

fallocate -l "${swapfile_size}" "${swapfile_path}"
chmod 600 "${swapfile_path}"
mkswap "${swapfile_path}"
swapon "${swapfile_path}"
