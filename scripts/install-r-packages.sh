#!/usr/bin/env bash
mapfile -t r_versions < <( rig list --json | jq '.[].name' | sed 's/"//g')

for r_version in "${r_versions[@]}"
do
   echo "Installing R packages for ${r_version}"
   rig default "${r_version}"
   Rscript -e 'cat(paste0("Using R package library: ", .libPaths()[2]))'
   Rscript -e 'install.packages("remotes", lib = .libPaths()[2])'
   Rscript -e 'remotes::install_github("r-lib/pak@00e4ec6e5e3cfad3d7431fef6ef645cfbd750b52", force = TRUE, lib = .libPaths()[2])'
   Rscript /tmp/scripts/install-r-packages.R
done
rig default release

