# Global configuration and helper functions for MALDIquant Application

# Load required libraries
suppressPackageStartupMessages({
  library(shiny)
  library(MALDIquant)
  library(MALDIquantForeign)
  library(plotly)
  library(DT)
  library(bslib)
})

# Check if optional packages are available
if (!require("colourpicker", quietly = TRUE)) {
  warning("colourpicker package not found. Color selection features will be limited.")
}

# Application constants
APP_VERSION <- "1.0.0"
APP_NAME <- "MALDIquant Analyzer"

# Supported file formats
SUPPORTED_FORMATS <- c(
  "mzML" = ".mzML",
  "mzXML" = ".mzXML",
  "Text" = ".txt",
  "CSV" = ".csv"
)

# Default processing parameters
DEFAULT_PARAMS <- list(
  smoothing = list(
    method = "SavitzkyGolay",
    halfWindowSize = 10
  ),
  baseline = list(
    method = "SNIP",
    iterations = 100
  ),
  peakDetection = list(
    SNR = 3,
    halfWindowSize = 20
  )
)

# Helper function: Validate spectrum data
validateSpectrum <- function(spectrum) {
  if (!isMassSpectrum(spectrum)) {
    return(list(valid = FALSE, message = "Invalid MassSpectrum object"))
  }

  if (length(mass(spectrum)) == 0) {
    return(list(valid = FALSE, message = "Empty spectrum"))
  }

  if (any(is.na(mass(spectrum))) || any(is.na(intensity(spectrum)))) {
    return(list(valid = FALSE, message = "Spectrum contains NA values"))
  }

  return(list(valid = TRUE, message = "Valid spectrum"))
}

# Helper function: Format number for display
formatNumber <- function(x, digits = 2) {
  format(round(x, digits), nsmall = digits, big.mark = ",")
}

# Helper function: Get file extension
getFileExtension <- function(filename) {
  tools::file_ext(filename)
}

# Helper function: Create log message
logMessage <- function(message, type = "INFO") {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  paste0("[", timestamp, "] ", type, ": ", message)
}

# Print startup message
cat("=========================================\n")
cat(paste(APP_NAME, "v", APP_VERSION, "\n"))
cat("=========================================\n")
cat("Application initialized successfully\n")
cat("Ready to process mass spectrometry data\n")
cat("=========================================\n\n")
