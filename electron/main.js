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
      preload: path.join(__dirname, 'preload.js')
    },
    icon: path.join(__dirname, 'build', 'icon.png'),
    title: 'MALDIquant Analyzer',
    show: false // Don't show until ready
  });

  // Create application menu
  createMenu();

  // Show window when ready
  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
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

  // Load splash screen first
  mainWindow.loadFile(path.join(__dirname, 'loading.html'));

  // Start R Shiny server
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
    dialog.showErrorBox(
      'R Not Found',
      'R is not installed or not found in PATH. Please install R and try again.'
    );
    app.quit();
    return;
  }

  // R command to start Shiny
  const rCommand = `
    options(shiny.port = ${shinyPort}, shiny.host = '127.0.0.1')
    shiny::runApp('${rAppPath.replace(/\\/g, '/')}', launch.browser = FALSE)
  `;

  // Spawn R process
  rProcess = spawn(rExecutable, ['--vanilla', '-e', rCommand], {
    stdio: ['ignore', 'pipe', 'pipe']
  });

  rProcess.stdout.on('data', (data) => {
    console.log(`R: ${data}`);

    // Check if Shiny is ready
    if (data.toString().includes('Listening on')) {
      console.log('Shiny server is ready!');
      setTimeout(() => {
        mainWindow.loadURL(`http://127.0.0.1:${shinyPort}`);
      }, 1000);
    }
  });

  rProcess.stderr.on('data', (data) => {
    console.error(`R Error: ${data}`);
  });

  rProcess.on('error', (error) => {
    console.error('Failed to start R process:', error);
    dialog.showErrorBox(
      'Failed to Start',
      `Could not start R Shiny server: ${error.message}`
    );
    app.quit();
  });

  rProcess.on('close', (code) => {
    console.log(`R process exited with code ${code}`);
    if (code !== 0 && mainWindow) {
      dialog.showErrorBox(
        'R Process Crashed',
        'The R Shiny server has stopped unexpectedly.'
      );
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
  const possiblePaths = [
    'R', // In PATH
    'C:\\Program Files\\R\\R-4.3.2\\bin\\R.exe',
    'C:\\Program Files\\R\\R-4.3.1\\bin\\R.exe',
    'C:\\Program Files\\R\\R-4.2.3\\bin\\R.exe',
    'C:\\Program Files\\R\\R-4.2.2\\bin\\R.exe',
    'C:\\Program Files\\R\\R-4.1.3\\bin\\R.exe'
  ];

  // Try to find R in common locations
  for (const rPath of possiblePaths) {
    try {
      const { execSync } = require('child_process');
      execSync(`"${rPath}" --version`, { stdio: 'ignore' });
      return rPath;
    } catch (e) {
      // Continue to next path
    }
  }

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
