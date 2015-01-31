var mNone = [],
  mCmd = ['cmd'],
  mShift = ['shift'],
  mHyper = ['shift','ctrl','alt','cmd'],
  nudgePixels = 10,
  padding = 0,
  previousSizes = {};

// Remembers hotkey bindings ##################################################
var keys = [];
function bind(key, mods, callback) {
  keys.push(api.bind(key, mods, callback));
}

// Modal activation / deactivation ############################################
var active = false;
api.bind('a', mHyper, function() {
  if (!active) {
    enableKeys();
  } else {
    disableKeys();
  }
});
bind('escape', [], function() { disableKeys(); });
bind('return', [], function() { disableKeys(); });

// Bindings  ##################################################################

// Center window.
bind( 'c', mNone, cycleCalls( toGrid, 
    [ [.04, 0, 0.92, 1],[0.22, 0.025, 0.56, 0.95], [0.1, 0, 0.8, 1] ]));

// Space toggles the focussed between full screen and its initial size and position.
bind( 'space', mNone, function() { Window.focusedWindow().toggleFullscreen(); });

// The cursor keys make any window occupy one side of the screen.
bind( 'left',  mNone, cycleCalls( toGrid, [ [0, 0, 0.5, 1],   [0, 0, 0.6, 1],   [0, 0, 0.4, 1] ] ));
bind( 'right', mNone, cycleCalls( toGrid, [ [0.5, 0, 0.5, 1], [0.4, 0, 0.6, 1], [0.6, 0, 0.4, 1] ] ));
bind( 'up',    mNone, function() { Window.focusedWindow().toGrid(0, 0, 1, 0.3); });
bind( 'down',  mNone, function() { Window.focusedWindow().toGrid(0, 0.7, 1, 0.3); });

// The <CMD> + cursor keys move the focussed window.
bind( 'left',  mCmd, function() { Window.focusedWindow().nudgeLeft( 5 ); });
bind( 'right', mCmd, function() { Window.focusedWindow().nudgeRight( 5 ); });
bind( 'up',    mCmd, function() { Window.focusedWindow().nudgeUp( 5 ); });
bind( 'down',  mCmd, function() { Window.focusedWindow().nudgeDown( 5 ); });

// <SHIFT> + cursor keys grows/shrinks the focussed window.
bind( 'left',  mShift, function() { Window.focusedWindow().shrinkWidth(); });
bind( 'right', mShift, function() { Window.focusedWindow().growWidth(); });
bind( 'up',    mShift, function() { Window.focusedWindow().shrinkHeight(); });
bind( 'down',  mShift, function() { Window.focusedWindow().growHeight(); });

api.bind( 'f', mHyper, function() { api.launch('Finder') });
api.bind( 'e', mHyper, function() { api.launch('Macvim') });

// ############################################################################
// Bindings for specific apps
// ############################################################################

function getAppInfo( title ) {
  var app = App.findByTitle(title),
      msg = title;

  msg += ' ' + app;
  if( app ) {
      app.activate();
      app.show();

      msg += '\nisHidden: ' + app.isHidden();

      msg += '\nallWindows: ';
      app.allWindows().forEach(function(win) {
          msg += '"' + win.title() + '" ';
      });
      msg += '\nvisibleWindows: ';
      app.visibleWindows().forEach(function(win) {
          msg += '"' + win.title() + '" ';
      });
  }
  msg += '\nallWindows:\n';
  Window.allWindows().forEach(function(win) {
      msg += '"' + win.title() + '"\n';
  });
  msg += '\nallWindows app titles:\n';
  Window.allWindows().forEach(function(win) {
      msg += '"' + win.app().title() + '"\n';
  });

  return msg;
}

// Debug
api.bind( 'f10', mCmd, function() {
  //api.alert( getAppInfo('Google Chrome'), 10 );
  //api.launch('Google Chrome')
  api.alert( 'Hello there!!!', 10);
  //api.cancelAlerts();
});

bind( '1', mNone, function() {
  var forklift = App.findByTitle('ForkLift').firstWindow();
  if (forklift) {
    forklift.toGrid(0.15, 0.1, 0.6, 0.7);
  }
  disableKeys();
});

// Chrome Devtools
// When checking HTML/JS in Chrome I want to have my browsing window to the
// East and my Chrome devtools window to the W, the latter not quite full height.
bind( 'd', mNone, function() {
  var chrome = App.findByTitle('Google Chrome'),
    browseWindow = chrome.findWindowNotMatchingTitle('^Developer Tools -'),
    devToolsWindow = chrome.findWindowMatchingTitle('^Developer Tools -');

  api.alert( 'Chrome Dev Tools Layout', 0.25 );
  if ( browseWindow ) {
    browseWindow.toE();
  }
  if ( devToolsWindow ) {
    devToolsWindow.toGrid( 0, 0, 0.5, 1 );
  }
  disableKeys();
});

// ############################################################################
// Helpers
// ############################################################################

// Cycle args for the function, if called repeatedly
// cycleCalls(fn, [ [args1...], [args2...], ... ])
var lastCall = null;
function cycleCalls(fn, argsList) {
  var argIndex = 0, identifier = {};
  return function () {
    if (lastCall !== identifier || ++argIndex >= argsList.length) {
      argIndex = 0;
    }
    lastCall = identifier;
    fn.apply(this, argsList[argIndex]);
  };
}

// Disables all remembered keys.
function disableKeys() {
  active = false;
  _(keys).each(function(key) {
    key.disable();
  });
  api.cancelAlerts();
  //api.alert("done", 0.5);
}

// Enables all remembered keys.
function enableKeys() {
  active = true;
  _(keys).each(function(key) {
    key.enable();
  });
  api.alert("Phoenix window manager active", 999999);
}

// ### Helper methods `Window`
//
// #### Window#toGrid()
//
// This method can be used to push a window to a certain position and size on
// the screen by using four floats instead of pixel sizes.  Examples:
//
//     // Window position: top-left; width: 25%, height: 50%
//     someWindow.toGrid( 0, 0, 0.25, 0.5 );
//
//     // Window position: 30% top, 20% left; width: 50%, height: 35%
//     someWindow.toGrid( 0.3, 0.2, 0.5, 0.35 );
//
// The window will be automatically focussed.  Returns the window instance.
function windowToGrid(window, x, y, width, height) {
  var screen = window.screen().frameWithoutDockOrMenu();

  window.setFrame({
    x: Math.round( x * screen.width ) + padding + screen.x,
    y: Math.round( y * screen.height ) + padding + screen.y,
    width: Math.round( width * screen.width ) - ( 2 * padding ),
    height: Math.round( height * screen.height ) - ( 2 * padding )
  });

  window.focusWindow();

  return window;
}

function toGrid(x, y, width, height) {
  windowToGrid(Window.focusedWindow(), x, y, width, height);
}

Window.prototype.toGrid = function(x, y, width, height) {
  windowToGrid(this, x, y, width, height);
};

// Convenience method, doing exactly what it says. Returns the window instance.
Window.prototype.toFullScreen = function() {
  return this.toGrid( 0, 0, 1, 1 );
};

// Push the window to the East/West/North/South. Returns the window instance.
Window.prototype.toE = function() { return this.toGrid( 0.5, 0, 0.5, 1 ); };
Window.prototype.toW = function() { return this.toGrid( 0, 0, 0.5, 1 ); };
Window.prototype.toN = function() { return this.toGrid( 0, 0, 1, 0.5 ); };
Window.prototype.toS = function() { return this.toGrid( 0, 0.5, 1, 0.5 ); };

// Make full screen or restore if full screen. Returns the window instance.
Window.prototype.toggleFullscreen = function() {
  if ( previousSizes[ this ] ) {
    this.setFrame( previousSizes[ this ] );
    delete previousSizes[ this ];
  } else {
    previousSizes[ this ] = this.frame();
    this.toFullScreen();
  }
  return this;
};

// Move the currently focussed window left by [`nudgePixel`] pixels.
Window.prototype.nudgeLeft = function( factor ) {
  var win = this,
    frame = win.frame(),
    pixels = nudgePixels * ( factor || 1 );

  if (frame.x >= pixels) {
    frame.x -= pixels;
  } else {
    frame.x = 0;
  }
  win.setFrame( frame );
};

// Move the currently focussed window right by [`nudgePixel`] pixels.
Window.prototype.nudgeRight = function( factor ) {
  var win = this,
    frame = win.frame(),
    maxLeft = win.screen().frameIncludingDockAndMenu().width - frame.width,
    pixels = nudgePixels * ( factor || 1 );

  if (frame.x < maxLeft - pixels) {
    frame.x += pixels;
  } else {
    frame.x = maxLeft;
  }
  win.setFrame( frame );
};

// Move the currently focussed window left by [`nudgePixel`] pixels.
Window.prototype.nudgeUp = function( factor ) {
  var win = this,
    frame = win.frame(),
    pixels = nudgePixels * ( factor || 1 );

  if (frame.y >= pixels) {
    frame.y -= pixels;
  } else {
    frame.y = 0;
  }
  win.setFrame( frame );
};

// Move the currently focussed window right by [`nudgePixel`] pixels.
Window.prototype.nudgeDown = function( factor ) {
  var win = this,
    frame = win.frame(),
    maxTop = win.screen().frameIncludingDockAndMenu().height - frame.height,
    pixels = nudgePixels * ( factor || 1 );

  if (frame.y < maxTop - pixels) {
    frame.y += pixels;
  } else {
    frame.y = maxTop;
  }
  win.setFrame( frame );
};

// #### Functions for growing / shrinking the focussed window.

Window.prototype.growWidth = function() {
  this.nudgeLeft(3);

  var win = this,
  frame = win.frame(),
  screenFrame = win.screen().frameIncludingDockAndMenu(),
  pixels = nudgePixels * 6;

  if (frame.width < screenFrame.width - pixels) {
    frame.width += pixels;
  } else {
    frame.width = screenFrame.width;
  }

  win.setFrame(frame);
};

Window.prototype.growHeight = function() {
  this.nudgeUp(3);

  var win = this,
  frame = win.frame(),
  screenFrame = win.screen().frameIncludingDockAndMenu(),
  pixels = nudgePixels * 6;

  if (frame.height < screenFrame.height - pixels) {
    frame.height += pixels;
  } else {
    frame.height = screenFrame.height;
  }

  win.setFrame(frame);
};

Window.prototype.shrinkWidth = function() {
  var win = this,
  frame = win.frame(),
  screenFrame = win.screen().frameIncludingDockAndMenu(),
  pixels = nudgePixels * 6;

  if (frame.width >= pixels * 2) {
    frame.width -= pixels;
  } else {
    frame.width = pixels;
  }

  win.setFrame(frame);

  this.nudgeRight(3);
};

Window.prototype.shrinkHeight = function() {
  var win = this,
  frame = win.frame(),
  screenFrame = win.screen().frameWithoutDockOrMenu(),
  pixels = nudgePixels * 6;

  if (frame.height >= pixels * 2) {
    frame.height -= pixels;
  } else {
    frame.height = pixels;
  }

  win.setFrame(frame);

  this.nudgeDown(3);
};

// ### Helper methods `App`
//
// Finds the window with a certain title.  Expects a string, returns a window
// instance or `undefined`.  If there are several windows with the same title,
// the first found instance is returned.
App.findByTitle = function( title ) {
  return _( this.runningApps() ).find( function( app ) {
    if ( app.title() === title ) {
      app.show();
      return true;
    }
  });
};

// Finds the window whose title matches a regex pattern.  Expects a string
// (the pattern), returns a window instance or `undefined`.  If there are
// several matching windows, the first found instance is returned.
App.prototype.findWindowMatchingTitle = function( title ) {
  var regexp = new RegExp( title );

  return _( this.visibleWindows() ).find( function( win ) {
    return regexp.test( win.title() );
  });
};

// Finds the window whose title doesn't match a regex pattern.  Expects a
// string (the pattern), returns a window instance or `undefined`.  If there
// are several matching windows, the first found instance is returned.
App.prototype.findWindowNotMatchingTitle = function( title ) {
  var regexp = new RegExp( title );

  return _( this.visibleWindows() ).find( function( win ) {
    return !regexp.test( win.title() );
  });
};

// Returns the first visible window of the app or `undefined`.
App.prototype.firstWindow = function() {
  return this.visibleWindows()[ 0 ];
};

// Init
// Initially disable all hotkeys
disableKeys();
