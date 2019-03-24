#!/usr/bin/env bash

# This script installs bazel's dependencies on a Debian operating
# system.

set -ue

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
fi

apt-get update

apt-get install \
    autoconf \
    automake \
    default-jdk-headless \
    g++ \
    libtool \
    pkg-config \
    unzip \
    zip \
    zlib1g-dev
