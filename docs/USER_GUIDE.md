# MALDIquant Analyzer - User Guide

## Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Getting Started](#getting-started)
4. [Workflow](#workflow)
5. [Features](#features)
6. [Troubleshooting](#troubleshooting)

## Introduction

MALDIquant Analyzer is a user-friendly Windows application for analyzing mass spectrometry data. It provides a graphical interface for the powerful MALDIquant R package, making it accessible to users without programming experience.

### Key Features

- Intuitive graphical interface
- Support for multiple file formats (mzML, mzXML, Bruker, CSV)
- Automated preprocessing pipeline
- Interactive visualization
- Batch processing capabilities
- Export results to CSV/Excel

## Installation

### Prerequisites

Before installing MALDIquant Analyzer, ensure you have:

1. **Windows 10 or later** (64-bit)
2. **R (version 4.0 or later)** - Download from [CRAN](https://cran.r-project.org/)

### Installing R

1. Download R from https://cran.r-project.org/bin/windows/base/
2. Run the installer and follow the default installation options
3. Make sure to add R to your system PATH (option during installation)

### Installing MALDIquant Analyzer

1. Download `MALDIquant-Setup-1.0.0.exe`
2. Run the installer
3. Follow the installation wizard
4. Launch the application from the Start Menu or Desktop shortcut

### First Run Setup

On first launch, the application will:

1. Check for required R packages
2. Install missing dependencies automatically
3. This may take 5-10 minutes depending on your internet connection

## Getting Started

### Launching the Application

1. Double-click the MALDIquant Analyzer icon
2. Wait for the loading screen (R server initialization)
3. The main interface will appear when ready

### Interface Overview

The application consists of:

- **Sidebar Panel** (left): Data import and processing controls
- **Main Panel** (right): Visualization and results in tabbed interface
- **Menu Bar** (top): File operations and help

### Main Tabs

1. **Overview**: Welcome screen and application status
2. **Spectra**: Individual spectrum visualization
3. **Peaks**: Detected peaks table and statistics
4. **Comparison**: Overlay multiple spectra
5. **Settings**: Application preferences

## Workflow

### Step 1: Import Data

1. Click "Select Spectra Files" button
2. Browse to your data files
3. Select one or multiple files
4. Supported formats:
   - `.mzML` (standard format)
   - `.mzXML` (standard format)
   - `.txt` or `.csv` (tab-separated: mass, intensity)

### Step 2: Configure Preprocessing

#### Smoothing Options

- **Enable/Disable**: Check "Apply Smoothing"
- **Method**:
  - SavitzkyGolay (recommended for most data)
  - MovingAverage (for noisy data)
- **Half Window Size**: 5-20 (default: 10)

#### Baseline Correction

- **Enable/Disable**: Check "Remove Baseline"
- **Method**:
  - SNIP (recommended, fast)
  - TopHat (for flat baselines)
  - ConvexHull (for varying baselines)
  - Median (simple method)

### Step 3: Peak Detection

Configure peak detection parameters:

- **Signal-to-Noise Ratio (SNR)**: 2-5 (default: 3)
  - Higher = fewer, more significant peaks
  - Lower = more peaks, may include noise
- **Half Window Size**: 10-50 (default: 20)
  - Larger = smoother peak detection

### Step 4: Process Data

1. Click the **"Process Data"** button
2. Wait for processing (progress indicator shown)
3. Results will appear in the Spectra and Peaks tabs

### Step 5: Analyze Results

#### Spectra Tab

- View processed spectra
- Select spectrum index to view different samples
- Toggle peak markers on/off
- Interactive zoom and pan (Plotly controls)

#### Peaks Tab

- Table of all detected peaks across all spectra
- Columns: Spectrum ID, Mass (m/z), Intensity, SNR
- Sortable and searchable
- Peak statistics summary

#### Comparison Tab

- Overlay multiple spectra for comparison
- Select which spectra to display
- Useful for comparing samples

### Step 6: Export Results

#### Download Detected Peaks

1. Click **"Download Results"** button
2. Save CSV file with peak data
3. Columns included: Spectrum, Mass, Intensity, SNR

#### Download Plots

1. Click **"Download Plot"** button
2. Save current spectrum view as PNG
3. High-resolution (1200x800, 150 DPI)

## Features

### Batch Processing

Process multiple spectra files at once:

1. Select multiple files during import
2. All files processed with same parameters
3. View individual results by spectrum index

### Interactive Visualization

- **Zoom**: Drag to select area
- **Pan**: Shift + drag
- **Reset**: Double-click
- **Hover**: View exact m/z and intensity values

### Data Quality Indicators

The application provides:

- Number of spectra loaded
- Number of peaks detected per spectrum
- Average, min, max peaks
- Processing status messages

### Settings Customization

In the Settings tab:

#### Plot Settings

- Change line colors
- Adjust peak marker colors
- Modify plot height

#### Export Settings

- Choose export format (CSV, Excel, RData)

#### Advanced Options

- Verbose console output
- Reset all settings to defaults

## Troubleshooting

### Application won't start

**Problem**: Loading screen appears but application doesn't load

**Solutions**:
1. Check if R is installed: Open Command Prompt, type `R --version`
2. Reinstall R if needed
3. Check Windows Event Viewer for error messages
4. Try running as Administrator

### R packages installation failed

**Problem**: Error message about missing packages

**Solutions**:
1. Open R console directly
2. Run: `install.packages(c("shiny", "MALDIquant", "MALDIquantForeign"))`
3. Restart the application

### Files won't import

**Problem**: Selected files don't appear or import fails

**Solutions**:
1. Check file format is supported
2. Ensure files are not corrupted
3. For CSV/TXT files, verify format:
   - Tab-separated
   - Two columns: mass and intensity
   - Header row: "mass\tintensity"

### Processing takes too long

**Problem**: Processing hangs or takes excessive time

**Solutions**:
1. Reduce number of spectra
2. Increase SNR threshold (fewer peaks)
3. Check if file sizes are reasonable (<100MB per file)
4. Close other applications to free memory

### Peak detection not working

**Problem**: No peaks detected or too many/few peaks

**Solutions**:
1. Adjust SNR parameter:
   - Too high: No peaks detected → Decrease SNR
   - Too low: Too many noise peaks → Increase SNR
2. Check preprocessing settings:
   - Enable baseline correction
   - Try different baseline methods
3. Verify data quality in raw files

### Export failed

**Problem**: Download buttons don't work

**Solutions**:
1. Ensure processing completed successfully
2. Check available disk space
3. Verify write permissions in download folder
4. Try changing export format in Settings

### Memory issues

**Problem**: Application crashes with large datasets

**Solutions**:
1. Process fewer files at once
2. Increase system RAM
3. Close other applications
4. Reduce preprocessing steps

### Application crashes

**Problem**: Unexpected application closure

**Solutions**:
1. Check Windows Event Viewer logs
2. Update R to latest version
3. Reinstall application
4. Report issue with error logs

## Tips and Best Practices

### Data Preparation

1. **Organize files**: Keep spectra files in dedicated folders
2. **Naming convention**: Use descriptive filenames
3. **Backup**: Always keep original data files

### Parameter Optimization

1. **Start conservative**: Begin with default parameters
2. **Iterative refinement**: Adjust based on results
3. **Document settings**: Note successful parameter combinations

### Quality Control

1. **Visual inspection**: Always check spectra plots
2. **Replicate processing**: Process same files multiple times to verify
3. **Export settings**: Save parameter configurations for reproducibility

### Performance

1. **Batch by similarity**: Group similar samples together
2. **Sequential processing**: Don't overload with too many files
3. **Regular saves**: Export results periodically

## Keyboard Shortcuts

- `Ctrl+O`: Open files dialog
- `Ctrl+Q`: Quit application
- `F11`: Toggle fullscreen
- `Ctrl+R`: Reload interface
- `Ctrl++`: Zoom in
- `Ctrl+-`: Zoom out

## Support and Resources

### Documentation

- MALDIquant package: https://github.com/sgibb/MALDIquant
- User manual: `docs/` folder in installation directory

### Reporting Issues

When reporting problems, include:

1. Application version
2. R version (`R --version`)
3. Error messages (screenshots)
4. Steps to reproduce
5. Sample data (if possible)

### Contact

For support and questions:
- GitHub Issues: [Project repository]
- Email: [Support email]

## Appendix

### Supported File Formats

| Format | Extension | Description |
|--------|-----------|-------------|
| mzML | .mzML | Standard mass spec format |
| mzXML | .mzXML | Standard mass spec format |
| CSV | .csv | Tab-separated text file |
| TXT | .txt | Tab-separated text file |

### Processing Methods

#### Smoothing Methods

- **SavitzkyGolay**: Polynomial smoothing, preserves peak shape
- **MovingAverage**: Simple averaging, good for noisy data

#### Baseline Methods

- **SNIP**: Statistics-sensitive nonlinear iterative peak-clipping
- **TopHat**: Morphological filter
- **ConvexHull**: Convex hull algorithm
- **Median**: Simple median-based removal

### Version History

- **v1.0.0** (2024-10): Initial release
  - Basic preprocessing pipeline
  - Peak detection
  - Interactive visualization
  - Windows desktop application

---

**Last Updated**: October 2024
**Application Version**: 1.0.0
