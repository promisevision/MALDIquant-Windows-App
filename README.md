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

- R (>= 4.0.0)
- Node.js (>= 14.0.0)
- npm or yarn

### Installation

1. Install R dependencies:
```r
install.packages(c("shiny", "MALDIquant", "MALDIquantForeign", "shinyFiles", "plotly", "DT"))
```

2. Install Node.js dependencies:
```bash
cd electron
npm install
```

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

## Support

For issues and questions, please refer to the documentation in the `docs/` folder.
