#!/usr/bin/env Rscript

# Install R packages

cat("Installing R packages for pipeline operations...\n")

# Function to safely install packages with error handling
safe_install <- function(packages) {
  cat("Packages:", paste(packages, collapse = ", "), "\n")

  tryCatch({
    # Install packages using pak (handles dependencies better)
    pak::pkg_install(packages, upgrade = TRUE, lib = .libPaths()[2])

    cat("✓ Successfully installed packages\n")
    return(TRUE)
  }, error = function(e) {
    cat("✗ Error installing packages\n")
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
    "devtools", "roxygen2", "decor",
    "lintr", "styler", "cyclocomp",
    "pkgdown", "rsconnect",
    "sessioninfo", "RcppSimdJson", "desc", "miniCRAN",
    "remotes", "withr", "testthat", "knitr", "rmarkdown"
  )
}

cat("Packages to install:", paste(packages, collapse = ", "), "\n")

# Install packages for this R version
safe_install(packages)

cat("R packages installation script completed.\n")
