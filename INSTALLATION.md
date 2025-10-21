# MALDIquant Windows App - Installation & Build Guide

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Development Environment Setup](#development-environment-setup)
3. [Running the Application](#running-the-application)
4. [Building for Distribution](#building-for-distribution)
5. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

#### 1. R (Statistical Computing Environment)

**Version**: 4.0.0 or later (4.3.x recommended)

**Download**: https://cran.r-project.org/bin/windows/base/

**Installation Steps**:
1. Download `R-4.3.2-win.exe` (or latest version)
2. Run the installer
3. **IMPORTANT**: Check "Add R to PATH" during installation
4. Use default installation directory: `C:\Program Files\R\R-4.3.2\`
5. Complete installation

**Verify Installation**:
```bash
# Open Command Prompt (cmd) and run:
R --version
```

Expected output:
```
R version 4.3.2 (2023-10-31) -- "Eye Holes"
...
```

#### 2. Node.js (JavaScript Runtime)

**Version**: 14.0.0 or later (LTS 18.x or 20.x recommended)

**Download**: https://nodejs.org/

**Installation Steps**:
1. Download Windows Installer (.msi)
2. Run installer
3. Accept default options (includes npm)
4. Restart terminal after installation

**Verify Installation**:
```bash
node --version
npm --version
```

Expected output:
```
v18.17.0  # or similar
9.6.7     # or similar
```

#### 3. Git (Optional, for version control)

**Download**: https://git-scm.com/download/win

**Installation**: Use default options

---

## Development Environment Setup

### Step 1: Navigate to Project Directory

```bash
cd /path/to/MALDIquant-Windows-App
```

### Step 2: Install R Packages

Open **R Console** (not Command Prompt) or **RStudio**:

```r
# Set working directory
setwd("C:/path/to/MALDIquant-Windows-App")

# Run installation script
source("R-app/install_packages.R")
```

**What gets installed**:
- `shiny` - Web application framework
- `MALDIquant` - Mass spectrometry analysis
- `MALDIquantForeign` - File format support
- `plotly` - Interactive plots
- `DT` - Interactive tables
- `bslib` - Bootstrap theming
- `colourpicker` - Color picker widget

**Installation Time**: 5-10 minutes (depending on internet speed)

**Verify R Packages**:
```r
# Check installed packages
library(shiny)
library(MALDIquant)
library(plotly)

# Should load without errors
```

### Step 3: Install Node.js Dependencies

Open **Command Prompt** or **PowerShell**:

```bash
# Navigate to electron directory
cd MALDIquant-Windows-App/electron

# Install dependencies
npm install
```

**What gets installed**:
- `electron` (~140MB) - Desktop framework
- `electron-builder` - Build/packaging tool
- `electron-store` - Settings storage

**Installation Time**: 2-5 minutes

**Verify Node Packages**:
```bash
# Check installed packages
npm list --depth=0
```

Expected output:
```
MALDIquant-windows-app@1.0.0
├── electron@28.0.0
├── electron-builder@24.9.1
└── electron-store@8.1.0
```

---

## Running the Application

### Method 1: Development Mode (Shiny Only)

**Best for**: Quick UI/logic testing, fastest iteration

**Steps**:

1. Open R Console or RStudio
2. Run:
```r
library(shiny)
runApp("R-app")
```

3. Application opens in browser (e.g., http://127.0.0.1:3456)

**Advantages**:
- Fast startup
- Direct R console access
- Quick reload (just refresh browser)

**Disadvantages**:
- Not testing Electron integration
- Browser-based (not desktop app)

**Stop Application**: Press `Ctrl+C` in R console

---

### Method 2: Desktop Mode (Electron + Shiny)

**Best for**: Full application testing, UI/UX validation

**Steps**:

1. Open Command Prompt or PowerShell
2. Navigate to electron directory:
```bash
cd MALDIquant-Windows-App/electron
```

3. Start application:
```bash
npm start
```

**What happens**:
1. Electron launches
2. Shows loading screen
3. Starts R Shiny server in background
4. Loads Shiny app in Electron window (30-60 seconds)

**Advantages**:
- Tests full desktop experience
- Tests Electron integration
- Realistic user experience

**Disadvantages**:
- Slower startup
- Need to restart for most changes

**Stop Application**: Close window or press `Ctrl+C` in terminal

---

## Building for Distribution

### Build Overview

Creates standalone Windows installer that includes:
- Electron application
- Shiny application
- Node.js runtime (bundled)

**Does NOT include**:
- R runtime (users must install separately)

**Alternative**: Bundle R runtime (~500MB additional size)

---

### Standard Build (Without R Runtime)

#### Step 1: Prepare for Build

```bash
cd MALDIquant-Windows-App/electron

# Clean previous builds (optional)
rm -rf dist/
```

#### Step 2: Run Build Command

```bash
npm run build
```

**Build process**:
1. Packages Electron app
2. Bundles R-app directory
3. Creates NSIS installer
4. Outputs to `electron/dist/`

**Build Time**: 2-5 minutes

**Output**:
```
electron/dist/
├── MALDIquant-Setup-1.0.0.exe    # Installer (~50-80MB)
└── win-unpacked/                  # Unpacked application
```

#### Step 3: Test Installer

```bash
# Run installer
./dist/MALDIquant-Setup-1.0.0.exe
```

**Installation**:
1. Choose installation directory
2. Creates desktop shortcut
3. Creates Start Menu entry
4. Installs application

**Default Install Location**:
```
C:\Users\<YourName>\AppData\Local\Programs\MALDIquant Analyzer\
```

---

### Advanced Build (With R Runtime)

**Warning**: Increases installer size to ~500MB

#### Step 1: Download Portable R

1. Download R portable: https://sourceforge.net/projects/rportable/
2. Extract to `electron/build/r-portable/`

#### Step 2: Modify main.js

Edit `electron/main.js`:

```javascript
// Find this function
function findRExecutable() {
  // Add portable R path at the beginning
  const possiblePaths = [
    path.join(process.resourcesPath, 'r-portable', 'bin', 'R.exe'), // Bundled R
    'R', // In PATH
    'C:\\Program Files\\R\\R-4.3.2\\bin\\R.exe',
    // ... rest of paths
  ];
  // ... rest of function
}
```

#### Step 3: Update package.json

Edit `electron/package.json`:

```json
{
  "build": {
    "extraResources": [
      {
        "from": "../R-app",
        "to": "R-app"
      },
      {
        "from": "build/r-portable",
        "to": "r-portable"
      }
    ]
  }
}
```

#### Step 4: Build

```bash
npm run build
```

**Result**: Installer includes R runtime, no separate R installation needed.

---

### Build Options

#### Build for 32-bit and 64-bit

```bash
npm run build-all
```

Outputs:
- `MALDIquant-Setup-1.0.0-x64.exe`
- `MALDIquant-Setup-1.0.0-ia32.exe`

#### Directory Build (No Installer)

```bash
npm run pack
```

Creates unpacked application in `dist/win-unpacked/` for testing.

#### Distribution Build

```bash
npm run dist
```

Creates both installer and portable zip.

---

## Testing the Build

### Pre-Installation Testing

1. **Check file size**:
```bash
ls -lh electron/dist/*.exe
```

Expected: ~50-80MB (without R), ~500MB (with R)

2. **Verify file integrity**:
```bash
# On Windows
certutil -hashfile electron/dist/MALDIquant-Setup-1.0.0.exe SHA256
```

### Post-Installation Testing

1. **Launch application**:
   - From Start Menu: "MALDIquant Analyzer"
   - From Desktop shortcut
   - From install directory

2. **Test basic functionality**:
   - Application launches without errors
   - R server starts successfully
   - UI loads properly
   - File import works
   - Processing completes
   - Export functions work

3. **Check installation files**:
```bash
cd C:\Users\<YourName>\AppData\Local\Programs\MALDIquant Analyzer\
dir
```

Expected structure:
```
MALDIquant Analyzer/
├── MALDIquant Analyzer.exe
├── resources/
│   ├── app.asar              # Packaged application
│   └── R-app/                # Shiny application
└── locales/
```

---

## Complete Setup Example

### Fresh Installation (Step-by-Step)

```bash
# 1. Install R (if not installed)
# Download from https://cran.r-project.org/
# Run installer, check "Add to PATH"

# 2. Install Node.js (if not installed)
# Download from https://nodejs.org/
# Run installer

# 3. Verify installations
R --version
node --version
npm --version

# 4. Navigate to project
cd C:/Projects/MALDIquant-Windows-App

# 5. Install R packages
R
> source("R-app/install_packages.R")
> q()

# 6. Install Node packages
cd electron
npm install

# 7. Test in development
npm start

# 8. Build for distribution
npm run build

# 9. Test installer
./dist/MALDIquant-Setup-1.0.0.exe
```

**Total Time**: ~20-30 minutes (including downloads)

---

## Troubleshooting

### R Issues

#### Problem: "R not found"

**Solution**:
```bash
# Check R in PATH
where R

# If not found, add R to PATH:
# Windows:
# Control Panel > System > Advanced > Environment Variables
# Add: C:\Program Files\R\R-4.3.2\bin
```

#### Problem: "Package installation failed"

**Solution**:
```r
# Install manually
install.packages("shiny", dependencies = TRUE)
install.packages("MALDIquant", dependencies = TRUE)

# Check CRAN mirror
options(repos = c(CRAN = "https://cran.rstudio.com/"))
```

#### Problem: "Cannot load MALDIquant"

**Solution**:
```r
# Update Bioconductor (if needed)
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

# Reinstall MALDIquant
install.packages("MALDIquant", type = "source")
```

---

### Node.js Issues

#### Problem: "npm install fails"

**Solution**:
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules
rm -rf node_modules
rm package-lock.json

# Reinstall
npm install
```

#### Problem: "Electron download timeout"

**Solution**:
```bash
# Set longer timeout
npm config set timeout 600000

# Or use Electron mirror
npm config set electron_mirror https://npmmirror.com/mirrors/electron/

# Reinstall
npm install electron
```

---

### Build Issues

#### Problem: "Build fails with error"

**Solution**:
```bash
# Check Node.js version
node --version  # Should be 14+

# Update electron-builder
npm install electron-builder@latest --save-dev

# Clean and rebuild
rm -rf dist/
npm run build
```

#### Problem: "Installer too large"

**Solution**:
- Don't bundle R runtime (use separate R installation)
- Compress resources
- Exclude unnecessary files in `package.json`:

```json
{
  "build": {
    "files": [
      "!**/node_modules/*/{CHANGELOG.md,README.md,README,readme.md,readme}",
      "!**/node_modules/*/{test,__tests__,tests,powered-test,example,examples}",
      "!**/node_modules/*.d.ts",
      "!**/node_modules/.bin"
    ]
  }
}
```

---

### Runtime Issues

#### Problem: "Application won't start after installation"

**Solution**:
1. Check R is installed: `R --version`
2. Check R is in PATH
3. Check Event Viewer (Windows) for errors
4. Run from Command Prompt to see errors:
```bash
"C:\Users\<Name>\AppData\Local\Programs\MALDIquant Analyzer\MALDIquant Analyzer.exe"
```

#### Problem: "Shiny server won't start"

**Solution**:
```bash
# Check R packages
R
> library(shiny)
> library(MALDIquant)

# If error, reinstall packages
> install.packages(c("shiny", "MALDIquant"))
```

#### Problem: "Port already in use"

**Solution**:
Edit `electron/main.js`:
```javascript
// Change port
let shinyPort = 3838;  // Change to 3839, 3840, etc.
```

---

## Performance Optimization

### Development

1. **Use Shiny only mode** for UI development
2. **Use nodemon** for auto-restart:
```bash
npm install -g nodemon
nodemon --exec "npm start"
```

3. **Enable Shiny autoreload**:
```r
options(shiny.autoreload = TRUE)
runApp("R-app")
```

### Production Build

1. **Minimize bundle size**:
   - Exclude dev dependencies
   - Use production mode
   - Compress resources

2. **Optimize R packages**:
   - Only install required packages
   - Use binary packages (not source)

3. **Test on target system**:
   - Clean Windows installation
   - Various R versions
   - Different hardware specs

---

## Deployment Checklist

Before distributing:

- [ ] All R packages install successfully
- [ ] Application launches without errors
- [ ] File import works for all formats
- [ ] Processing completes without crashes
- [ ] Export functions work correctly
- [ ] Build creates installer successfully
- [ ] Installer runs on clean Windows system
- [ ] Application works after installation
- [ ] No console errors in production
- [ ] Documentation is up to date
- [ ] Version number is correct
- [ ] License information included

---

## Version Control

### Using Git

```bash
# Initialize repository
git init

# Add files
git add .

# Commit
git commit -m "Initial commit"

# Create release tag
git tag -a v1.0.0 -m "Version 1.0.0"
```

### .gitignore

Already configured to exclude:
- `electron/node_modules/`
- `electron/dist/`
- Build artifacts
- User settings

---

## Next Steps

1. **Development**: Use `npm start` for testing
2. **Build**: Use `npm run build` for distribution
3. **Deploy**: Distribute `.exe` installer
4. **Update**: Increment version, rebuild, distribute

---

**For More Information**:
- User Guide: `docs/USER_GUIDE.md`
- Developer Guide: `docs/DEVELOPER_GUIDE.md`
- Quick Start: `QUICKSTART.md`

**Support**:
- GitHub Issues: [Your repository]
- Documentation: `docs/` folder
