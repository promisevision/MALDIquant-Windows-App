# Generate Test Data for MALDIquant Application
# This script creates sample mass spectrometry data files

library(MALDIquant)

cat("Generating test data...\n")

# Function to create a test spectrum
create_test_spectrum <- function(n_peaks = 5, noise_level = 20, baseline = 50) {
  # Mass range: 1000 to 5000 m/z
  mass <- seq(1000, 5000, by = 0.5)

  # Base intensity with noise
  intensity <- rnorm(length(mass), mean = 100, sd = noise_level)

  # Add baseline
  baseline_signal <- baseline + 0.01 * (mass - 1000)
  intensity <- intensity + baseline_signal

  # Add peaks at regular intervals
  peak_positions <- seq(1500, 4500, length.out = n_peaks)

  for (pm in peak_positions) {
    idx <- which.min(abs(mass - pm))
    # Create Gaussian peak
    peak_width <- 20
    peak_height <- rnorm(1, mean = 500, sd = 100)
    for (i in (idx-peak_width):(idx+peak_width)) {
      if (i > 0 && i <= length(intensity)) {
        distance <- mass[i] - pm
        intensity[i] <- intensity[i] + peak_height * exp(-(distance^2) / 10)
      }
    }
  }

  # Ensure no negative intensities
  intensity[intensity < 0] <- 0

  return(list(mass = mass, intensity = intensity))
}

# Create output directory if it doesn't exist
output_dir <- "."
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Generate multiple test files with different characteristics
cat("Creating test files...\n\n")

# Test 1: Clean spectrum with 5 peaks
cat("1. Creating clean_spectrum.txt (5 peaks, low noise)...\n")
spectrum1 <- create_test_spectrum(n_peaks = 5, noise_level = 10, baseline = 30)
df1 <- data.frame(mass = spectrum1$mass, intensity = spectrum1$intensity)
write.table(df1, file.path(output_dir, "clean_spectrum.txt"),
            sep = "\t", row.names = FALSE, quote = FALSE)
cat("   Saved: clean_spectrum.txt\n")

# Test 2: Noisy spectrum with 7 peaks
cat("2. Creating noisy_spectrum.txt (7 peaks, high noise)...\n")
spectrum2 <- create_test_spectrum(n_peaks = 7, noise_level = 40, baseline = 60)
df2 <- data.frame(mass = spectrum2$mass, intensity = spectrum2$intensity)
write.table(df2, file.path(output_dir, "noisy_spectrum.txt"),
            sep = "\t", row.names = FALSE, quote = FALSE)
cat("   Saved: noisy_spectrum.txt\n")

# Test 3: High baseline spectrum
cat("3. Creating high_baseline_spectrum.txt (5 peaks, high baseline)...\n")
spectrum3 <- create_test_spectrum(n_peaks = 5, noise_level = 15, baseline = 100)
df3 <- data.frame(mass = spectrum3$mass, intensity = spectrum3$intensity)
write.table(df3, file.path(output_dir, "high_baseline_spectrum.txt"),
            sep = "\t", row.names = FALSE, quote = FALSE)
cat("   Saved: high_baseline_spectrum.txt\n")

# Test 4: Simple spectrum with 3 peaks
cat("4. Creating simple_spectrum.txt (3 peaks, minimal noise)...\n")
spectrum4 <- create_test_spectrum(n_peaks = 3, noise_level = 5, baseline = 20)
df4 <- data.frame(mass = spectrum4$mass, intensity = spectrum4$intensity)
write.table(df4, file.path(output_dir, "simple_spectrum.txt"),
            sep = "\t", row.names = FALSE, quote = FALSE)
cat("   Saved: simple_spectrum.txt\n")

# Test 5: Complex spectrum with many peaks
cat("5. Creating complex_spectrum.txt (10 peaks, moderate noise)...\n")
spectrum5 <- create_test_spectrum(n_peaks = 10, noise_level = 25, baseline = 40)
df5 <- data.frame(mass = spectrum5$mass, intensity = spectrum5$intensity)
write.table(df5, file.path(output_dir, "complex_spectrum.txt"),
            sep = "\t", row.names = FALSE, quote = FALSE)
cat("   Saved: complex_spectrum.txt\n")

# Create summary file
cat("\n6. Creating test_data_summary.txt...\n")
summary_text <- "Test Data Summary
================

This folder contains sample mass spectrometry data files for testing the MALDIquant application.

Files:
------

1. clean_spectrum.txt
   - 5 peaks
   - Low noise level
   - Low baseline
   - Good for testing basic functionality

2. noisy_spectrum.txt
   - 7 peaks
   - High noise level
   - Moderate baseline
   - Good for testing noise reduction and peak detection robustness

3. high_baseline_spectrum.txt
   - 5 peaks
   - Moderate noise
   - High baseline
   - Good for testing baseline correction algorithms

4. simple_spectrum.txt
   - 3 peaks
   - Minimal noise
   - Low baseline
   - Quick test file for basic operations

5. complex_spectrum.txt
   - 10 peaks
   - Moderate noise
   - Moderate baseline
   - Good for testing peak detection with many peaks

File Format:
------------
All files are tab-separated text files with two columns:
- Column 1: mass (m/z values)
- Column 2: intensity (signal intensity)

Usage:
------
1. Launch MALDIquant Analyzer
2. Click 'Select Spectra Files'
3. Choose one or more test files
4. Configure preprocessing options
5. Click 'Process Data'
6. View results in Spectra and Peaks tabs

Recommended Test Workflow:
--------------------------
1. Start with simple_spectrum.txt to verify basic functionality
2. Try clean_spectrum.txt with default settings
3. Test noisy_spectrum.txt with smoothing enabled
4. Test high_baseline_spectrum.txt with baseline correction
5. Test complex_spectrum.txt with adjusted SNR settings

Generated: $(date)
"

cat(summary_text, file = file.path(output_dir, "test_data_summary.txt"))
cat("   Saved: test_data_summary.txt\n")

# Print statistics
cat("\n")
cat("==========================================\n")
cat("Test Data Generation Complete!\n")
cat("==========================================\n")
cat("Total files created: 6\n")
cat("Output directory:", normalizePath(output_dir), "\n")
cat("\nFile details:\n")
for (file in c("clean_spectrum.txt", "noisy_spectrum.txt", "high_baseline_spectrum.txt",
               "simple_spectrum.txt", "complex_spectrum.txt")) {
  if (file.exists(file.path(output_dir, file))) {
    size <- file.info(file.path(output_dir, file))$size
    cat(sprintf("  %s: %.2f KB\n", file, size / 1024))
  }
}
cat("\nYou can now use these files to test the MALDIquant application.\n")
cat("==========================================\n")
