# Troubleshooting Guide - MALDIquant Windows App

## Common Error: Exit Code 3221225477

### Problem
```
R process exited with code 3221225477
```

This error (0xC0000005 - Access Violation) typically means R cannot be found or executed properly.

---

## Quick Fix Steps

### Step 1: Verify R Installation

Open **Command Prompt** (cmd) and run:

```bash
R --version
```

**Expected output:**
```
R version 4.x.x (...)
```

**If you get an error:**
- R is not installed, OR
- R is not in your PATH

---

### Step 2: Install R (If Not Installed)

1. Download R from: **https://cran.r-project.org/bin/windows/base/**
2. Run the installer
3. **IMPORTANT**: During installation, check the box:
   - ☑️ **"Add R to PATH"**
4. Complete installation
5. **Restart your computer**

---

### Step 3: Manually Add R to PATH (If Already Installed)

If R is installed but not in PATH:

#### Method A: Windows Settings

1. Open **Start Menu** → Search "Environment Variables"
2. Click **"Edit the system environment variables"**
3. Click **"Environment Variables"** button
4. Under **"System variables"**, find **Path**, click **Edit**
5. Click **New** and add:
   ```
   C:\Program Files\R\R-4.3.2\bin
   ```
   (Replace `R-4.3.2` with your R version)
6. Click **OK** on all dialogs
7. **Restart Command Prompt** and test: `R --version`

#### Method B: PowerShell (Quick)

Open **PowerShell as Administrator** and run:

```powershell
# Find R installation
$rPath = "C:\Program Files\R"
$rVersions = Get-ChildItem $rPath -Directory | Where-Object { $_.Name -like "R-*" } | Sort-Object -Descending
$latestR = $rVersions[0].FullName

# Add to PATH
$binPath = "$latestR\bin"
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$binPath", [EnvironmentVariableTarget]::Machine)

Write-Host "Added R to PATH: $binPath"
Write-Host "Please restart your terminal"
```

---

### Step 4: Install R Packages

After R is properly installed, install required packages:

#### Method A: Using provided script (Recommended)

Open **R Console** (not Command Prompt):

```r
# Navigate to project directory
setwd("C:/path/to/MALDIquant-Windows-App")

# Run installation script
source("R-app/install_packages.R")
```

#### Method B: Manual installation

In **R Console**:

```r
# Install required packages
install.packages(c(
  "shiny",
  "MALDIquant",
  "MALDIquantForeign",
  "plotly",
  "DT",
  "bslib",
  "colourpicker"
), dependencies = TRUE)
```

**Installation time**: 5-10 minutes

---

### Step 5: Verify Installation

In **R Console**:

```r
# Test loading packages
library(shiny)
library(MALDIquant)
library(plotly)

# Should load without errors
# If successful, you'll see:
# (no error messages)
```

---

### Step 6: Restart Application

```bash
cd electron
npm start
```

---

## Detailed Diagnostics

### Check R Installation Paths

Run this in **Command Prompt**:

```bash
where R
```

**Expected output:**
```
C:\Program Files\R\R-4.3.2\bin\R.exe
```

**If you see multiple paths**, the first one will be used.

---

### Check R from Node.js/Electron

Create a test file `test-r.js`:

```javascript
const { execSync } = require('child_process');

try {
  const output = execSync('R --version', { encoding: 'utf8' });
  console.log('R found!');
  console.log(output);
} catch (e) {
  console.error('R not found:', e.message);
}
```

Run:
```bash
node test-r.js
```

---

### Check R Package Installation

In **R Console**:

```r
# List all installed packages
installed.packages()[, c("Package", "Version")]

# Check specific packages
packageVersion("shiny")
packageVersion("MALDIquant")

# Check library paths
.libPaths()
```

---

## Platform-Specific Issues

### Windows 11

Some users report issues with R on Windows 11. Solutions:

1. **Run as Administrator**: Right-click the app → Run as administrator
2. **Disable SmartScreen**: May block R execution
3. **Check antivirus**: Whitelist R and the app

### MINGW/Git Bash

If using MINGW (like in your error):

```bash
# In MINGW, use winpty
winpty R --version

# Or switch to Command Prompt (cmd) or PowerShell
```

---

## Advanced Troubleshooting

### Enable Debug Logging

Edit `electron/main.js`, add at the top:

```javascript
// Enable debug mode
process.env.DEBUG = 'true';
```

Then check console output for detailed R search process.

### Manually Test R Command

In **Command Prompt**:

```bash
# Test the exact command Electron uses
R --vanilla --quiet -e "cat('R is working\n')"
```

**Expected output:**
```
R is working
```

### Check for DLL Dependencies

R requires certain DLLs. Check if they're present:

```bash
cd "C:\Program Files\R\R-4.3.2\bin\x64"
dir *.dll
```

Should see: `R.dll`, `Rblas.dll`, `Rgraphapp.dll`, etc.

---

## Still Not Working?

### Collect Diagnostic Information

Run these commands and save output:

```bash
# System info
systeminfo

# R version and path
R --version
where R

# Node/npm versions
node --version
npm --version

# Check R from PowerShell
powershell -Command "Get-Command R"

# Registry check (R installation)
reg query "HKEY_LOCAL_MACHINE\Software\R-core\R" /v InstallPath
```

### Try Portable R

1. Download R Portable: https://sourceforge.net/projects/rportable/
2. Extract to `electron/build/r-portable/`
3. Modify `electron/main.js` to use portable R (see `INSTALLATION.md`)

---

## Error Code Reference

| Exit Code | Hex | Meaning | Solution |
|-----------|-----|---------|----------|
| 3221225477 | 0xC0000005 | Access Violation | R not found or path issue |
| 3221225781 | 0xC0000135 | DLL Not Found | Missing R DLLs or dependencies |
| 1 | 0x1 | General Error | Check R stderr output |
| -1073741819 | 0xC0000005 | Access Violation | Same as 3221225477 |

---

## Prevention Checklist

Before running the app:

- [ ] R is installed from official source
- [ ] R version is 4.0 or later
- [ ] R is added to system PATH
- [ ] Computer has been restarted after R installation
- [ ] All R packages are installed (`source("R-app/install_packages.R")`)
- [ ] Packages load without errors (`library(shiny)`, `library(MALDIquant)`)
- [ ] Node.js and npm are installed
- [ ] `npm install` completed successfully in `electron/` directory

---

## Getting Help

If still experiencing issues:

1. **Check Console Output**: Run `npm start` and save all output
2. **Check R Directly**: Run `R` in terminal and test packages
3. **Collect Information**:
   - R version: `R --version`
   - R path: `where R` (Windows)
   - Installed packages: `installed.packages()[, "Package"]` in R
   - Error messages from console
4. **Report Issue**: Include all above information

---

## Quick Reference Commands

```bash
# Verify R
R --version

# Install R packages
R
> source("R-app/install_packages.R")
> q()

# Test application
cd electron
npm start

# Clean reinstall
cd electron
rm -rf node_modules package-lock.json
npm install
npm start
```

---

**Last Updated**: October 2024
**Version**: 1.0.0
