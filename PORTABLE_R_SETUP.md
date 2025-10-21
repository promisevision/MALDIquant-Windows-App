# Portable R Setup Guide

This guide explains how to bundle Portable R with the MALDIquant application so users do NOT need to install R separately.

## Overview

The application now supports two modes:
1. **With Bundled R** - R is included in the installer (NO R installation needed)
2. **Without Bundled R** - Users must install R separately (fallback mode)

## Setup Steps

### Step 1: Download Portable R

1. Go to https://cran.r-project.org/bin/windows/base/
2. Download the latest R installer (e.g., R-4.4.2-win.exe)
3. Run the installer
4. During installation, note the installation path (e.g., `C:\Program Files\R\R-4.4.2`)

### Step 2: Copy R to Project

Copy the entire R installation to the project:

```bash
# Create R-portable directory in project root
mkdir R-portable

# Copy R installation
# Windows:
xcopy "C:\Program Files\R\R-4.4.2\*" "R-portable\" /E /I /H

# Or use File Explorer:
# Copy C:\Program Files\R\R-4.4.2\
# Paste to: MALDIquant-Windows-App\R-portable\
```

### Step 3: Install Required R Packages

Run R and install packages to the portable R:

```r
# Set library path to portable R
.libPaths("./R-portable/library")

# Install required packages
install.packages(c(
  "shiny",
  "MALDIquant",
  "MALDIquantForeign",
  "plotly",
  "DT",
  "bslib",
  "colourpicker"
), lib = "./R-portable/library")
```

Or run the install script:

```bash
cd R-portable/bin/x64
Rscript.exe -e ".libPaths('../../library'); source('../../../R-app/install_packages.R')"
```

### Step 4: Project Structure

Your project should now look like this:

```
MALDIquant-Windows-App/
├── electron/
│   ├── main.js (updated to check for portable R)
│   ├── package.json (configured to bundle R-portable)
│   └── ...
├── R-app/
│   ├── app.R
│   └── ...
├── R-portable/          ← NEW!
│   ├── bin/
│   │   └── x64/
│   │       └── Rscript.exe
│   ├── library/         ← All R packages here
│   │   ├── shiny/
│   │   ├── MALDIquant/
│   │   └── ...
│   └── ...
└── data/
```

### Step 5: Build the Application

```bash
cd electron
npm install
npm run build
```

This will create an installer in `electron/dist/` that includes:
- The Electron application
- All R files (R-portable/)
- All Shiny app files (R-app/)

**Installer size:** Approximately 300-500 MB

## How It Works

1. When the app starts, `main.js` checks for bundled R first:
   ```javascript
   // Check: resources/R-portable/bin/x64/Rscript.exe
   ```

2. If bundled R is found, it uses that (NO system R needed)

3. If bundled R is NOT found, it searches for system-installed R

4. If neither is found, it shows an error asking user to install R

## Distribution

### With Bundled R (Recommended)
- **File:** `MALDIquant-Analyzer-Setup-1.0.0.exe` (400-500 MB)
- **User Requirements:** NONE - just run the installer
- **Advantages:** Works out of the box, no R installation needed

### Without Bundled R (Smaller package)
- Delete the `R-portable/` folder before building
- **File:** `MALDIquant-Analyzer-Setup-1.0.0.exe` (50-100 MB)
- **User Requirements:** Must install R separately
- **Advantages:** Smaller download size

## Testing

### Test with Bundled R:
```bash
cd electron
npm start
# Check console output: "✓ Found bundled portable R at: ..."
```

### Test without Bundled R:
```bash
# Temporarily rename R-portable folder
mv R-portable R-portable-backup

cd electron
npm start
# Check console output: "No bundled portable R found, searching for system R..."

# Restore
mv R-portable-backup R-portable
```

## Troubleshooting

### Issue: Bundled R not found after installation
- Check: `C:\Program Files\MALDIquant Analyzer\resources\R-portable\bin\x64\Rscript.exe`
- If missing, the build didn't include R-portable folder

### Issue: R packages missing
- Run the package installation script again in R-portable
- Make sure packages are in `R-portable/library/`

### Issue: Build takes very long
- Normal - bundling 300-500 MB of R files takes time
- Use `npm run pack` for faster testing (creates unpacked directory)

## File Size Breakdown

- R-portable: ~300 MB
  - R base: ~200 MB
  - Packages: ~100 MB
- Electron app: ~50 MB
- R-app (Shiny): ~1 MB
- **Total: ~350-400 MB**

## Notes

- Portable R is Windows x64 only
- Users on 32-bit Windows must install R separately
- Portable R increases installer size significantly
- Consider offering both bundled and non-bundled versions
