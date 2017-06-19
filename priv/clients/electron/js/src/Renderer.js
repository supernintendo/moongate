// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.
const ipcRenderer = require('electron').ipcRenderer;
const frameContainer = document.querySelector('[data-moongate-electron-client-frame]');
const net = require('net');
const State = {};

function loadEndpointFrame(endpoint) {
  if (endpoint.port && endpoint.protocol === 'web') {
    frameContainer.innerHTML = `<iframe src="http://localhost:${endpoint.port}"></iframe>`;
  }
}

function stateCallback(key, value) {
  switch (key) {
    case 'activeEndpoint':
      return loadEndpointFrame(value);
    default:
      return null;
  }
}

ipcRenderer.send('getState', 'activeEndpoint');
ipcRenderer.on('pushState', function(event, key, value) {
  stateCallback(key, value);
});
