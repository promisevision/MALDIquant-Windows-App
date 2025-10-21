# Quick Start Guide - MALDIquant Windows Application

## For Developers

### Prerequisites

1. **Install R** (version 4.0 or later)
   - Download: https://cran.r-project.org/bin/windows/base/
   - During installation: **Check "Add R to PATH"**

2. **Install Node.js** (version 14 or later)
   - Download: https://nodejs.org/
   - Use LTS version recommended

### Setup (5 minutes)

#### Step 1: Install R Packages

Open R console or RStudio and run:

```r
source("R-app/install_packages.R")
```

This will install:
- shiny
- MALDIquant
- MALDIquantForeign
- plotly
- DT
- bslib
- colourpicker

**Note**: First-time installation may take 5-10 minutes.

#### Step 2: Install Node.js Dependencies

Open terminal/command prompt:

```bash
cd electron
npm install
```

This installs:
- electron
- electron-builder
- electron-store

### Running the Application

#### Option A: Development Mode (Shiny in Browser)

**Best for**: Quick testing of UI changes

```r
# In R console
library(shiny)
runApp("R-app")
```

Application opens in browser at http://127.0.0.1:XXXX

#### Option B: Desktop Mode (Electron + Shiny)

**Best for**: Testing full application

```bash
cd electron
npm start
```

Application launches as desktop window.

### Testing the Application

1. **Launch** the application (either mode)
2. **Import data**:
   - Use sample files from `data/sample-data/`
   - Or create test data (see below)
3. **Configure preprocessing**:
   - Enable smoothing (default: SavitzkyGolay)
   - Enable baseline removal (default: SNIP)
4. **Set peak detection**:
   - SNR: 3 (default)
   - Half window size: 20 (default)
5. **Click "Process Data"**
6. **View results** in Spectra and Peaks tabs

### Creating Test Data

```r
# In R console
library(MALDIquant)

# Create synthetic spectrum
mass <- seq(1000, 5000, by = 0.5)
intensity <- rnorm(length(mass), mean = 100, sd = 20)

# Add peaks
peaks_mass <- c(1500, 2000, 2500, 3000, 3500)
for (pm in peaks_mass) {
  idx <- which.min(abs(mass - pm))
  intensity[(idx-20):(idx+20)] <- intensity[(idx-20):(idx+20)] + 500
}

# Create and save
spectrum <- createMassSpectrum(mass, intensity)

# Save as CSV
df <- data.frame(mass = mass, intensity = intensity)
write.table(df, "data/sample-data/test_spectrum.txt",
            sep = "\t", row.names = FALSE)
```

### Building for Distribution

#### Create Windows Installer

```bash
cd electron
npm run build
```

Output: `electron/dist/MALDIquant-Setup-1.0.0.exe`

**Size**: ~150-250MB (includes dependencies)

#### Test the Installer

1. Navigate to `electron/dist/`
2. Run `MALDIquant-Setup-1.0.0.exe`
3. Follow installation wizard
4. Launch from Start Menu or Desktop

## For End Users

### Installation

1. **Download** `MALDIquant-Setup-1.0.0.exe`
2. **Double-click** to run installer
3. **Follow** installation wizard
4. **Launch** from Start Menu or Desktop shortcut

### First Launch

1. Application may take 30-60 seconds to start (first time)
2. R packages are initialized
3. Shiny server starts
4. Main window appears

### Basic Usage

#### 1. Import Your Data

- Click **"Select Spectra Files"**
- Choose one or more files:
  - `.mzML` (recommended)
  - `.mzXML`
  - `.txt` or `.csv` (tab-separated: mass, intensity)

#### 2. Configure Settings (Optional)

**Smoothing**:
- Method: SavitzkyGolay (recommended)
- Half Window Size: 10 (default)

**Baseline Correction**:
- Method: SNIP (recommended)

**Peak Detection**:
- SNR: 3 (higher = fewer peaks)
- Half Window Size: 20

#### 3. Process Data

- Click **"Process Data"** button
- Wait for progress indicator
- Results appear automatically

#### 4. View Results

**Spectra Tab**:
- Interactive plot of processed spectrum
- Zoom, pan, hover for details
- Select different spectra with index selector

**Peaks Tab**:
- Table of all detected peaks
- Sort and search capabilities
- Peak statistics summary

**Comparison Tab**:
- Overlay multiple spectra
- Select spectra to compare

#### 5. Export Results

**Download Results**:
- CSV file with peak data
- Columns: Spectrum, Mass, Intensity, SNR

**Download Plot**:
- High-resolution PNG image
- Current spectrum view

### Supported File Formats

| Format | Extension | Description |
|--------|-----------|-------------|
| mzML | `.mzML` | Standard XML format |
| mzXML | `.mzXML` | Legacy XML format |
| CSV/Text | `.txt`, `.csv` | Tab-separated text |

**CSV Format Requirements**:
```
mass	intensity
1000.5	150.2
1001.0	145.8
...
```

### Keyboard Shortcuts

- `Ctrl+O`: Open files
- `Ctrl+Q`: Quit
- `F11`: Fullscreen
- `Ctrl+R`: Reload

### Troubleshooting

#### Application won't start

**Solution**:
1. Check R is installed: Open Command Prompt, type `R --version`
2. If not found, install R from https://cran.r-project.org/
3. Restart application

#### No peaks detected

**Solution**:
1. Lower SNR threshold (try 2 instead of 3)
2. Enable baseline correction
3. Check data quality (view raw spectrum)

#### Processing takes too long

**Solution**:
1. Process fewer files at once
2. Use smaller files (<50MB)
3. Close other applications

### Getting Help

- **User Guide**: `docs/USER_GUIDE.md`
- **Developer Guide**: `docs/DEVELOPER_GUIDE.md`
- **Sample Data**: `data/sample-data/`

## Common Workflows

### Workflow 1: Single Spectrum Analysis

1. Import one spectrum file
2. Use default preprocessing settings
3. Click "Process Data"
4. View in Spectra tab
5. Download results

**Time**: 1-2 minutes

### Workflow 2: Batch Processing

1. Import multiple files (5-10 recommended)
2. Configure preprocessing once
3. Click "Process Data"
4. View individual results by changing spectrum index
5. Download combined results table

**Time**: 5-10 minutes

### Workflow 3: Parameter Optimization

1. Import one test file
2. Process with default settings
3. Check results in Peaks tab
4. Adjust SNR if needed:
   - Too many peaks → Increase SNR
   - Too few peaks → Decrease SNR
5. Reprocess
6. Repeat until satisfied
7. Apply settings to full dataset

**Time**: 10-15 minutes

## Development Roadmap

### Current Version (1.0.0)

- ✅ Basic preprocessing pipeline
- ✅ Peak detection
- ✅ Interactive visualization
- ✅ Windows desktop application

### Planned Features (Future)

- [ ] Bruker raw file support
- [ ] Advanced peak alignment
- [ ] Statistical analysis tools
- [ ] Batch export to Excel
- [ ] Custom preprocessing templates
- [ ] Multi-language support

## Additional Resources

### MALDIquant Package

- GitHub: https://github.com/sgibb/MALDIquant
- Documentation: https://strimmerlab.github.io/software/maldiquant/

### Shiny Framework

- Official Site: https://shiny.rstudio.com/
- Gallery: https://shiny.rstudio.com/gallery/

### Electron

- Official Site: https://www.electronjs.org/
- Documentation: https://www.electronjs.org/docs

## Version Information

- **Application Version**: 1.0.0
- **MALDIquant Version**: Check with `packageVersion("MALDIquant")`
- **R Version**: Check with `R.version.string`
- **Electron Version**: Check `electron/package.json`

---

**Questions?** See full documentation in `docs/` folder.

**Issues?** Check troubleshooting sections or create GitHub issue.
