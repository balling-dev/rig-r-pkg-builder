# Multi-stage Docker image for R package development and CI/CD
# Based on ghcr.io/r-lib/rig/r with pre-installed dependencies
#
# This image includes:
# - All OS packages required for R package development
# - Common R packages pre-installed for multiple R versions
# - Additional tools (quarto-cli, bbi)

FROM ghcr.io/r-lib/rig/r:latest

LABEL maintainer="Kristoffer Winther Balling"
LABEL description="R package development environment with pre-installed dependencies"
LABEL org.opencontainers.image.source="https://github.com/balling-dev/rig-r-pkg-builder"
LABEL org.opencontainers.image.documentation="https://github.com/balling-dev/rig-r-pkg-builder"
LABEL org.opencontainers.image.licenses="MIT"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV CCACHE_DIR=/opt/ccache
ENV PATH="/usr/lib/ccache:${PATH}"

# Create necessary directories
RUN mkdir -p /opt/ccache /tmp/package-lists mkdir -p /tmp/scripts

# Copy package lists and scripts
COPY package-lists/ /tmp/package-lists/
COPY scripts/ /tmp/scripts/

# Make scripts executable
RUN chmod +x /tmp/scripts/*.sh \
  && /tmp/scripts/install-os-packages.sh \
  && /tmp/scripts/install-additional-tools.sh \
  && Rscript /tmp/scripts/install-r-packages.R \
  && rm -rf /tmp/package-lists \
  && Rscript -e "pak::cache_clean()" \
  && Rscript -e "pak::meta_clean(force = TRUE)" \
  && rm -rf /tmp/scripts /tmp/Rtmp* /tmp/downloaded_packages /tmp/*.rds

