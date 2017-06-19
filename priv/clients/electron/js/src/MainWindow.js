const electron = require('electron');
const { Menu, BrowserWindow, app, shell } = electron;
const defaultMenu = require('electron-default-menu');
const ipcMain = require('electron').ipcMain;
const fs = require('fs');
const path = require('path');
const url = require('url');

require('static?!index.html?output=../dist/index.html');

const State = {
  activeEndpoint: null,
  config: {},
  mainMenu: {},
  mainWindow: null,
  gamefile: process.argv[2],
}

function createWindow() {
  State.mainWindow = new BrowserWindow({
    fullscreenable: isFullfullscreenable(),
    title: 'Moongate Electron Client',
    width: 800,
    height: 600
  });
  refreshWindow();
  State.mainWindow.on('closed', function () {
    State.mainWindow = null;
  });
}

function prepareMenu() {
  let result = {};

  Object.keys(State.config.endpoints).forEach((key) => {
    result[key] = () => {
      State.activeEndpoint = endpoint(key);
      refreshWindow();
    }
  });
  State.mainMenu['Port'] = result;
}

function createMenu() {
  // Get template for default menu
  const menu = defaultMenu(app, shell);
  const modifiedMenu = (
    menu.filter((menuItem) => {
      return (
        menuItem.label !== 'File' &&
        menuItem.label !== 'Help'
      );
    }));

  Object.keys(State.mainMenu).forEach((key) => {
    modifiedMenu.splice(1, 0, {
      label: key,
      submenu: Object.keys(State.mainMenu[key]).map((menuItemKey) => {
        return {
          label: menuItemKey,
          click: (item, focusedWindow) => {
            State.mainMenu[key][menuItemKey](item, focusedWindow);
          }
        }
      })
    })
  });
  // Set top-level application menu, using modified template
  Menu.setApplicationMenu(Menu.buildFromTemplate(modifiedMenu));
}

function refreshWindow() {
  State.mainWindow.loadURL(url.format({
    pathname: path.join(__dirname, 'index.html'),
    protocol: 'file:',
    slashes: true
  }));
}

function endpoint(port) {
  let key = port || Object.keys(State.config.endpoints)[0],
      result = State.config.endpoints[`${key}`];

  if (result && result instanceof Object) {
    return Object.assign(result, { port: key });
  }
  throw `Endpoint entry with key ${key} is not a valid object literal`
}

function init() {
  if (State.gamefile) {
    fs.readFile(State.gamefile, function (err, data) {
      if (err) {
        throw err;
      } else {
        State.config = JSON.parse(data.toString());
        State.activeEndpoint = endpoint();
        createWindow();
        prepareMenu();
        createMenu();
      }
    });
  }
}

function isFullfullscreenable() {
  return process.env.TERM !== 'screen' && !process.env.TMUX;
}

ipcMain.on('getState', function(event, key) {
  if (State[key]) {
    event.sender.send('pushState', key, State[key]);
  }
});
process.on('exit', function() {
  process.stdout.write('closed');
});
app.on('ready', init);
app.on('window-all-closed', function() {
  app.quit();
});
app.on('activate', function() {
  if (State.mainWindow === null) {
    init();
  }
});
