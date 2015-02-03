-- Ensure the IPC command line client is available
hs.ipc.cliInstall()

-- Things we need to clean up at reload
local configFileWatcher = nil
local appWatcher = nil

hs.window.animationDuration = 0
local padding = 0

-- Define some keyboard modifier variables
-- Note: Capslock bound to cmd+alt+ctrl+shift via Seil and Karabiner
local mNone  = {}
local mAlt   = {"⌥"}
local mHyper = {"⌘", "⌥", "⌃", "⇧"}

-- Modal activation / deactivation
local keys = {}
local modalActive = false

function bind( mods, key, callback )
    table.insert( keys, hs.hotkey.new( mods, key, callback ) )
end

function disableKeys()
    modalActive = false
    for keyCount = 1, #keys do
        keys[ keyCount ]:disable()
    end
    hs.alert.closeAll()
end

function enableKeys()
    modalActive = true
    for keyCount = 1, #keys do
        keys[ keyCount ]:enable()
    end
    hs.alert.show( "Window manager active", 999999 )
end

hs.hotkey.bind( mHyper, 'a', function()
    if( modalActive ) then
        disableKeys()
    else
        enableKeys()
    end
end )

-- Cycle args for the function, if called repeatedly
-- cycleCalls(fn, [ [args1...], [args2...], ... ])
function cycleCalls( fn, args )
    local argIndex = 0
    return function()
        argIndex = argIndex + 1
        if (argIndex > #args) then
            argIndex = 1;
        end
        fn( args[ argIndex ] );
    end
end

-- This method can be used to push a window to a certain position and size on
-- the screen by using four floats instead of pixel sizes.  Examples:
--
--     someWindow:toGrid( 0, 0, 0.25, 0.5 );     -- top-left, width: 25%, height: 50%
--     someWindow:toGrid( 0.3, 0.2, 0.5, 0.35 ); -- top: 30%, left: 20%, width: 50%, height: 35%
--
-- The window will be automatically focussed.  Returns the window instance.
function windowToGrid( window, rect )
    if not window then
        return
    end

    local screen = hs.screen.mainScreen():fullFrame()
    window:setFrame( {
        x = math.floor( rect[1] * screen.w + .5 ) + padding + screen.x,
        y = math.floor( rect[2] * screen.h + .5 ) + padding + screen.y,
        w = math.floor( rect[3] * screen.w + .5 ) - 2 * padding,
        h = math.floor( rect[4] * screen.h + .5 ) - 2 * padding
    } )
    -- window:focus()
    return window
end

function toGrid( x, y, w, h )
    windowToGrid( hs.window.focusedWindow(), x, y, w, h );
end

bind( mNone, 'escape', function() disableKeys() end )
bind( mNone, 'return', function() disableKeys() end )
-- Centre window
bind( mNone, 'c', cycleCalls( toGrid, {{.04, 0, 0.92, 1},{0.22, 0.025, 0.56, 0.95},{0.1, 0, 0.8, 1}} ) )
-- Space toggles the focussed between full screen and its initial size and position.
bind( mNone, 'space', function() hs.window.focusedWindow():toggleFullScreen() end )
-- The cursor keys make any window occupy one side of the screen.
bind( mNone, 'left',  cycleCalls( toGrid, { {0, 0, 0.5, 1},   {0, 0, 0.6, 1},   {0, 0, 0.4, 1} } ));
bind( mNone, 'right', cycleCalls( toGrid, { {0.5, 0, 0.5, 1}, {0.4, 0, 0.6, 1}, {0.6, 0, 0.4, 1} } ));
bind( mNone, 'up',    function() toGrid( {0, 0,   1, 0.3 } ) end )
bind( mNone, 'down',  function() toGrid( {0, 0.7, 1, 0.3 } ) end )

-------------------------------------------------------------------------
-- Toggle Skype between muted/unmuted, whether it is focused or not
function toggleSkypeMute()
    local skype = hs.appfinder.appFromName("Skype")
    if not skype then
        return
    end

    local lastapp = nil
    if not skype:isFrontmost() then
        lastapp = hs.application.frontmostApplication()
        skype:activate()
    end

    if not skype:selectMenuItem({"Conversations", "Mute Microphone"}) then
        skype:selectMenuItem({"Conversations", "Unmute Microphone"})
    end

    if lastapp then
        lastapp:activate()
    end
end

-- Toggle an application between being the frontmost app, and being hidden
function toggle_application(_app)
    local app = hs.appfinder.appFromName(_app)
    if not app then
        -- FIXME: This should really launch _app
        return
    end
    local mainwin = app:mainWindow()
    if mainwin == hs.window.focusedWindow() then
        mainwin:application():hide()
    else
        mainwin:application():activate(true)
        mainwin:application():unhide()
        mainwin:focus()
    end
end

-- Callback function for application events
function applicationWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        if (appName == "Finder") then
            -- Bring all Finder windows forward when one gets activated
            appObject:selectMenuItem({"Window", "Bring All to Front"})
        end
    end
end

-- Reload config automatically
function reloadConfig()
    configFileWatcher:stop()
    configFileWatcher = nil

    appWatcher:stop()
    appWatcher = nil

    hs.reload()
end

-- Hotkeys to move windows between screens
hs.hotkey.bind(mHyper, 'Left', function() hs.window.focusedWindow():moveOneScreenWest() end)
hs.hotkey.bind(mHyper, 'Right', function() hs.window.focusedWindow():moveOneScreenEast() end)

-- Hotkeys to resize windows absolutely
-- hs.hotkey.bind(mHyper, 'a', function() hs.window.focusedWindow():moveToUnit(hs.layout.left30) end)
hs.hotkey.bind(mHyper, 's', function() hs.window.focusedWindow():moveToUnit(hs.layout.right70) end)
hs.hotkey.bind(mHyper, '[', function() hs.window.focusedWindow():moveToUnit(hs.layout.left50) end)
hs.hotkey.bind(mHyper, ']', function() hs.window.focusedWindow():moveToUnit(hs.layout.right50) end)
hs.hotkey.bind(mHyper, 'f', function() hs.window.focusedWindow():maximize() end)
hs.hotkey.bind(mHyper, 'r', function() hs.window.focusedWindow():toggleFullScreen() end)

-- Application hotkeys
hs.hotkey.bind(mHyper, '`', function() hs.application.launchOrFocus("iTerm") end)
hs.hotkey.bind(mHyper, 'q', function() toggle_application("Safari") end)
hs.hotkey.bind(mHyper, 'z', function() toggle_application("Reeder") end)
hs.hotkey.bind(mHyper, 'w', function() toggle_application("IRC") end)

-- Misc hotkeys
hs.hotkey.bind(mHyper, 'y', hs.toggleConsole)
hs.hotkey.bind(mHyper, 'n', function() os.execute("open ~") end)
hs.hotkey.bind(mHyper, 'Escape', toggle_audio_output)
hs.hotkey.bind(mHyper, 'm', toggleSkypeMute)
-- Can't use this until we fix https://github.com/Hammerspoon/hammerspoon/issues/203
--hs.hotkey.bind({}, 'F17', function() hs.eventtap.keyStrokes({}, hs.pasteboard.getContents()) end)

-- Create and start our callbacks
configFileWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
configFileWatcher:start()

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

-- Finally, show a notification that we finished loading the config successfully
hs.notify.show("Hammerspoon", "", "Config loaded", "")
