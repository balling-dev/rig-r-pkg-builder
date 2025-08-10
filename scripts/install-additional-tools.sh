#!/bin/bash
set -euo pipefail

# Install additional tools for R package development

echo "Installing additional tools..."

# Function to get latest GitHub release download URL
get_latest_release_url() {
    local repo="$1"
    local pattern="$2"
    curl -s "https://api.github.com/repos/$repo/releases/latest" | \
        grep -E "browser_download_url.*$pattern" | \
        cut -d '"' -f 4 | \
        head -n 1
}

# Install Quarto CLI
echo "Installing Quarto CLI..."
QUARTO_URL=$(get_latest_release_url "quarto-dev/quarto-cli" "linux-amd64\\.deb")
if [ -n "$QUARTO_URL" ]; then
    echo "Downloading Quarto from: $QUARTO_URL"
    wget -q "$QUARTO_URL" -O /tmp/quarto-linux-amd64.deb
    dpkg -i /tmp/quarto-linux-amd64.deb
    rm -f /tmp/quarto-linux-amd64.deb
    echo "Quarto CLI installed successfully"
else
    echo "Warning: Could not find Quarto CLI release URL"
fi

# Install bbi (Bayesian modeling tool)
echo "Installing bbi..."
BBI_URL=$(get_latest_release_url "metrumresearchgroup/bbi" "linux_amd64\\.tar\\.gz")
if [ -n "$BBI_URL" ]; then
    echo "Downloading bbi from: $BBI_URL"
    wget -q "$BBI_URL" -O /tmp/bbi.tar.gz
    cd /tmp
    tar -xzf bbi.tar.gz
    # Find the bbi binary in the extracted directory
    BBI_BINARY=$(find /tmp -name "bbi" -type f | head -n 1)
    if [ -n "$BBI_BINARY" ]; then
        chmod +x "$BBI_BINARY"
        mv "$BBI_BINARY" /usr/local/bin/bbi
        echo "bbi installed successfully"
    else
        echo "Warning: Could not find bbi binary in archive"
    fi
    rm -f /tmp/bbi.tar.gz
    rm -rf /tmp/bbi_linux_amd64*
else
    echo "Warning: Could not find bbi release URL"
fi

# Verify installations
echo "Verifying installations..."

if command -v quarto >/dev/null 2>&1; then
    echo "✓ Quarto CLI: $(quarto --version)"
else
    echo "✗ Quarto CLI not found"
fi

if command -v bbi >/dev/null 2>&1; then
    echo "✓ bbi: $(bbi version)"
else
    echo "✗ bbi not found"
fi

echo "Additional tools installation completed!"
