-- spaces = require("spaces")
spaces = require("hs._asm.undocumented.spaces")

-- Misc setup
hs.window.animationDuration = 0
local vw = hs.inspect.inspect
local configFileWatcher = nil
local appWatcher = nil

-- Keyboard modifiers, Capslock bound to cmd+alt+ctrl+shift via Seil and Karabiner
local modNone  = {}
local mAlt     = {"⌥"}
local modCmd   = {"⌘"}
local modShift = {"⇧"}
local modHyper = {"⌘", "⌥", "⌃", "⇧"}

-- Reload config automatically
function reloadConfig()
    configFileWatcher:stop()
    configFileWatcher = nil
    appWatcher:stop()
    appWatcher = nil
    hs.reload()
end

configFileWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
configFileWatcher:start()

-- Callback function for application events
function applicationWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        if (appName == "Finder") then
            -- Bring all Finder windows forward when one gets activated
            appObject:selectMenuItem({"Window", "Bring All to Front"})
        end
    end
end

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

-- Modal activation / deactivation
local modalKeys = {}
local modalActive = false

function modalBind( mods, key, callback )
    table.insert( modalKeys, hs.hotkey.new( mods, key, callback ) )
end

function disableModal()
    modalActive = false
    for keyCount = 1, #modalKeys do
        modalKeys[ keyCount ]:disable()
    end
    hs.alert.closeAll()
end

function enableModal()
    modalActive = true
    for keyCount = 1, #modalKeys do
        modalKeys[ keyCount ]:enable()
    end
    hs.alert.show( "Window manager active", 999999 )
end

function caffeinate()
    hs.caffeinate.toggle("displayIdle")
    if hs.caffeinate.get("displayIdle") then
        hs.alert.show("Staying AWAKE!", 2)
    else
        hs.alert.show("Sleepy", 2)
    end
end

hs.hotkey.bind( modHyper, 'a', function()
    if( modalActive ) then
        disableModal()
    else
        enableModal()
    end
end )
modalBind( modNone, 'escape', function() disableModal() end )
modalBind( modNone, 'return', function() disableModal() end )

-- Cycle args for the function when called repeatedly: cycleCalls( fn, { {args1...}, ... } )
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

-- This method can be used to place a window to a position and size on the screen by using 
-- four floats instead of pixel sizes. Returns the window instance. Examples:
--     windowToGrid( someWindow, 0, 0, 0.25, 0.5 );     -- top-left, width: 25%, height: 50%
--     windowToGrid( someWindow, 0.3, 0.2, 0.5, 0.35 ); -- top: 30%, left: 20%, width: 50%, height: 35%
function windowToGrid( window, rect )
    -- TODO: change rect to use named indices rather than integer
    if not window then
        return window
    end

    local screen = hs.screen.mainScreen():fullFrame()
    window:setFrame( {
        x = math.floor( rect[1] * screen.w + .5 ) + screen.x,
        y = math.floor( rect[2] * screen.h + .5 ) + screen.y,
        w = math.floor( rect[3] * screen.w + .5 ),
        h = math.floor( rect[4] * screen.h + .5 )
    } )
    return window
end

function toGrid( x, y, w, h )
    windowToGrid( hs.window.focusedWindow(), x, y, w, h );
end

-- Toggle between full screen and orginial size. Returns the window instance.
local previousSizes = {}
function toggleMaximize( window )
    if not window then
        return window
    end

    local id = window:id()
    if previousSizes[ id ] == nil then
        previousSizes[ id ] = window:frame()
        window:maximize()
    else
        window:setFrame( previousSizes[ id ] )
        previousSizes[ id ] = nil
    end

    return window
end

-- Microphone mute/unmute
local microphoneLevel = 75      -- my default level
function toggleMicrophoneMute()
    success, currentVolume = hs.applescript.applescript( "input volume of (get volume settings)" )
    if success then
        if currentVolume == 0 then
            success, junk = hs.applescript.applescript( "set volume input volume " .. microphoneLevel )
            hs.notify.new( {title='Microphone unmuted', subTitle='Level: '..microphoneLevel} ):send()
        else
            success, junk = hs.applescript.applescript( "set volume input volume 0" )
            hs.notify.new( {title='Microphone muted'} ):send()
            microphoneLevel = currentVolume
        end
    end
end

-- Debug: for trying out snippets of code
function dbg()
    apps = hs.application.runningApplications()
    for appIndex=1,#apps do
        app = apps[appIndex]
        print( app:pid() .. ' ' .. app:title() )
    end
end

-- ------------------------
-- Modal keys
-- ------------------------
-- Centre window
modalBind( modNone, 'c', cycleCalls( toGrid, {{0.1,0,0.8,1},{.04, 0, 0.92, 1},{0.22, 0.025, 0.56, 0.95}} ) )
-- Toggle between maximized and its initial size and position.
modalBind( modNone, 'space', function() toggleMaximize(  hs.window.focusedWindow() ) end )
-- Size/position to one side of the screen
modalBind( modNone, 'left',  cycleCalls( toGrid, { {0, 0, 0.5, 1},   {0, 0, 0.6, 1},   {0, 0, 0.4, 1} } ));
modalBind( modNone, 'right', cycleCalls( toGrid, { {0.5, 0, 0.5, 1}, {0.4, 0, 0.6, 1}, {0.6, 0, 0.4, 1} } ));
modalBind( modNone, 'up',    function() toGrid( {0, 0,   1, 0.3 } ) end )
modalBind( modNone, 'down',  function() toGrid( {0, 0.7, 1, 0.3 } ) end )

-- ------------------------
-- Non-modal keys
-- ------------------------
hs.hotkey.bind( modHyper, 'c', caffeinate )
hs.hotkey.bind( modHyper, 'f', function() hs.application.launchOrFocus( "Finder" ) end )
hs.hotkey.bind( modHyper, 'h', function() os.execute( "open ~" ) end )
-- hs.hotkey.bind( modHyper, 'q', function() hs.application.launchOrFocus( "Google Chrome" ) end )
-- hs.hotkey.bind( modHyper, 'w', function() hs.application.launchOrFocus( "iTerm" ) end )
hs.hotkey.bind( modHyper, 'm', toggleMicrophoneMute )
hs.hotkey.bind( modHyper, 'y', hs.toggleConsole )
-- hs.hotkey.bind( modHyper, '1', spaces.movetospace(1) )
-- hs.hotkey.bind( modHyper, '2', spaces.movetospace(2) )

-- Finally, show a notification that we finished loading the config
hs.notify.new( {title='Hammerspoon', subTitle='Configuration loaded'} ):send()

-------------------------------------------------------------------------
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
