# MALDIquant Analyzer - Developer Guide

## Table of Contents

1. [Architecture](#architecture)
2. [Development Setup](#development-setup)
3. [Project Structure](#project-structure)
4. [Development Workflow](#development-workflow)
5. [Building and Packaging](#building-and-packaging)
6. [Testing](#testing)
7. [Contributing](#contributing)

## Architecture

### Technology Stack

```
┌─────────────────────────────────────────┐
│          Electron Desktop Shell         │
│  (Windows application wrapper)          │
├─────────────────────────────────────────┤
│          Shiny Web Interface            │
│  (UI layer with reactive components)    │
├─────────────────────────────────────────┤
│         MALDIquant R Package            │
│  (Core data analysis engine)            │
├─────────────────────────────────────────┤
│      R Runtime (Embedded/External)      │
│  (Statistical computing environment)    │
└─────────────────────────────────────────┘
```

### Components

#### 1. R-app (Shiny Application)

- **Purpose**: User interface and data processing logic
- **Technology**: R + Shiny framework
- **Key files**:
  - `app.R`: Main Shiny application
  - `global.R`: Global configurations and helper functions
  - `install_packages.R`: Package installation script

#### 2. Electron Wrapper

- **Purpose**: Desktop application container
- **Technology**: Electron (Node.js + Chromium)
- **Key files**:
  - `main.js`: Electron main process (window management, R process)
  - `preload.js`: IPC communication bridge
  - `loading.html`: Splash screen
  - `package.json`: Dependencies and build configuration

#### 3. Documentation

- **Purpose**: User and developer documentation
- **Files**:
  - `USER_GUIDE.md`: End-user documentation
  - `DEVELOPER_GUIDE.md`: This file

## Development Setup

### Prerequisites

1. **R** (>= 4.0.0)
   - Download: https://cran.r-project.org/
   - Add to PATH during installation

2. **Node.js** (>= 14.0.0)
   - Download: https://nodejs.org/
   - Includes npm package manager

3. **Git** (optional, for version control)
   - Download: https://git-scm.com/

4. **Code Editor**
   - Recommended: Visual Studio Code or RStudio

### Installation Steps

#### 1. Clone/Download Project

```bash
git clone <repository-url>
cd MALDIquant-Windows-App
```

#### 2. Install R Dependencies

```r
# Open R console or RStudio
source("R-app/install_packages.R")
```

Required R packages:
- shiny
- MALDIquant
- MALDIquantForeign
- plotly
- DT
- bslib
- colourpicker

#### 3. Install Node.js Dependencies

```bash
cd electron
npm install
```

This installs:
- electron
- electron-builder
- electron-store

### Verify Installation

#### Test R Application

```r
# In R console
library(shiny)
runApp("R-app")
```

Should open browser with Shiny app.

#### Test Electron Wrapper

```bash
cd electron
npm start
```

Should launch desktop application.

## Project Structure

```
MALDIquant-Windows-App/
│
├── R-app/                          # Shiny application
│   ├── app.R                       # Main Shiny app (UI + Server)
│   ├── global.R                    # Global config and helpers
│   ├── install_packages.R          # Package installer
│   └── www/                        # Static assets (optional)
│       ├── logo.png
│       └── styles.css
│
├── electron/                       # Electron wrapper
│   ├── main.js                     # Main process
│   ├── preload.js                  # Preload script
│   ├── loading.html                # Splash screen
│   ├── package.json                # Dependencies
│   ├── package-lock.json
│   └── build/                      # Build resources
│       ├── icon.ico                # Windows icon
│       └── icon.png                # PNG icon
│
├── docs/                           # Documentation
│   ├── USER_GUIDE.md
│   └── DEVELOPER_GUIDE.md
│
├── tests/                          # Test files
│   ├── test_preprocessing.R
│   └── test_peak_detection.R
│
├── data/                           # Sample data
│   └── sample-data/
│       ├── example1.mzML
│       └── README.txt
│
└── README.md                       # Project overview
```

## Development Workflow

### Running in Development Mode

#### Option 1: Shiny Only (Browser)

```r
# Fast iteration for UI/logic changes
library(shiny)
runApp("R-app")
```

**Pros**: Fast reload, R console access
**Cons**: Not testing Electron integration

#### Option 2: Electron + Shiny (Desktop)

```bash
cd electron
npm start
```

**Pros**: Full application testing
**Cons**: Slower startup, need to restart for changes

### Making Changes

#### Modifying UI

1. Edit `R-app/app.R` (ui section)
2. Save file
3. Reload application:
   - Shiny mode: Refresh browser
   - Electron mode: Ctrl+R or restart

#### Modifying Server Logic

1. Edit `R-app/app.R` (server section)
2. Save file
3. Reload application

#### Modifying Electron Behavior

1. Edit `electron/main.js` or `electron/preload.js`
2. Save file
3. Restart Electron: `npm start`

#### Adding R Packages

1. Add package to `R-app/install_packages.R`
2. Add library() call to `R-app/app.R` or `global.R`
3. Run install script:
   ```r
   source("R-app/install_packages.R")
   ```

#### Adding Node Modules

```bash
cd electron
npm install <package-name> --save
```

### Debugging

#### R/Shiny Debugging

```r
# Add browser() breakpoint in server function
server <- function(input, output, session) {
  observeEvent(input$processBtn, {
    browser()  # Execution will pause here
    # ... rest of code
  })
}
```

Run in R console for interactive debugging.

#### Electron Debugging

1. Launch with dev tools:
   ```bash
   npm start
   ```

2. Open Developer Tools: `Ctrl+Shift+I`

3. View console logs from `main.js`:
   ```bash
   # In terminal where npm start was run
   ```

#### R Process Debugging

Check R process output in Electron console:
- `main.js` logs R stdout/stderr
- Look for error messages

### Common Development Tasks

#### Add New Preprocessing Method

1. In `app.R`, add to UI selectInput choices
2. In server, add case to preprocessing logic
3. Test with sample data

#### Add New Tab

1. In `app.R` ui, add tabPanel to tabsetPanel
2. Add corresponding output in mainPanel
3. Add render function in server
4. Test navigation and rendering

#### Customize Styling

1. Create `R-app/www/styles.css`
2. Add custom CSS rules
3. Reference in ui with `includeCSS()`

#### Add Menu Item

1. Edit `electron/main.js`
2. Add item to menu template
3. Define click handler
4. Restart Electron

## Building and Packaging

### Development Build

Test packaging without full distribution:

```bash
cd electron
npm run pack
```

Creates unpackaged application in `electron/dist/`.

### Production Build (Windows)

#### Full Build

```bash
cd electron
npm run build
```

**Output**: `electron/dist/MALDIquant-Setup-1.0.0.exe`

#### Build Options

```bash
# 64-bit only (recommended)
npm run build

# 32-bit and 64-bit
npm run build-all
```

### Build Configuration

Edit `electron/package.json` → `build` section:

```json
{
  "build": {
    "appId": "com.maldiquant.windowsapp",
    "productName": "MALDIquant Analyzer",
    "win": {
      "target": "nsis",
      "icon": "build/icon.ico"
    }
  }
}
```

### Customizing Installer

NSIS options in `package.json`:

```json
{
  "nsis": {
    "oneClick": false,                  // Allow custom install path
    "allowToChangeInstallationDirectory": true,
    "createDesktopShortcut": true,
    "createStartMenuShortcut": true,
    "shortcutName": "MALDIquant Analyzer"
  }
}
```

### Including R Runtime (Advanced)

To bundle R with the application:

1. Download Portable R
2. Add to `electron/build/r-portable/`
3. Update `main.js` to use bundled R:

```javascript
const rExecutable = path.join(
  process.resourcesPath,
  'r-portable',
  'bin',
  'R.exe'
);
```

4. Update `package.json` extraResources:

```json
{
  "extraResources": [
    {
      "from": "build/r-portable",
      "to": "r-portable"
    }
  ]
}
```

**Warning**: This significantly increases installer size (~500MB).

## Testing

### Manual Testing Checklist

- [ ] Application launches successfully
- [ ] R process starts without errors
- [ ] File import works for all formats
- [ ] Preprocessing completes without errors
- [ ] Peak detection runs successfully
- [ ] Plots render correctly
- [ ] Export functions work
- [ ] Application closes cleanly

### Automated Testing (R)

Create test files in `tests/`:

```r
# tests/test_preprocessing.R
library(testthat)
library(MALDIquant)

test_that("Smoothing works correctly", {
  # Create test spectrum
  mass <- seq(1000, 5000, by = 1)
  intensity <- rnorm(length(mass), mean = 100, sd = 10)
  spectrum <- createMassSpectrum(mass, intensity)

  # Apply smoothing
  smoothed <- smoothIntensity(spectrum, method = "SavitzkyGolay")

  # Check results
  expect_s4_class(smoothed, "MassSpectrum")
  expect_equal(length(mass(smoothed)), length(mass(spectrum)))
})
```

Run tests:

```r
testthat::test_dir("tests/")
```

### Sample Data

Create test data in `data/sample-data/`:

```r
# Generate sample mzML file
library(MALDIquant)
library(MALDIquantForeign)

# Create spectrum
mass <- seq(1000, 5000, by = 0.5)
intensity <- rnorm(length(mass), mean = 100, sd = 20)
spectrum <- createMassSpectrum(mass, intensity)

# Export
exportMzMl(spectrum, "data/sample-data/example1.mzML")
```

## Contributing

### Code Style

#### R Code

- Use tidyverse style guide
- 2-space indentation
- Function names: camelCase
- Variable names: snake_case or camelCase

#### JavaScript Code

- ES6+ syntax
- 2-space indentation
- Single quotes for strings
- Semicolons required

### Commit Messages

Format:
```
<type>: <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Tests
- `chore`: Maintenance

Example:
```
feat: Add support for Bruker raw files

- Implement importBrukerFlex wrapper
- Add file type detection
- Update UI to show Bruker option

Closes #123
```

### Pull Request Process

1. Fork repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Update documentation
6. Submit PR with description

### Versioning

Follow Semantic Versioning (semver):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

Update version in:
- `electron/package.json`
- `R-app/global.R` (APP_VERSION)
- `README.md`

## Advanced Topics

### Performance Optimization

#### R Side

1. **Vectorization**: Use vectorized operations
2. **Memory management**: Clear large objects
3. **Parallel processing**: Use `parallel` package

```r
# Example: Parallel peak detection
library(parallel)
cl <- makeCluster(detectCores() - 1)
peaks <- parLapply(cl, spectra, detectPeaks, SNR = 3)
stopCluster(cl)
```

#### Electron Side

1. **Lazy loading**: Load tabs on demand
2. **Debouncing**: Delay reactive updates
3. **Progress indicators**: Show processing status

### Security Considerations

1. **Input validation**: Validate file uploads
2. **Path sanitization**: Prevent directory traversal
3. **R code injection**: Don't eval user input
4. **Update dependencies**: Regularly update packages

### Internationalization (i18n)

To add language support:

1. Install `shiny.i18n` package
2. Create translation files
3. Update UI with translation functions

```r
library(shiny.i18n)
translator <- Translator$new(translation_json_path = "translations.json")
```

### Analytics and Logging

Add telemetry:

```r
# In global.R
logEvent <- function(event, details = "") {
  timestamp <- Sys.time()
  cat(sprintf("[%s] %s: %s\n", timestamp, event, details))
  # Optional: Write to file or send to analytics service
}

# In server
logEvent("DATA_IMPORTED", paste(nrow(input$dataFiles), "files"))
```

## Resources

### Documentation

- Shiny: https://shiny.rstudio.com/
- MALDIquant: https://strimmerlab.github.io/software/maldiquant/
- Electron: https://www.electronjs.org/docs

### Community

- R-help: https://www.r-project.org/help.html
- Shiny Community: https://community.rstudio.com/
- Electron Discord: https://discord.gg/electron

### Useful Packages

- `shinyWidgets`: Enhanced UI components
- `shinyjs`: JavaScript integration
- `shinydashboard`: Dashboard layouts
- `plotly`: Interactive plots
- `DT`: Interactive tables

---

**Last Updated**: October 2024
**Document Version**: 1.0.0
