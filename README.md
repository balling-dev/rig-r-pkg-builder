# R Package Development Environment

[![Build and Push Docker Image](https://github.com/balling-dev/rig-r-pkg-builder/actions/workflows/build-and-push.yml/badge.svg)](https://github.com/balling-dev/rig-r-pkg-builder/actions/workflows/build-and-push.yml)
[![Docker Image Size](https://img.shields.io/docker/image-size/ghcr.io/balling-dev/rig-r-pkg-builder/latest)](https://github.com/balling-dev/rig-r-pkg-builder/pkgs/container/rig-r-pkg-builder)

A Docker image based on [`ghcr.io/r-lib/rig/r`](https://github.com/r-lib/rig) with pre-installed dependencies for R package development and CI/CD pipelines.

## Update Schedule

The image is automatically built and pushed to GitHub Container Registry:

- **Weekly**: Every Sunday at 2 AM UTC (scheduled build)
- **On changes**: When modifications are made to Dockerfile, scripts, or package lists
- **Manual**: Can be triggered manually via GitHub Actions

## Image Tags

- `latest`: Most recent build from main branch
- `weekly-YYYY-MM-DD`: Weekly automated builds
- `main-<sha>`: Commit-specific builds from main branch

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Projects

- [rig](https://github.com/r-lib/rig): R Installation Manager
- [pak](https://github.com/r-lib/pak): Package manager for R
- [r-lib/actions](https://github.com/r-lib/actions): GitHub Actions for R

