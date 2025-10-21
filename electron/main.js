// MALDIquant Windows Application - Electron Main Process
const { app, BrowserWindow, Menu, dialog, ipcMain } = require('electron');
const path = require('path');
const { spawn } = require('child_process');
const Store = require('electron-store');

// Initialize electron-store for settings
const store = new Store();

// Global references
let mainWindow;
let rProcess;
let shinyPort = 3838;
let shinyReady = false;

// Configuration
const isDev = !app.isPackaged;
const rAppPath = isDev
  ? path.join(__dirname, '..', 'R-app')
  : path.join(process.resourcesPath, 'R-app');

/**
 * Create the main application window
 */
function createWindow() {
  // Get stored window bounds or use defaults
  const windowBounds = store.get('windowBounds', {
    width: 1400,
    height: 900
  });

  mainWindow = new BrowserWindow({
    width: windowBounds.width,
    height: windowBounds.height,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js'),
      webSecurity: true
    },
    icon: path.join(__dirname, 'build', 'icon.png'),
    title: 'MALDIquant Analyzer',
    show: true // Show immediately with loading screen
  });

  // Set Content Security Policy for Shiny
  mainWindow.webContents.session.webRequest.onHeadersReceived((details, callback) => {
    callback({
      responseHeaders: {
        ...details.responseHeaders,
        'Content-Security-Policy': [
          "default-src 'self' 'unsafe-inline' 'unsafe-eval' http://127.0.0.1:* ws://127.0.0.1:* data: blob:;"
        ]
      }
    });
  });

  // Create application menu
  createMenu();

  // Filter console errors (ignore Shiny's dragEvent errors)
  mainWindow.webContents.on('console-message', (event, level, message, line, sourceId) => {
    // Suppress known non-critical errors
    if (message.includes('dragEvent is not defined')) {
      return; // Don't log this error
    }
    // Log other messages normally
    if (level >= 2) { // 2 = warning, 3 = error
      console.log(`[Browser Console] ${message}`);
    }
  });

  // Save window bounds on close
  mainWindow.on('close', () => {
    store.set('windowBounds', mainWindow.getBounds());
  });

  // Clean up on closed
  mainWindow.on('closed', () => {
    mainWindow = null;
    stopRShiny();
  });

  // Show loading screen manually
  mainWindow.loadFile(path.join(__dirname, 'loading.html'));

  // Start R Shiny server - will automatically load Shiny URL when ready
  startRShiny();
}

/**
 * Start R Shiny server
 */
function startRShiny() {
  console.log('Starting R Shiny server...');
  console.log('R App Path:', rAppPath);

  // Find R executable
  const rExecutable = findRExecutable();

  if (!rExecutable) {
    const errorMessage = `R is not installed or could not be found.

Please install R from: https://cran.r-project.org/

Installation instructions:
1. Download R for Windows
2. Run the installer
3. Important: Check "Add R to PATH" during installation
4. Restart this application after installing R

Searched locations:
- System PATH
- C:\\Program Files\\R\\
- C:\\Program Files (x86)\\R\\
- Windows Registry`;

    dialog.showErrorBox('R Not Found', errorMessage);
    app.quit();
    return;
  }

  const rPath = rExecutable.path;
  const useRscript = rExecutable.useRscript;

  console.log(`Using R executable: ${rPath}`);
  console.log(`Using Rscript mode: ${useRscript}`);

  // R command to start Shiny
  const rCommand = `
    cat("Checking R packages...\\n")
    if (!require("shiny", quietly = TRUE)) {
      stop("Package 'shiny' is not installed. Please run: install.packages('shiny')")
    }
    if (!require("MALDIquant", quietly = TRUE)) {
      stop("Package 'MALDIquant' is not installed. Please run: install.packages('MALDIquant')")
    }
    cat("All required packages found\\n")
    cat("Starting Shiny server...\\n")
    options(shiny.port = ${shinyPort}, shiny.host = '127.0.0.1')
    shiny::runApp('${rAppPath.replace(/\\/g, '/')}', launch.browser = FALSE)
  `;

  console.log('Starting R process with command:');
  console.log(rCommand);

  // Spawn R process
  // Rscript doesn't need --vanilla flag
  const args = useRscript
    ? ['-e', rCommand]
    : ['--vanilla', '--quiet', '-e', rCommand];

  console.log(`Spawning: ${rPath} ${args.join(' ')}`);

  rProcess = spawn(rPath, args, {
    stdio: ['ignore', 'pipe', 'pipe']
  });

  rProcess.stdout.on('data', (data) => {
    console.log(`R: ${data}`);

    // Check if Shiny is ready
    if (data.toString().includes('Listening on') && !shinyReady) {
      shinyReady = true;
      console.log('✓ Shiny server is ready!');
      console.log('⏳ Waiting 5 seconds for Shiny to fully initialize...');

      // Wait for Shiny to actually respond before loading
      const shinyUrl = `http://127.0.0.1:${shinyPort}`;
      let attempts = 0;
      const maxAttempts = 30;

      console.log('⏳ Waiting for Shiny to respond...');

      const checkShinyReady = setInterval(() => {
        attempts++;

        // Use net module to check if Shiny is responding
        const http = require('http');
        const req = http.get(shinyUrl, (res) => {
          // Shiny responded!
          clearInterval(checkShinyReady);
          console.log(`✓ Shiny is responding! (HTTP ${res.statusCode})`);
          console.log('🔗 Loading Shiny application...');

          // Now load the URL
          mainWindow.loadURL(shinyUrl);
        });

        req.on('error', (err) => {
          if (attempts >= maxAttempts) {
            clearInterval(checkShinyReady);
            console.error('✗ Shiny did not respond after', maxAttempts, 'attempts');
            console.error('Error:', err.message);
            console.log('Try opening http://127.0.0.1:' + shinyPort + ' in a browser manually');
          } else {
            console.log(`[${attempts}/${maxAttempts}] Waiting for Shiny...`);
          }
        });

        req.setTimeout(1000);
        req.end();
      }, 1000);
    }
  });

  let stderrBuffer = '';

  rProcess.stderr.on('data', (data) => {
    const errorMsg = data.toString();
    stderrBuffer += errorMsg;
    console.error(`R Error: ${errorMsg}`);

    // Check for package errors
    if (errorMsg.includes('there is no package called')) {
      const packageMatch = errorMsg.match(/there is no package called '(.+?)'/);
      if (packageMatch) {
        const packageName = packageMatch[1];
        dialog.showErrorBox(
          'Missing R Package',
          `Required R package '${packageName}' is not installed.\n\nPlease install it by running in R:\ninstall.packages("${packageName}")\n\nOr run: source("R-app/install_packages.R")`
        );
      }
    }
  });

  rProcess.on('error', (error) => {
    console.error('Failed to start R process:', error);
    dialog.showErrorBox(
      'Failed to Start R',
      `Could not start R process.\n\nError: ${error.message}\n\nR executable: ${rPath}\n\nPlease ensure R is properly installed.`
    );
    app.quit();
  });

  rProcess.on('close', (code) => {
    console.log(`R process exited with code ${code}`);

    if (code !== 0 && mainWindow) {
      let errorMessage = `The R Shiny server has stopped unexpectedly.\n\nExit code: ${code}`;

      if (code === 3221225477 || code === -1073741819) {
        errorMessage += `\n\nThis usually means:\n- R is not properly installed\n- R packages are missing\n- Path issues with R installation`;
      }

      if (stderrBuffer) {
        errorMessage += `\n\nError output:\n${stderrBuffer.slice(0, 500)}`;
      }

      errorMessage += `\n\nPlease check:\n1. R is installed from https://cran.r-project.org/\n2. Run: source("R-app/install_packages.R") in R\n3. Check console for detailed errors`;

      dialog.showErrorBox('R Process Error', errorMessage);
    }
  });
}

/**
 * Stop R Shiny server
 */
function stopRShiny() {
  if (rProcess) {
    console.log('Stopping R Shiny server...');
    rProcess.kill();
    rProcess = null;
  }
}

/**
 * Find R executable
 */
function findRExecutable() {
  const { execSync } = require('child_process');
  const fs = require('fs');

  // Method 0: Check for bundled portable R FIRST
  console.log('Checking for bundled portable R...');
  const portableRPath = path.join(process.resourcesPath, 'R-portable', 'bin', 'x64', 'Rscript.exe');

  if (fs.existsSync(portableRPath)) {
    try {
      execSync(`"${portableRPath}" --version`, { stdio: 'ignore', timeout: 5000 });
      console.log(`✓ Found bundled portable R at: ${portableRPath}`);
      return { path: portableRPath, useRscript: true };
    } catch (e) {
      console.log('Bundled portable R found but not working, trying system R...');
    }
  } else {
    console.log('No bundled portable R found, searching for system R...');
  }

  // Method 1: Search in Program Files (for system-installed R)
  console.log('Searching for R in Program Files...');
  const programFilesLocations = [
    process.env.ProgramFiles || 'C:\\Program Files',
    process.env['ProgramFiles(x86)'] || 'C:\\Program Files (x86)'
  ];

  for (const programFiles of programFilesLocations) {
    const rBaseDir = path.join(programFiles, 'R');

    if (fs.existsSync(rBaseDir)) {
      try {
        // Find all R-x.x.x folders
        const rVersions = fs.readdirSync(rBaseDir)
          .filter(name => name.startsWith('R-'))
          .sort()
          .reverse(); // Get latest version first

        for (const version of rVersions) {
          const rExePath = path.join(rBaseDir, version, 'bin', 'R.exe');
          const rExePathX64 = path.join(rBaseDir, version, 'bin', 'x64', 'R.exe');

          // Try Rscript.exe first (more reliable with spawn)
          const rscriptPathX64 = path.join(rBaseDir, version, 'bin', 'x64', 'Rscript.exe');
          const rscriptPath = path.join(rBaseDir, version, 'bin', 'Rscript.exe');

          if (fs.existsSync(rscriptPathX64)) {
            try {
              execSync(`"${rscriptPathX64}" --version`, { stdio: 'ignore', timeout: 5000 });
              console.log(`Found Rscript at: ${rscriptPathX64}`);
              return { path: rscriptPathX64, useRscript: true };
            } catch (e) {
              // Continue searching
            }
          }

          if (fs.existsSync(rscriptPath)) {
            try {
              execSync(`"${rscriptPath}" --version`, { stdio: 'ignore', timeout: 5000 });
              console.log(`Found Rscript at: ${rscriptPath}`);
              return { path: rscriptPath, useRscript: true };
            } catch (e) {
              // Continue searching
            }
          }

          // Try x64 R.exe
          if (fs.existsSync(rExePathX64)) {
            try {
              execSync(`"${rExePathX64}" --version`, { stdio: 'ignore', timeout: 5000 });
              console.log(`Found R at: ${rExePathX64}`);
              return { path: rExePathX64, useRscript: false };
            } catch (e) {
              // Continue searching
            }
          }

          // Try standard R.exe
          if (fs.existsSync(rExePath)) {
            try {
              execSync(`"${rExePath}" --version`, { stdio: 'ignore', timeout: 5000 });
              console.log(`Found R at: ${rExePath}`);
              return { path: rExePath, useRscript: false };
            } catch (e) {
              // Continue searching
            }
          }
        }
      } catch (e) {
        console.error('Error searching R directory:', e.message);
      }
    }
  }

  // Method 3: Check registry (Windows only)
  if (process.platform === 'win32') {
    try {
      const registryPath = 'HKEY_LOCAL_MACHINE\\Software\\R-core\\R';
      const result = execSync(`reg query "${registryPath}" /v InstallPath`, {
        encoding: 'utf8',
        timeout: 5000
      });

      const match = result.match(/InstallPath\s+REG_SZ\s+(.+)/);
      if (match) {
        const installPath = match[1].trim();
        const rscriptPathX64 = path.join(installPath, 'bin', 'x64', 'Rscript.exe');
        const rscriptPath = path.join(installPath, 'bin', 'Rscript.exe');
        const rExePathX64 = path.join(installPath, 'bin', 'x64', 'R.exe');
        const rExePath = path.join(installPath, 'bin', 'R.exe');

        if (fs.existsSync(rscriptPathX64)) {
          console.log(`Found Rscript from registry: ${rscriptPathX64}`);
          return { path: rscriptPathX64, useRscript: true };
        }
        if (fs.existsSync(rscriptPath)) {
          console.log(`Found Rscript from registry: ${rscriptPath}`);
          return { path: rscriptPath, useRscript: true };
        }
        if (fs.existsSync(rExePathX64)) {
          console.log(`Found R from registry: ${rExePathX64}`);
          return { path: rExePathX64, useRscript: false };
        }
        if (fs.existsSync(rExePath)) {
          console.log(`Found R from registry: ${rExePath}`);
          return { path: rExePath, useRscript: false };
        }
      }
    } catch (e) {
      console.log('Could not read R from registry');
    }
  }

  // Method 3: Try R/Rscript in PATH as last resort
  // Note: In MINGW/Git Bash, PATH commands might not work reliably with spawn()
  console.log('Trying to find R in PATH as last resort...');

  const pathCommands = [
    { cmd: 'Rscript.exe', useRscript: true },
    { cmd: 'R.exe', useRscript: false },
    { cmd: 'Rscript', useRscript: true },
    { cmd: 'R', useRscript: false }
  ];

  for (const { cmd, useRscript } of pathCommands) {
    try {
      // First check if command exists
      execSync(`${cmd} --version`, { stdio: 'ignore', timeout: 5000 });

      // Try to get full path using 'where' command (Windows)
      try {
        const whereOutput = execSync(`where ${cmd}`, { encoding: 'utf8', timeout: 5000 });
        const fullPath = whereOutput.trim().split('\n')[0].trim();

        // Verify the path exists and is executable
        if (fs.existsSync(fullPath)) {
          console.log(`Found ${cmd} in PATH at: ${fullPath}`);
          return { path: fullPath, useRscript };
        }
      } catch (whereError) {
        console.log(`'where' command failed for ${cmd}, trying command name directly`);
      }

      // Fallback: use command name directly (may not work in MINGW)
      console.log(`Using ${cmd} from PATH (command name)`);
      return { path: cmd, useRscript };
    } catch (e) {
      // Try next command
    }
  }

  console.error('R executable not found anywhere');
  console.error('Searched locations:');
  console.error('- C:\\Program Files\\R\\');
  console.error('- C:\\Program Files (x86)\\R\\');
  console.error('- Windows Registry');
  console.error('- System PATH');
  return null;
}

/**
 * Create application menu
 */
function createMenu() {
  const template = [
    {
      label: 'File',
      submenu: [
        {
          label: 'Open Data Files...',
          accelerator: 'CmdOrCtrl+O',
          click: () => {
            // This will be handled by Shiny's file input
            mainWindow.webContents.send('menu-open-files');
          }
        },
        { type: 'separator' },
        {
          label: 'Exit',
          accelerator: 'CmdOrCtrl+Q',
          click: () => {
            app.quit();
          }
        }
      ]
    },
    {
      label: 'View',
      submenu: [
        { role: 'reload' },
        { role: 'forceReload' },
        { role: 'toggleDevTools' },
        { type: 'separator' },
        { role: 'resetZoom' },
        { role: 'zoomIn' },
        { role: 'zoomOut' },
        { type: 'separator' },
        { role: 'togglefullscreen' }
      ]
    },
    {
      label: 'Help',
      submenu: [
        {
          label: 'Documentation',
          click: () => {
            require('electron').shell.openExternal('https://github.com/sgibb/MALDIquant');
          }
        },
        {
          label: 'About MALDIquant',
          click: () => {
            dialog.showMessageBox(mainWindow, {
              type: 'info',
              title: 'About MALDIquant Analyzer',
              message: 'MALDIquant Analyzer v1.0.0',
              detail: 'A user-friendly Windows application for mass spectrometry data analysis.\n\nBuilt with R, Shiny, and Electron.\n\nMALDIquant package by Sebastian Gibb.',
              buttons: ['OK']
            });
          }
        }
      ]
    }
  ];

  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);
}

// App event handlers
app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  stopRShiny();
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

app.on('before-quit', () => {
  stopRShiny();
});

// IPC handlers
ipcMain.handle('get-app-path', () => {
  return app.getAppPath();
});

ipcMain.handle('get-user-data-path', () => {
  return app.getPath('userData');
});
