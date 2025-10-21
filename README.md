# MALDIquant Windows Application

A user-friendly Windows desktop application for mass spectrometry data analysis using the MALDIquant R package.

## Project Structure

```
MALDIquant-Windows-App/
├── R-app/              # Shiny application source code
├── electron/           # Electron wrapper configuration
├── docs/               # Documentation and user guides
├── tests/              # Test files
├── data/               # Sample data and examples
│   └── sample-data/
└── README.md
```

## Features

- User-friendly GUI for MALDIquant operations
- Batch file import (mzML, mzXML, Bruker formats)
- Visual spectrum inspection
- Automated preprocessing pipeline
- Peak detection with customizable parameters
- Export results (CSV, Excel, PDF reports)

## Technology Stack

- **R**: MALDIquant package for core analysis
- **Shiny**: Web-based user interface
- **Electron**: Desktop application wrapper
- **Node.js**: Build and packaging tools

## Development Setup

### Prerequisites

- **R (>= 4.0.0)** - [Download](https://cran.r-project.org/)
  - **⚠️ Important**: Check "Add R to PATH" during installation
- **Node.js (>= 14.0.0)** - [Download](https://nodejs.org/)
- npm (included with Node.js)

### Installation

1. **Install R dependencies:**
```r
# In R console
source("R-app/install_packages.R")
```

2. **Install Node.js dependencies:**
```bash
cd electron
npm install
```

### ⚠️ Common Issues

**Error: "R process exited with code 3221225477"**

This means R is not in your system PATH. Solutions:

1. Verify R installation: `R --version` in Command Prompt
2. If error, add R to PATH or reinstall R
3. See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed steps
4. Restart your terminal/computer after fixing

### Running the Application

#### Development Mode (Shiny only)
```r
library(shiny)
runApp("R-app")
```

#### Desktop Mode (Electron + Shiny)
```bash
cd electron
npm start
```

## Building for Distribution

```bash
cd electron
npm run build
```

This will create a Windows executable in the `dist/` folder.

## License

This project uses the MALDIquant package which is licensed under GPL (>= 3).

## Contributors

Developed for mass spectrometry data analysis workflow automation.

## Documentation

- 📖 [INSTALLATION.md](INSTALLATION.md) - Complete installation and build guide
- 🔧 [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Solutions for common problems
- 🚀 [QUICKSTART.md](QUICKSTART.md) - Quick start guide
- 📚 [docs/USER_GUIDE.md](docs/USER_GUIDE.md) - End-user documentation
- 💻 [docs/DEVELOPER_GUIDE.md](docs/DEVELOPER_GUIDE.md) - Developer documentation

## Support

**Having issues?**
1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) first
2. Verify R is installed: `R --version`
3. Ensure all packages installed: `source("R-app/install_packages.R")` in R
4. See documentation in `docs/` folder
