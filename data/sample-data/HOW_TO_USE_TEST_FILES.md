# How to Use Test Files

## Available Test Files

Three sample mass spectrometry data files are provided:

### 1. sample_spectrum_1.txt
- **Peaks**: 5 peaks at m/z 1500, 2000, 2500, 3000, 3500
- **Characteristics**: Clean spectrum, moderate peak heights
- **Best for**: Basic functionality testing

### 2. sample_spectrum_2.txt
- **Peaks**: 6 peaks at m/z 1250, 1750, 2250, 2750, 3250, 3750
- **Characteristics**: Different peak positions, varying heights
- **Best for**: Testing peak detection accuracy

### 3. sample_spectrum_3.txt
- **Peaks**: 6 peaks at m/z 1400, 1900, 2400, 2900, 3400, 3900
- **Characteristics**: Another peak pattern for comparison
- **Best for**: Multi-spectrum analysis and overlay comparison

## File Format

All files are **tab-separated text files** with two columns:

```
mass	intensity
1000.0	95.234
1000.5	98.123
...
```

- **Column 1**: mass (m/z values from 1000 to 5000)
- **Column 2**: intensity (signal intensity with noise)

## Quick Start Testing

### Step 1: Open Application

```bash
# In terminal
cd electron
npm start

# Or open in browser
start http://127.0.0.1:3838
```

### Step 2: Import Test File

1. Click **"Select Spectra Files"** button
2. Navigate to: `MALDIquant-Windows-App/data/sample-data/`
3. Select **`sample_spectrum_1.txt`**
4. Click **Open**

### Step 3: Configure Settings (Use Defaults)

Default settings are good for these files:
- ✓ Apply Smoothing: **ON**
  - Method: **SavitzkyGolay**
  - Half Window Size: **10**
- ✓ Remove Baseline: **ON**
  - Method: **SNIP**
- Peak Detection:
  - SNR: **3**
  - Half Window Size: **20**

### Step 4: Process Data

1. Click **"Process Data"** button
2. Wait 5-10 seconds
3. Processing complete!

### Step 5: View Results

**Spectra Tab:**
- See processed spectrum plot
- Zoom: drag to select area
- Pan: Shift + drag
- Reset: double-click

**Peaks Tab:**
- Table shows detected peaks
- Expected: 5 peaks for sample_spectrum_1.txt
- Columns: Spectrum ID, Mass, Intensity, SNR

## Expected Results

### sample_spectrum_1.txt
Should detect **5 peaks** near:
- m/z 1500 (intensity ~580)
- m/z 2000 (intensity ~620)
- m/z 2500 (intensity ~550)
- m/z 3000 (intensity ~590)
- m/z 3500 (intensity ~570)

### sample_spectrum_2.txt
Should detect **6 peaks** near:
- m/z 1250 (intensity ~480)
- m/z 1750 (intensity ~720)
- m/z 2250 (intensity ~650)
- m/z 2750 (intensity ~690)
- m/z 3250 (intensity ~620)
- m/z 3750 (intensity ~590)

### sample_spectrum_3.txt
Should detect **6 peaks** near:
- m/z 1400 (intensity ~540)
- m/z 1900 (intensity ~670)
- m/z 2400 (intensity ~610)
- m/z 2900 (intensity ~640)
- m/z 3400 (intensity ~580)
- m/z 3900 (intensity ~560)

## Advanced Testing

### Test 1: Batch Processing

Import all three files at once:
1. Click "Select Spectra Files"
2. Hold **Ctrl** and select all three .txt files
3. Click "Process Data"
4. View each spectrum using the index selector

### Test 2: Compare Spectra

1. Import multiple files
2. Process data
3. Go to **"Comparison"** tab
4. Select spectra to overlay
5. Compare peak patterns visually

### Test 3: Adjust Parameters

Try different settings to see effects:

**Low SNR (SNR = 2):**
- Detects more peaks (including noise)
- Good for finding weak signals

**High SNR (SNR = 5):**
- Detects fewer, more significant peaks
- Reduces false positives

**No Smoothing:**
- Uncheck "Apply Smoothing"
- See noisier spectrum
- Harder to detect peaks

**No Baseline Correction:**
- Uncheck "Remove Baseline"
- Peaks sit on elevated baseline
- May affect quantification

### Test 4: Export Results

1. Process data
2. Click **"Download Results"**
3. Save CSV file
4. Open in Excel/spreadsheet to verify peak data

## Troubleshooting Test Files

### No Peaks Detected

**Problem**: Peak table is empty

**Solutions:**
- Lower SNR (try 2 instead of 3)
- Ensure "Remove Baseline" is checked
- Check you're viewing the correct spectrum index

### Too Many Peaks

**Problem**: 20+ peaks detected (mostly noise)

**Solutions:**
- Increase SNR (try 4 or 5)
- Check smoothing is enabled
- Increase peak half window size to 30

### File Won't Import

**Problem**: Error when selecting file

**Solutions:**
- Ensure file is in correct format (tab-separated)
- Check file has header row: `mass	intensity`
- Verify file path has no special characters
- Try copying file to a simpler path (e.g., C:\temp\)

### Plot Not Showing

**Problem**: Blank plot area

**Solutions:**
- Wait for processing to complete
- Check Spectra tab is selected
- Try refreshing: Ctrl+R
- Check spectrum index is valid (1 to number of files)

## Performance Expectations

### Processing Time (per file):
- **Sample files**: 5-10 seconds
- Smoothing: ~2s
- Baseline correction: ~2s
- Peak detection: ~3s
- Plotting: ~2s

### File Sizes:
- sample_spectrum_1.txt: ~2.5 KB
- sample_spectrum_2.txt: ~2.5 KB
- sample_spectrum_3.txt: ~2.5 KB

All files are small and process quickly.

## Success Criteria

Your testing is successful if:
- ✓ Files import without errors
- ✓ Processing completes in <30 seconds
- ✓ Correct number of peaks detected (±1)
- ✓ Peak positions match expected m/z (±10)
- ✓ Plots display correctly
- ✓ Can export results to CSV

## Next Steps

After successful testing with sample files:

1. **Try your own data**: Import real mzML or mzXML files
2. **Optimize parameters**: Adjust settings for your data type
3. **Batch process**: Analyze multiple samples together
4. **Export results**: Save peak data for further analysis

## File Locations

All test files are in:
```
MALDIquant-Windows-App/data/sample-data/
├── sample_spectrum_1.txt  ← Use this first
├── sample_spectrum_2.txt
├── sample_spectrum_3.txt
└── HOW_TO_USE_TEST_FILES.md  ← This file
```

## Quick Reference Commands

```bash
# Start application
cd electron && npm start

# Open in browser
start http://127.0.0.1:3838

# Generate more test data (in R)
source("data/sample-data/generate_test_data.R")

# Quick single test file (in R)
source("data/sample-data/quick_generate.R")
```

---

**Happy Testing!** 🧪🔬

For issues, see: [TROUBLESHOOTING.md](../../TROUBLESHOOTING.md)
