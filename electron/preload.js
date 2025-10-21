// Preload script for MALDIquant Windows Application
const { contextBridge, ipcRenderer } = require('electron');

// Expose protected methods that allow the renderer process to use
// the ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('electron', {
  getAppPath: () => ipcRenderer.invoke('get-app-path'),
  getUserDataPath: () => ipcRenderer.invoke('get-user-data-path'),

  // Listen for menu events
  onMenuOpenFiles: (callback) => {
    ipcRenderer.on('menu-open-files', callback);
  }
});

console.log('Preload script loaded');
