Sample Data for MALDIquant Analyzer
====================================

This folder contains sample mass spectrometry data files for testing the application.

File Formats Supported:
-----------------------

1. mzML (.mzML)
   - Standard XML-based format
   - Widely supported by mass spec instruments

2. mzXML (.mzXML)
   - Legacy XML format
   - Still commonly used

3. Text/CSV (.txt, .csv)
   - Tab-separated format
   - Two columns: mass, intensity
   - Header row required: "mass\tintensity"

Example CSV Format:
-------------------

mass	intensity
1000.5	150.2
1001.0	145.8
1001.5	152.1
...

Creating Test Data:
-------------------

You can generate sample data using R:

```r
library(MALDIquant)
library(MALDIquantForeign)

# Create synthetic spectrum
mass <- seq(1000, 5000, by = 0.5)
intensity <- rnorm(length(mass), mean = 100, sd = 20)

# Add some peaks
peaks_mass <- c(1500, 2000, 2500, 3000, 3500)
for (pm in peaks_mass) {
  idx <- which.min(abs(mass - pm))
  intensity[idx] <- intensity[idx] + 500
}

# Create spectrum object
spectrum <- createMassSpectrum(mass, intensity)

# Export as mzML
exportMzMl(spectrum, "example_spectrum.mzML")

# Or export as CSV
df <- data.frame(mass = mass(spectrum), intensity = intensity(spectrum))
write.table(df, "example_spectrum.txt", sep = "\t", row.names = FALSE)
```

Using Sample Data:
------------------

1. Launch MALDIquant Analyzer
2. Click "Select Spectra Files"
3. Navigate to this folder
4. Select sample files
5. Click "Process Data"

Tips:
-----

- Start with small files (< 10MB) to test functionality
- Use multiple files to test batch processing
- Verify file format before importing
- Keep original data backed up

For more information, see the User Guide in the docs/ folder.
