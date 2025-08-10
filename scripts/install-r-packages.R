#!/usr/bin/env Rscript

# Install R packages for all R versions available in rig

cat("Installing R packages for pipeline operations...\n")

# Function to safely install packages with error handling
safe_install <- function(packages, r_version = "current") {
  cat("Installing packages for R version:", r_version, "\n")
  cat("Packages:", paste(packages, collapse = ", "), "\n")

  tryCatch({
    # Ensure pak is available
    if (!requireNamespace("pak", quietly = TRUE)) {
      install.packages("pak", repos = "https://cloud.r-project.org/")
    }

    # Install packages using pak (handles dependencies better)
    pak::pkg_install(packages, upgrade = TRUE)

    cat("✓ Successfully installed packages for R version:", r_version, "\n")
    return(TRUE)
  }, error = function(e) {
    cat("✗ Error installing packages for R version:", r_version, "\n")
    cat("Error message:", conditionMessage(e), "\n")
    return(FALSE)
  })
}

# Read R packages from file if it exists, otherwise use default list
packages_file <- "/tmp/package-lists/r-packages.txt"
if (file.exists(packages_file)) {
  # Read packages, filter out comments and empty lines
  all_lines <- readLines(packages_file)
  packages <- all_lines[!grepl("^#", all_lines) & nzchar(trimws(all_lines))]
  packages <- trimws(packages)
} else {
  # Default package list (fallback)
  packages <- c(
    "pak", "devtools", "roxygen2", "decor",
    "lintr", "styler", "cyclocomp",
    "pkgdown", "rsconnect",
    "sessioninfo", "RcppSimdJson", "desc", "miniCRAN",
    "remotes", "withr", "testthat", "knitr", "rmarkdown"
  )
}

cat("Packages to install:", paste(packages, collapse = ", "), "\n")

# Read R versions from file if it exists, otherwise use default list
versions_file <- "/tmp/package-lists/r-versions.txt"
if (file.exists(versions_file)) {
  # Read versions, filter out comments and empty lines
  all_lines <- readLines(versions_file)
  r_versions <- all_lines[!grepl("^#", all_lines) & nzchar(trimws(all_lines))]
  r_versions <- trimws(r_versions)
} else {
  # Default R versions (fallback)
  r_versions <- c("release", "next", "devel", "4.4.3", "4.3.3", "4.2.3", "4.1.3")
}

cat("R versions to configure:", paste(r_versions, collapse = ", "), "\n")

# Get currently available R versions from rig
available_versions <- tryCatch({
  system("rig list", intern = TRUE)
}, error = function(e) {
  cat("Warning: Could not get rig list, using default versions\n")
  character(0)
})

# Install packages for each R version
success_count <- 0
total_count <- 0

for (version in r_versions) {
  total_count <- total_count + 1
  cat("\n=== Processing R version:", version, "===\n")

  # Try to switch to this R version
  switch_cmd <- paste("rig default", version)
  switch_result <- tryCatch({
    system(switch_cmd, ignore.stdout = TRUE, ignore.stderr = TRUE)
  }, error = function(e) {
    cat("Warning: Could not switch to R version:", version, "\n")
    1
  })

  if (switch_result != 0) {
    cat("Skipping R version", version, "- not available or switch failed\n")
    next
  }

  # Verify R version
  r_version_check <- tryCatch({
    system("R --version", intern = TRUE)[1]
  }, error = function(e) {
    "Unknown R version"
  })
  cat("Current R version:", r_version_check, "\n")

  # Install packages for this R version
  if (safe_install(packages, version)) {
    success_count <- success_count + 1
  }
}

# Summary
cat("\n=== Installation Summary ===\n")
cat("Total R versions processed:", total_count, "\n")
cat("Successful installations:", success_count, "\n")
cat("Failed installations:", total_count - success_count, "\n")

if (success_count == total_count) {
  cat("✓ All R package installations completed successfully!\n")
} else if (success_count > 0) {
  cat("⚠ Partial success - some R versions failed\n")
} else {
  cat("✗ All R package installations failed\n")
  quit(status = 1)
}

# Switch to R release
version <- "release"
switch_cmd <- paste("rig default", version)
switch_result <- tryCatch({
  system(switch_cmd, ignore.stdout = TRUE, ignore.stderr = TRUE)
}, error = function(e) {
  cat("Warning: Could not switch to R version:", version, "\n")
  1
})

cat("R packages installation script completed.\n")
