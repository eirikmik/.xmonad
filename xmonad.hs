import XMonad
import XMonad.Layout.Spacing
import XMonad.Layout.Gaps
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run
import XMonad.Util.EZConfig
import XMonad.Actions.CycleWS
import XMonad.Layout.Maximize
import XMonad.Layout.MultiToggle
import XMonad.Layout.NoBorders
import XMonad.Layout.MultiToggle.Instances
import XMonad.Hooks.ManageHelpers
import XMonad.Actions.UpdatePointer
import XMonad.Actions.GridSelect
import XMonad.Hooks.SetWMName
import XMonad.Util.NamedScratchpad
import XMonad.Util.WorkspaceCompare
import XMonad.Hooks.FadeInactive
import XMonad.Layout.Minimize
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeWindows
import Graphics.X11.ExtraTypes.XF86
import System.IO
import Data.Monoid
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "gnome-terminal"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
--xmobarEscape = concatMap doubleLts
--  where doubleLts '<' = "<<"
--        doubleLts x   = [x]

myWorkspaces = ["1: TERM","2: WEB","3: CODE","4: COMM","5: MAIL","6: ETC"] ++ map show [7..8] ++ ["NSP"]
     --where
     --    clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" |
     --                        (i,ws) <- zip [1..9] l,
     --                       let n = i ]
    --where clickable l = ["<action=`xdotool key super+" ++ show (n) ++ "`>" ++ ws ++ "</action>" | (i,ws) <- zip [1..9] l, let n = i ]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "black"
myFocusedBorderColor = "#705A2B"
                    --"#E39402"
                    --"#00F2FF"

-- Scratch Pads
myScratchpads = [--NS "zeal" "zeal" (className =? "Zeal") (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)),
                 --NS "telegram" "telegram" (className =? "Telegram") (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)),
                 --NS"termite" "termite -e ~/bin/tmux-stream-dev.sh" (className =? "Termite") (customFloating $ W.RationalRect (1/10) (1/10) (4/5) (4/5))
                 ]

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask,  xK_Return), spawn $ XMonad.terminal conf)

    -- launch thunar
    , ((modm .|. shiftMask, xK_f     ), spawn "thunar")

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "rofi -show run")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- lock screen using gnome-screensaver
    , ((modm .|. shiftMask, xK_l    ), spawn "gnome-screensaver-command -l")

    -- launch zeal
    , ((modm,               xK_z     ), namedScratchpadAction myScratchpads "zeal")

    -- launch telegram
    , ((modm,               xK_F10   ), namedScratchpadAction myScratchpads "telegram")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

    -- Grid Select
    , ((modm,               xK_g     ), goToSelected defaultGSConfig)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    --, ((modm,               xK_m     ), windows W.focusMaster  )
    , ((modm,               xK_m     ), withFocused minimizeWindow)
    , ((modm .|. shiftMask, xK_m     ), sendMessage RestoreNextMinimizedWin)

    -- Maximize selected window
    , ((modm, 				xK_f     ), (sendMessage $ Toggle FULL))

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Switch workspaces and screens
    , ((modm,               xK_Right),  moveTo Next (WSIs hiddenNotNSP))
    , ((modm,               xK_Left),   moveTo Prev (WSIs hiddenNotNSP))
    , ((modm .|. shiftMask, xK_Right),  shiftTo Next (WSIs hiddenNotNSP))
    , ((modm .|. shiftMask, xK_Left),   shiftTo Prev (WSIs hiddenNotNSP))
    , ((modm,               xK_Down),   nextScreen)
    , ((modm,               xK_Up),     prevScreen)
    , ((modm .|. shiftMask, xK_Down),   shiftNextScreen)
    , ((modm .|. shiftMask, xK_Up),     shiftPrevScreen)

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


hiddenNotNSP :: X (WindowSpace -> Bool)
hiddenNotNSP = do
  hs <- gets $ map W.tag . W.hidden . windowset
  return (\w -> (W.tag w) /= "NSP" && (W.tag w) `elem` hs)

addKeys = [ ("<XF86AudioLowerVolume>"        ,spawn "pulseaudio-ctl down 10")
    	  , ("<XF86AudioRaiseVolume>"        ,spawn "pulseaudio-ctl up 10"  )
    	  , ("<XF86AudioMute>"               ,spawn "pulseaudio-ctl mute"   )
    	  , ("<XF86MonBrightnessDown>"       ,spawn "light -U 5"            )
    	  , ("<XF86MonBrightnessUp>"         ,spawn "light -A 5"            )
    	  , ("<XF86AudioPlay>"               ,spawn "play-pause-mpd.sh"     )
    	  , ("<XF86AudioPrev>"               ,spawn "mpc prev"     )
    	  , ("<XF86AudioNext>"               ,spawn "mpc next"     )
          , ("<F12>"                         ,namedScratchpadAction myScratchpads "termite")
		  ]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = smartBorders $ avoidStruts $ minimize (mkToggle (NOBORDERS ?? FULL ?? EOT) (tiled ||| Mirror tiled ||| Full))
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = gaps [(U,3), (R,3), (L,3), (R,3)] $ spacing 3 $ Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , className =? "Xfce4-notifyd"  --> doIgnore]
    <+> (isFullscreen --> doFullFloat)
    <+> manageDocks
    <+> (namedScratchpadManageHook myScratchpads)

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--myLogHook :: Handle -> X ()
--myLogHook h = dynamicLogWithPP $ defaultPP
--    {
--        ppCurrent           =   dzenColor "#9BC1B2" "#1B1D1E" . pad
--      , ppVisible           =   dzenColor "gray" "#1B1D1E" . pad
--      , ppHidden            =   dzenColor "gray" "#1B1D1E" . pad
--      , ppHiddenNoWindows   =   dzenColor "gray" "#1B1D1E" . pad
--      , ppUrgent            =   dzenColor "#F73E3E" "#1B1D1E" . pad
--      , ppCurrent           =   dzenColor "#9BC1B2" "#181D1E" . pad
--      , ppWsSep             =   " "
--      , ppSep               =   "  |  "
--      , ppLayout            =   dzenColor "#ebac54" "#1B1D1E" .
--                                (\x -> case x of
--                                    "ResizableTall"             ->      "^i(" ++ myBitmapsDir ++ "/tall.xbm)"
--                                    "Mirror ResizableTall"      ->      "^i(" ++ myBitmapsDir ++ "/mtall.xbm)"
--                                    "Full"                      ->      "^i(" ++ myBitmapsDir ++ "/full.xbm)"
--                                    "Simple Float"              ->      "~"
--                                    _                           ->      x
--                                )
--      , ppTitle             =   (" " ++) . dzenColor "#9BC1B2" "#1B1D1E" . dzenEscape
--      , ppOutput            =   hPutStrLn h
--    }
--    >> updatePointer (0.75, 0.75) (0.75, 0.75)
--    >> (fadeOutLogHook $ fadeIf ((className =? "URxvt")) 0.93)


myLogHook xmproc = dynamicLogWithPP xmobarPP
                     { ppOutput = hPutStrLn xmproc
                     , ppCurrent = xmobarColor "#A28C5D" "" . wrap "[" "]"   -- #9BC1B2
                     , ppTitle = xmobarColor "#A28C5D" "" . shorten 50       -- #9BC1B2
                     , ppSort = fmap (.namedScratchpadFilterOutWorkspace) getSortByTag
                     }
                     >> updatePointer (0.75, 0.75) (0.75, 0.75)
                     >> (fadeOutLogHook $ fadeIf ((className =? "URxvt")) 0.93)


------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = setWMName "LG3D"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
myConfig xmproc = (defaults xmproc) `additionalKeysP` addKeys

main = do
    xmproc <- spawnPipe "/usr/bin/xmobar /home/eirikmik/.xmobarrc"
    xmonad $ ewmh $ myConfig xmproc


-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults xmproc = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook xmproc,
        startupHook        = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
