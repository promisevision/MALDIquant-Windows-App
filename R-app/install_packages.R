# Install Required R Packages for MALDIquant Application
# Run this script before starting the application

cat("Installing required R packages...\n\n")

# List of required packages
required_packages <- c(
  "shiny",
  "MALDIquant",
  "MALDIquantForeign",
  "plotly",
  "DT",
  "bslib",
  "colourpicker",
  "shinyFiles",
  "shinyWidgets",
  "tools"
)

# Function to check and install packages
install_if_missing <- function(package) {
  if (!require(package, character.only = TRUE, quietly = TRUE)) {
    cat(paste("Installing", package, "...\n"))
    install.packages(package, dependencies = TRUE, repos = "https://cran.rstudio.com/")

    if (require(package, character.only = TRUE, quietly = TRUE)) {
      cat(paste("  ✓", package, "installed successfully\n"))
    } else {
      cat(paste("  ✗ Failed to install", package, "\n"))
      return(FALSE)
    }
  } else {
    cat(paste("  ✓", package, "already installed\n"))
  }
  return(TRUE)
}

# Install all packages
cat("Checking and installing packages...\n")
cat("====================================\n\n")

results <- sapply(required_packages, install_if_missing)

cat("\n====================================\n")
cat("Installation Summary:\n")
cat(paste("Total packages:", length(required_packages), "\n"))
cat(paste("Successfully installed/verified:", sum(results), "\n"))
cat(paste("Failed:", sum(!results), "\n"))

if (all(results)) {
  cat("\n✓ All packages installed successfully!\n")
  cat("You can now run the application with: shiny::runApp('R-app')\n")
} else {
  cat("\n✗ Some packages failed to install. Please check the errors above.\n")
  failed_packages <- required_packages[!results]
  cat("Failed packages:", paste(failed_packages, collapse = ", "), "\n")
}
