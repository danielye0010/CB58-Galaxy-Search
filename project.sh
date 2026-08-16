#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <reference.fits> <spectra.tar.gz> <output.csv>" >&2
  exit 2
fi

reference="$1"
archive="$2"
output="$3"
workdir="job_data"

mkdir -p "$workdir"
tar -xzf "$archive" -C "$workdir"

# FITSio should be installed in the R environment distributed with the job.
Rscript project.R "$reference" "$workdir" "$output"
