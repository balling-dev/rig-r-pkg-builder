#!/bin/bash
set -euo pipefail

# Install OS packages for R package development

echo "Installing OS packages for R package development..."

# Update package lists
apt-get update -qq -y

# Default package list
PACKAGES="\
  cmake \
  curl \
  git \
  gsfonts \
  jq \
  libcurl4-openssl-dev \
  libfontconfig1-dev \
  libfreetype6-dev \
  libfribidi-dev \
  libgit2-dev \
  libglpk-dev \
  libharfbuzz-dev \
  libicu-dev \
  libjpeg-dev \
  libleptonica-dev \
  libmagick++-dev \
  libpng-dev \
  libpoppler-cpp-dev \
  libssl-dev \
  libtesseract-dev \
  libtiff-dev \
  libuv1-dev \
  libwebp-dev \
  libx11-dev \
  libxml2-dev \
  make \
  pandoc \
  poppler-data \
  qpdf \
  sudo \
  tar \
  tesseract-ocr-eng \
  texlive-xetex \
  unzip \
  wget \
  zlib1g-dev"

echo "Installing packages: $PACKAGES"

# Install packages
apt-get install -y --no-install-recommends $PACKAGES

# Clean up
echo "Cleaning up..."
apt-get autoremove -y
apt-get autoclean
rm -rf /var/lib/apt/lists/*

echo "OS packages installation completed successfully!"
