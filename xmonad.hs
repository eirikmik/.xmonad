import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Layout.Gaps
import XMonad.Layout.Minimize -- not configured yet
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO
 

myManageHook :: [ManageHook]
myManageHook = 
	[ resource =? "Do" --> doIgnore ]


main = do
  xmproc <- spawnPipe "/usr/bin/xmobar /home/eirikmik/.xmonad/xmobarrc"
  synapse <- spawnPipe "/usr/bin/synapse -s"
  trayer <- spawnPipe "trayer --transparent true --tint FFFFFF --alpha 0 --edge top --align right --widthtype pixel --width 250 --heighttype pixel --height 17 --monitor 2"
  gnomesession <- spawnPipe "gnome-session"
  xmonad defaultConfig {
    modMask = mod4Mask, 
    terminal = "gnome-terminal",
    manageHook = ( isFullscreen --> doFullFloat ) <+> manageDocks <+> manageHook defaultConfig <+> composeAll myManageHook,
--    manageHook = manageDocks <+> manageHook defaultConfig,
    layoutHook = avoidStruts $ layoutHook defaultConfig, 
    logHook = dynamicLogWithPP $ xmobarPP
                        { ppOutput = hPutStrLn xmproc,
                          ppTitle = xmobarColor "green" "" . shorten 50
                        }
  }
