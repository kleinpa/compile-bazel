#!/usr/bin/env bash

# This script downloads and builds Bazel from source. It assumes
# Bazel's build dependencies, documented in prep.sh, are already
# present and the system has enough memory (physical or swap) to
# actually build bazel. Building Bazel is resource intensive. This
# script takes on the order of 3.5 hours to run on a Rasberry Pi 3.

# Configure Bazel package download URLs. This should be the "ready to
# compile" *-dist.zip package from the GitHub releases page.

set -ue

download_url="https://github.com/bazelbuild/bazel/releases/download/0.23.2/bazel-0.23.2-dist.zip"
download_sha1sum="e6814afeb5d379d436c244c72f2786f62052a5bb"

output_dir="$(dirname $(realpath $0))"

# Install Ubuntu/Debian dependencies. This will call sudo for
# privilege escalation if any package is missing.
packages=(
    autoconf
    automake
    default-jdk-headless
    g++
    libtool
    pkg-config
    unzip
    zip
    zlib1g-dev
)

if ! dpkg -s "${packages[@]}" &> /dev/null; then
    sudo apt-get install -y --no-upgrade "${packages[@]}"
fi

# Create a temporary directory to contain any mess. This is not
# required.
tmp_workspace=$(mktemp --tmpdir -d compile_bazel_XXXXXXXX)
echo "Creating fresh workspace ${tmp_workspace}" >&2
trap "rm -rf ${tmp_workspace}; echo Cleaning up workspace ${tmp_workspace} >&2" EXIT
cd ${tmp_workspace}

# Download and checksum the source code.
archive="bazel-dist.zip"
curl -L ${download_url} -o "${archive}"
sha1sum -c <(echo "$download_sha1sum ${archive}")

# Unzip the source code into the workspace.
unzip -q "${archive}"

# The host_javabase flag instructs Bazel to use the locally installed
# JDK instead of downloading one, which will not work on nonstandard
# platforms. The extra javac flags increase the heap size to
time {
    EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" BAZEL_JAVAC_OPTS="-J-Xmx1g" ./compile.sh
}

# The previous command builds a self-contained binary. Copy it out of
# the workspace.
ln -f bazel "${output_dir}/bazel"
ln bazel "${output_dir}/bazel-binary-$(date --utc +%Y%m%d_%H%M%S)"
