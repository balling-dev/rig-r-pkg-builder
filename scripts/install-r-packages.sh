#!/usr/bin/env bash
mapfile -t r_versions < <( rig list --json | jq '.[].name' | sed 's/"//g')

for r_version in "${r_versions[@]}"
do
   echo "Installing R packages for ${r_version}"
   rig default "${r_version}"
   Rscript -e 'cat(paste0("Using R package library: ", .libPaths()[2]))'
   Rscript -e 'install.packages("remotes", lib = .libPaths()[2])'
   Rscript -e 'remotes::install_github("r-lib/pak@95c6b18d5ccaa22a422b03d7234927ef22f4dc4c", force = TRUE, lib = .libPaths()[2])'
   Rscript /tmp/scripts/install-r-packages.R
done
rig default release

