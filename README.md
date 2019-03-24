# Building Bazel on a Raspberry Pi 3

This repository contains a few scripts to streamline building Bazel
from source on a Raspberry Pi 3. The included scripts help setup a
swapfile and install the needed dependencies. These scripts also work
on traditional platforms but the prebuilt distributions are
recommended.

The build process takes a very long time on cheap boards. Using a this
script can help get it right the first time, especially if you want to
build it on multiple slightly different platforms.

This script uses the current version of Bazel when it was written, but
by now it is likely out of date. Make sure you are happy with the
versions specified at the top of `run.sh` before you begin.

## Scripts

### `install_dependencies.sh`

Uses apt-get to install Bazel's build dependencies. This probably
doesn't need to be a script.

### `setup_swap.sh`

The Raspberry Pi 3's 1GB is not enough to build Bazel. This script
helps set up a 4GB swap file in `/var`.

### `run.sh`

Downloads the source code and builds Bazel. The binary will be in the
repository root. Heads up, this step downloads a few hundred megabytes
and will take a few hours to complete. This script uses a workspace in
`/tmp` and should clean up after it completes.

## Notes

Following the instructions on the Bazel website are basically all
these scripts do. The important points are:

- Make sure you have a few GB memory available. When using
  underpowered hardware use a very large swapfile and be patient.
- The zip utility was not installed by default. Finding out after a
  multiple-hour build is a bummer.

Finally, compile with:

```
$ EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" BAZEL_JAVAC_OPTS="-J-Xmx1g" ./compile.sh
```

### Timing

My observations. Your results may vary.

| Platform                        | Duration |
| ------------------------------- | -------- |
| Raspberry Pi 3 Model B+         | 2h44m    |
| 2008 Core 2 Duo                 | 24m      |
| DigitalOcean 2 CPU/4 GB Droplet | 10m      |
