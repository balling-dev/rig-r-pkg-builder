#!/bin/bash
set -euo pipefail

# Install OS packages for R package development

echo "Installing OS packages for R package development..."

# Update package lists
apt-get update -qq -y

# Default package list
PACKAGES="libcurl4-openssl-dev libxml2-dev libfontconfig1-dev libssl-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev qpdf pandoc jq git wget curl unzip tar libgit2-dev libx11-dev libglpk-dev sudo"

echo "Installing packages: $PACKAGES"

# Install packages
apt-get install -y --no-install-recommends $PACKAGES

# Clean up
echo "Cleaning up..."
apt-get autoremove -y
apt-get autoclean
rm -rf /var/lib/apt/lists/*

echo "OS packages installation completed successfully!"
