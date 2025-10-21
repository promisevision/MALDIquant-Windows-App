# Unit Tests for MALDIquant Preprocessing Functions
# Run with: testthat::test_file("tests/test_preprocessing.R")

library(testthat)
library(MALDIquant)

# Test Data Creation
create_test_spectrum <- function() {
  mass <- seq(1000, 5000, by = 1)
  intensity <- rnorm(length(mass), mean = 100, sd = 10)

  # Add baseline
  baseline <- 50 + 0.01 * (mass - 1000)
  intensity <- intensity + baseline

  # Add peaks
  peaks_mass <- c(1500, 2000, 2500, 3000, 3500)
  for (pm in peaks_mass) {
    idx <- which.min(abs(mass - pm))
    intensity[(idx-10):(idx+10)] <- intensity[(idx-10):(idx+10)] +
      500 * exp(-((mass[(idx-10):(idx+10)] - pm)^2) / 10)
  }

  createMassSpectrum(mass, intensity)
}

# Test Suite: Spectrum Creation
test_that("Test spectrum creation works", {
  spectrum <- create_test_spectrum()

  expect_s4_class(spectrum, "MassSpectrum")
  expect_true(length(mass(spectrum)) > 0)
  expect_true(length(intensity(spectrum)) > 0)
  expect_equal(length(mass(spectrum)), length(intensity(spectrum)))
})

# Test Suite: Smoothing
test_that("SavitzkyGolay smoothing works correctly", {
  spectrum <- create_test_spectrum()
  original_length <- length(mass(spectrum))

  smoothed <- smoothIntensity(spectrum, method = "SavitzkyGolay", halfWindowSize = 10)

  expect_s4_class(smoothed, "MassSpectrum")
  expect_equal(length(mass(smoothed)), original_length)
  expect_true(all(is.finite(intensity(smoothed))))
})

test_that("MovingAverage smoothing works correctly", {
  spectrum <- create_test_spectrum()
  original_length <- length(mass(spectrum))

  smoothed <- smoothIntensity(spectrum, method = "MovingAverage", halfWindowSize = 5)

  expect_s4_class(smoothed, "MassSpectrum")
  expect_equal(length(mass(smoothed)), original_length)
  expect_true(all(is.finite(intensity(smoothed))))
})

# Test Suite: Baseline Correction
test_that("SNIP baseline removal works", {
  spectrum <- create_test_spectrum()
  original_length <- length(mass(spectrum))

  corrected <- removeBaseline(spectrum, method = "SNIP", iterations = 100)

  expect_s4_class(corrected, "MassSpectrum")
  expect_equal(length(mass(corrected)), original_length)
  expect_true(all(intensity(corrected) >= 0))
})

test_that("TopHat baseline removal works", {
  spectrum <- create_test_spectrum()
  original_length <- length(mass(spectrum))

  corrected <- removeBaseline(spectrum, method = "TopHat", halfWindowSize = 100)

  expect_s4_class(corrected, "MassSpectrum")
  expect_equal(length(mass(corrected)), original_length)
  expect_true(all(intensity(corrected) >= 0))
})

test_that("ConvexHull baseline removal works", {
  spectrum <- create_test_spectrum()
  original_length <- length(mass(spectrum))

  corrected <- removeBaseline(spectrum, method = "ConvexHull")

  expect_s4_class(corrected, "MassSpectrum")
  expect_equal(length(mass(corrected)), original_length)
})

test_that("Median baseline removal works", {
  spectrum <- create_test_spectrum()
  original_length <- length(mass(spectrum))

  corrected <- removeBaseline(spectrum, method = "median", halfWindowSize = 100)

  expect_s4_class(corrected, "MassSpectrum")
  expect_equal(length(mass(corrected)), original_length)
})

# Test Suite: Normalization
test_that("TIC normalization works", {
  spectrum <- create_test_spectrum()
  original_length <- length(mass(spectrum))

  normalized <- calibrateIntensity(spectrum, method = "TIC")

  expect_s4_class(normalized, "MassSpectrum")
  expect_equal(length(mass(normalized)), original_length)
  expect_true(abs(sum(intensity(normalized)) - 1.0) < 0.01)
})

test_that("PQN normalization works", {
  spectrum <- create_test_spectrum()
  original_length <- length(mass(spectrum))

  normalized <- calibrateIntensity(spectrum, method = "PQN")

  expect_s4_class(normalized, "MassSpectrum")
  expect_equal(length(mass(normalized)), original_length)
})

# Test Suite: Peak Detection
test_that("Peak detection with default parameters works", {
  spectrum <- create_test_spectrum()
  spectrum <- smoothIntensity(spectrum, method = "SavitzkyGolay", halfWindowSize = 10)
  spectrum <- removeBaseline(spectrum, method = "SNIP")

  peaks <- detectPeaks(spectrum, SNR = 3, halfWindowSize = 20)

  expect_s4_class(peaks, "MassPeaks")
  expect_true(length(mass(peaks)) > 0)
  expect_equal(length(mass(peaks)), length(intensity(peaks)))
})

test_that("Peak detection with high SNR finds fewer peaks", {
  spectrum <- create_test_spectrum()
  spectrum <- smoothIntensity(spectrum, method = "SavitzkyGolay")
  spectrum <- removeBaseline(spectrum, method = "SNIP")

  peaks_low_snr <- detectPeaks(spectrum, SNR = 2, halfWindowSize = 20)
  peaks_high_snr <- detectPeaks(spectrum, SNR = 5, halfWindowSize = 20)

  expect_true(length(peaks_low_snr) >= length(peaks_high_snr))
})

# Test Suite: Complete Preprocessing Pipeline
test_that("Complete preprocessing pipeline works", {
  spectrum <- create_test_spectrum()

  # Full pipeline
  processed <- spectrum
  processed <- smoothIntensity(processed, method = "SavitzkyGolay", halfWindowSize = 10)
  processed <- removeBaseline(processed, method = "SNIP")
  processed <- calibrateIntensity(processed, method = "TIC")
  peaks <- detectPeaks(processed, SNR = 3, halfWindowSize = 20)

  expect_s4_class(processed, "MassSpectrum")
  expect_s4_class(peaks, "MassPeaks")
  expect_true(length(peaks) > 0)
})

# Test Suite: Multiple Spectra
test_that("Batch processing multiple spectra works", {
  spectra <- list(
    create_test_spectrum(),
    create_test_spectrum(),
    create_test_spectrum()
  )

  # Batch smoothing
  smoothed <- smoothIntensity(spectra, method = "SavitzkyGolay", halfWindowSize = 10)

  expect_equal(length(smoothed), 3)
  expect_true(all(sapply(smoothed, isMassSpectrum)))
})

test_that("Batch peak detection works", {
  spectra <- list(
    create_test_spectrum(),
    create_test_spectrum(),
    create_test_spectrum()
  )

  # Preprocess
  spectra <- smoothIntensity(spectra, method = "SavitzkyGolay")
  spectra <- removeBaseline(spectra, method = "SNIP")

  # Batch peak detection
  peaks <- detectPeaks(spectra, SNR = 3, halfWindowSize = 20)

  expect_equal(length(peaks), 3)
  expect_true(all(sapply(peaks, function(x) length(x) > 0)))
})

# Test Suite: Edge Cases
test_that("Empty spectrum handling", {
  mass <- numeric(0)
  intensity <- numeric(0)

  expect_error(createMassSpectrum(mass, intensity))
})

test_that("Spectrum with NAs handling", {
  mass <- seq(1000, 2000, by = 1)
  intensity <- rnorm(length(mass), mean = 100, sd = 10)
  intensity[50] <- NA

  expect_error(createMassSpectrum(mass, intensity))
})

test_that("Very noisy spectrum handling", {
  mass <- seq(1000, 5000, by = 1)
  intensity <- rnorm(length(mass), mean = 10, sd = 50)
  intensity[intensity < 0] <- 0

  spectrum <- createMassSpectrum(mass, intensity)
  smoothed <- smoothIntensity(spectrum, method = "SavitzkyGolay")

  expect_s4_class(smoothed, "MassSpectrum")
})

# Print test summary
cat("\n=================================\n")
cat("MALDIquant Preprocessing Tests\n")
cat("=================================\n")
cat("All tests completed.\n")
cat("Run with: testthat::test_file('tests/test_preprocessing.R')\n")
