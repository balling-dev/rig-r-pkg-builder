#!/bin/bash
set -euo pipefail

# Install OS packages for R package development

echo "Installing OS packages for R package development..."

# Update package lists
apt-get update -qq -y

# Default package list (fallback)
PACKAGES="libcurl4-openssl-dev libxml2-dev libfontconfig1-dev libssl-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev ccache qpdf pandoc jq git wget curl unzip tar libgit2-dev libx11-dev libglpk-dev"

echo "Installing packages: $PACKAGES"

# Install packages
apt-get install -y --no-install-recommends $PACKAGES

# Configure ccache
echo "Configuring ccache..."
mkdir -p /usr/lib/ccache
# Add ccache to PATH by creating symlinks
for compiler in gcc g++ cc c++; do
    if command -v "$compiler" > /dev/null 2>&1; then
        ln -sf /usr/bin/ccache "/usr/lib/ccache/$compiler"
    fi
done

# Clean up
echo "Cleaning up..."
apt-get autoremove -y
apt-get autoclean
rm -rf /var/lib/apt/lists/*

echo "OS packages installation completed successfully!"
