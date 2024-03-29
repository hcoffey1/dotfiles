  -- Base
import XMonad
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

    -- Actions
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import qualified XMonad.Actions.TreeSelect as TS
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S

    -- Data
import Data.Char (isSpace, toUpper)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks (avoidStruts, docks, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory

    -- Layouts
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

    -- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

    -- Prompt
import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Man
import XMonad.Prompt.Pass
import XMonad.Prompt.Shell
import XMonad.Prompt.Ssh
import XMonad.Prompt.XMonad
import Control.Arrow (first)

   -- Utilities
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

myFont :: String
myFont = "xft:Mononoki Nerd Font:bold:size=9:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod1Mask       -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "alacritty"   -- Sets default terminal

myBrowser :: String
myBrowser = "firefox "               -- Sets qutebrowser as browser for tree select
-- myBrowser = myTerminal ++ " -e lynx " -- Sets lynx as browser for tree select

myEditor :: String
myEditor = "emacsclient -c -a emacs "  -- Sets emacs as editor for tree select
-- myEditor = myTerminal ++ " -e vim "    -- Sets vim as editor for tree select

myBorderWidth :: Dimension
myBorderWidth = 4          -- Sets border width for windows

myNormColor :: String
myNormColor   = "#282c34"  -- Border color of normal windows

myFocusColor :: String
myFocusColor  = "#46d9ff"  -- Border color of focused windows

altMask :: KeyMask
altMask = mod1Mask         -- Setting this for use in xprompts

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
          --spawnOnce "nitrogen --restore &"
          spawnOnce "feh --randomize --bg-fill Pictures/wallpapers/*"
          spawnOnce "xrandr --auto --output HDMI-1 --right-of HDMI-0"
          spawnOnce "picom &"
          spawnOnce "nm-applet &"
          spawnOnce "volumeicon &"
          spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x282c34  --height 22 &"
          -- spawnOnce "/usr/bin/emacs --daemon &"
          -- spawnOnce "kak -d -s mysession &"
          setWMName "LG3D"

myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
                  (0x28,0x2c,0x34) -- lowest inactive bg
                  (0x28,0x2c,0x34) -- highest inactive bg
                  (0xc7,0x92,0xea) -- active bg
                  (0xc0,0xa7,0x9a) -- inactive fg
                  (0x28,0x2c,0x34) -- active fg

-- gridSelect menu layout
mygridConfig :: p -> GSConfig Window
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 40
    , gs_cellwidth    = 200
    , gs_cellpadding  = 6
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont
    }

spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = def
                   { gs_cellheight   = 40
                   , gs_cellwidth    = 200
                   , gs_cellpadding  = 6
                   , gs_originFractX = 0.5
                   , gs_originFractY = 0.5
                   , gs_font         = myFont
                   }

myAppGrid = [ ("Audacity", "audacity")
                 , ("Deadbeef", "deadbeef")
                 , ("Emacs", "emacsclient -c -a emacs")
                 , ("Firefox", "firefox")
                 , ("Geany", "geany")
                 , ("Geary", "geary")
                 , ("Gimp", "gimp")
                 , ("Kdenlive", "kdenlive")
                 , ("LibreOffice Impress", "loimpress")
                 , ("LibreOffice Writer", "lowriter")
                 , ("OBS", "obs")
                 , ("PCManFM", "pcmanfm")
                 ]

treeselectAction :: TS.TSConfig (X ()) -> X ()
treeselectAction a = TS.treeselectAction a
   [ Node (TS.TSNode "+ Accessories" "Accessory applications" (return ()))
       [ Node (TS.TSNode "Archive Manager" "Tool for archived packages" (spawn "file-roller")) []
       , Node (TS.TSNode "Calculator" "Gui version of qalc" (spawn "qalculate-gtk")) []
       , Node (TS.TSNode "Calibre" "Manages books on my ereader" (spawn "calibre")) []
       , Node (TS.TSNode "Castero" "Terminal podcast client" (spawn (myTerminal ++ " -e castero"))) []
       , Node (TS.TSNode "Picom Toggle on/off" "Compositor for window managers" (spawn "killall picom; picom")) []
       , Node (TS.TSNode "Virt-Manager" "Virtual machine manager" (spawn "virt-manager")) []
       , Node (TS.TSNode "Virtualbox" "Oracle's virtualization program" (spawn "virtualbox")) []
       ]
   , Node (TS.TSNode "+ Games" "fun and games" (return ()))
       [ Node (TS.TSNode "0 A.D" "Real-time strategy empire game" (spawn "0ad")) []
       , Node (TS.TSNode "Battle For Wesnoth" "Turn-based stretegy game" (spawn "wesnoth")) []
       , Node (TS.TSNode "Steam" "The Steam gaming platform" (spawn "steam")) []
       , Node (TS.TSNode "SuperTuxKart" "Open source kart racing" (spawn "supertuxkart")) []
       , Node (TS.TSNode "Xonotic" "Fast-paced first person shooter" (spawn "xonotic")) []
       ]
   , Node (TS.TSNode "+ Graphics" "graphics programs" (return ()))
       [ Node (TS.TSNode "Gimp" "GNU image manipulation program" (spawn "gimp")) []
       , Node (TS.TSNode "Inkscape" "An SVG editing program" (spawn "inkscape")) []
       , Node (TS.TSNode "LibreOffice Draw" "LibreOffice drawing program" (spawn "lodraw")) []
       , Node (TS.TSNode "Shotwell" "Photo management program" (spawn "shotwell")) []
       , Node (TS.TSNode "Simple Scan" "A simple scanning program" (spawn "simple-scan")) []
       ]
   , Node (TS.TSNode "+ Internet" "internet and web programs" (return ()))
       [ Node (TS.TSNode "Brave" "A privacy-oriented web browser" (spawn "brave")) []
       , Node (TS.TSNode "Discord" "Chat and video chat platform" (spawn "discord")) []
       , Node (TS.TSNode "Elfeed" "An Emacs RSS feed reader" (spawn "xxx")) []
       , Node (TS.TSNode "FileZilla" "An FTP client" (spawn "filezilla")) []
       , Node (TS.TSNode "Firefox" "Open source web browser" (spawn "firefox")) []
       , Node (TS.TSNode "Geary" "Email client with a nice UI" (spawn "geary")) []
       , Node (TS.TSNode "Jitsi" "Open source video chat" (spawn "xxx")) []
       , Node (TS.TSNode "Mu4e" "An Emacs email client" (spawn "xxx")) []
       , Node (TS.TSNode "Nextcloud" "File syncing desktop utility" (spawn "nextcloud")) []
       , Node (TS.TSNode "Qutebrowser" "Minimal web browser" (spawn "qutebrowser")) []
       , Node (TS.TSNode "Surf Browser" "Suckless surf web browser" (spawn "surf")) []
       , Node (TS.TSNode "Thunderbird" "Open source email client" (spawn "thunderbird")) []
       , Node (TS.TSNode "Transmission" "Bittorrent client" (spawn "transmission-gtk")) []
       , Node (TS.TSNode "Zoom" "Web conferencing" (spawn "zoom")) []
       ]
   , Node (TS.TSNode "+ Multimedia" "sound and video applications" (return ()))
       [ Node (TS.TSNode "Alsa Mixer" "Alsa volume control utility" (spawn (myTerminal ++ " -e alsamixer"))) []
       , Node (TS.TSNode "Audacity" "Graphical audio editing program" (spawn "audacity")) []
       , Node (TS.TSNode "Deadbeef" "Lightweight music player" (spawn "deadbeef")) []
       , Node (TS.TSNode "EMMS" "Emacs multimedia player" (spawn "xxx")) []
       , Node (TS.TSNode "Kdenlive" "Open source non-linear video editor" (spawn "kdenlive")) []
       , Node (TS.TSNode "OBS Studio" "Open Broadcaster Software" (spawn "obs")) []
       , Node (TS.TSNode "Pianobar" "A terminal Pandora client" (spawn (myTerminal ++ " -e pianobar"))) []
       , Node (TS.TSNode "VLC" "Multimedia player and server" (spawn "vlc")) []
       ]
   , Node (TS.TSNode "+ Office" "office applications" (return ()))
       [ Node (TS.TSNode "LibreOffice" "Open source office suite" (spawn "libreoffice")) []
       , Node (TS.TSNode "LibreOffice Base" "Desktop database front end" (spawn "lobase")) []
       , Node (TS.TSNode "LibreOffice Calc" "Spreadsheet program" (spawn "localc")) []
       , Node (TS.TSNode "LibreOffice Draw" "Diagrams and sketches" (spawn "lodraw")) []
       , Node (TS.TSNode "LibreOffice Impress" "Presentation program" (spawn "loimpress")) []
       , Node (TS.TSNode "LibreOffice Math" "Formula editor" (spawn "lomath")) []
       , Node (TS.TSNode "LibreOffice Writer" "Word processor" (spawn "lowriter")) []
       , Node (TS.TSNode "Zathura" "PDF Viewer" (spawn "zathura")) []
       ]
   , Node (TS.TSNode "+ Programming" "programming and scripting tools" (return ()))
       [ Node (TS.TSNode "+ Emacs" "Emacs is more than a text editor" (return ()))
           [ Node (TS.TSNode "Emacs Client" "Doom Emacs launched as client" (spawn "emacsclient -c -a emacs")) []
           , Node (TS.TSNode "M-x dired" "File manager for Emacs" (spawn "emacsclient -c -a '' --eval '(dired nil)'")) []
           , Node (TS.TSNode "M-x elfeed" "RSS client for Emacs" (spawn "emacsclient -c -a '' --eval '(elfeed)'")) []
           , Node (TS.TSNode "M-x emms" "Emacs" (spawn "emacsclient -c -a '' --eval '(emms)' --eval '(emms-play-directory-tree \"~/Music/Non-Classical/70s-80s/\")'")) []
           , Node (TS.TSNode "M-x erc" "IRC client for Emacs" (spawn "emacsclient -c -a '' --eval '(erc)'")) []
           , Node (TS.TSNode "M-x eshell" "The Eshell in Emacs" (spawn "emacsclient -c -a '' --eval '(eshell)'")) []
           , Node (TS.TSNode "M-x ibuffer" "Emacs buffer list" (spawn "emacsclient -c -a '' --eval '(ibuffer)'")) []
           , Node (TS.TSNode "M-x mastodon" "Emacs" (spawn "emacsclient -c -a '' --eval '(mastodon)'")) []
           , Node (TS.TSNode "M-x mu4e" "Email client for Emacs" (spawn "emacsclient -c -a '' --eval '(mu4e)'")) []
           , Node (TS.TSNode "M-x vterm" "Emacs" (spawn "emacsclient -c -a '' --eval '(+vterm/here nil))'")) []
           ]
        , Node (TS.TSNode "Python" "Python interactive prompt" (spawn (myTerminal ++ " -e python"))) []
       ]
   , Node (TS.TSNode "+ System" "system tools and utilities" (return ()))
       [ Node (TS.TSNode "Alacritty" "GPU accelerated terminal" (spawn "alacritty")) []
       , Node (TS.TSNode "Dired" "Emacs file manager" (spawn "xxx")) []
       , Node (TS.TSNode "Etcher" "USB stick writer" (spawn "xxx")) []
       , Node (TS.TSNode "Glances" "Terminal system monitor" (spawn (myTerminal ++ " -e glances"))) []
       , Node (TS.TSNode "Gufw" "GUI uncomplicated firewall" (spawn "gufw")) []
       , Node (TS.TSNode "Htop" "Terminal process viewer" (spawn (myTerminal ++ " -e htop"))) []
       , Node (TS.TSNode "LXAppearance" "Customize look and feel" (spawn "lxappearance")) []
       , Node (TS.TSNode "Nitrogen" "Wallpaper viewer and setter" (spawn "nitrogen")) []
       , Node (TS.TSNode "Nmon" "Network monitor" (spawn (myTerminal ++ " -e nmon"))) []
       , Node (TS.TSNode "PCManFM" "Lightweight graphical file manager" (spawn "pcmanfm")) []
       , Node (TS.TSNode "Simple Terminal" "Suckless simple terminal" (spawn "st")) []
       , Node (TS.TSNode "Stress Terminal UI" "Stress your system" (spawn (myTerminal ++ " -e vifm"))) []
       , Node (TS.TSNode "Vifm" "Vim-like file manager" (spawn (myTerminal ++ " -e vifm"))) []
       ]
   , Node (TS.TSNode "------------------------" "" (spawn "xdotool key Escape")) []
   , Node (TS.TSNode "+ Bookmarks" "a list of web bookmarks" (return ()))
       [ Node (TS.TSNode "+ Linux" "a list of web bookmarks" (return ()))
           [ Node (TS.TSNode "+ Arch Linux" "btw, i use arch!" (return ()))
               [ Node (TS.TSNode "Arch Linux" "Arch Linux homepage" (spawn (myBrowser ++ "https://www.archlinux.org/"))) []
               , Node (TS.TSNode "Arch Wiki" "The best Linux wiki" (spawn (myBrowser ++ "https://wiki.archlinux.org/"))) []
               , Node (TS.TSNode "AUR" "Arch User Repository" (spawn (myBrowser ++ "https://aur.archlinux.org/"))) []
               , Node (TS.TSNode "Arch Forums" "Arch Linux web forum" (spawn (myBrowser ++ "https://bbs.archlinux.org/"))) []
               ]
           , Node (TS.TSNode "+ Linux News" "linux news and blogs" (return ()))
               [ Node (TS.TSNode "DistroWatch" "Linux distro release announcments" (spawn (myBrowser ++ "https://distrowatch.com/"))) []
               , Node (TS.TSNode "LXer" "LXer linux news aggregation" (spawn (myBrowser ++ "http://lxer.com"))) []
               , Node (TS.TSNode "OMG Ubuntu" "Ubuntu news, apps and reviews" (spawn (myBrowser ++ "https://www.omgubuntu.co.uk"))) []
               ]
           , Node (TS.TSNode "+ Window Managers" "window manager documentation" (return ()))
               [ Node (TS.TSNode "+ Awesome" "awesomewm documentation" (return ()))
                   [ Node (TS.TSNode "Awesome" "Homepage for awesome wm" (spawn (myBrowser ++ "https://awesomewm.org/"))) []
                   , Node (TS.TSNode "Awesome GitHub" "The GutHub page for awesome" (spawn (myBrowser ++ "https://github.com/awesomeWM/awesome"))) []
                   , Node (TS.TSNode "r/awesome" "Subreddit for awesome" (spawn (myBrowser ++ "https://www.reddit.com/r/awesomewm/"))) []
                   ]
               , Node (TS.TSNode "+ Dwm" "dwm documentation" (return ()))
                   [ Node (TS.TSNode "Dwm" "Dynamic window manager" (spawn (myBrowser ++ "https://dwm.suckless.org/"))) []
                   , Node (TS.TSNode "Dwmblocks" "Modular status bar for dwm" (spawn (myBrowser ++ "https://github.com/torrinfail/dwmblocks"))) []
                   , Node (TS.TSNode "r/suckless" "Subreddit for suckless software" (spawn (myBrowser ++ "https://www.reddit.com/r/suckless//"))) []
                   ]
               , Node (TS.TSNode "+ Qtile" "qtile documentation" (return ()))
                   [ Node (TS.TSNode "Qtile" "Tiling window manager in Python" (spawn (myBrowser ++ "http://www.qtile.org"))) []
                   , Node (TS.TSNode "Qtile GitHub" "The GitHub page for qtile" (spawn (myBrowser ++ "https://github.com/qtile/qtile"))) []
                   , Node (TS.TSNode "r/qtile" "Subreddit for qtile" (spawn (myBrowser ++ "https://www.reddit.com/r/qtile/"))) []
                   ]
               , Node (TS.TSNode "+ XMonad" "xmonad documentation" (return ()))
                   [ Node (TS.TSNode "XMonad" "Homepage for XMonad" (spawn (myBrowser ++ "http://xmonad.org"))) []
                   , Node (TS.TSNode "XMonad GitHub" "The GitHub page for XMonad" (spawn (myBrowser ++ "https://github.com/xmonad/xmonad"))) []
                   , Node (TS.TSNode "xmonad-contrib" "Third party extensions for XMonad" (spawn (myBrowser ++ "https://hackage.haskell.org/package/xmonad-contrib"))) []
                   , Node (TS.TSNode "xmonad-ontrib GitHub" "The GitHub page for xmonad-contrib" (spawn (myBrowser ++ "https://github.com/xmonad/xmonad-contrib"))) []
                   , Node (TS.TSNode "Xmobar" "Minimal text-based status bar"  (spawn (myBrowser ++ "https://hackage.haskell.org/package/xmobar"))) []
                   ]
               ]
           ]
       , Node (TS.TSNode "+ Emacs" "Emacs documentation" (return ()))
           [ Node (TS.TSNode "GNU Emacs" "Extensible free/libre text editor" (spawn (myBrowser ++ "https://www.gnu.org/software/emacs/"))) []
           , Node (TS.TSNode "Doom Emacs" "Emacs distribution with sane defaults" (spawn (myBrowser ++ "https://github.com/hlissner/doom-emacs"))) []
           , Node (TS.TSNode "r/emacs" "M-x emacs-reddit" (spawn (myBrowser ++ "https://www.reddit.com/r/emacs/"))) []
           , Node (TS.TSNode "EmacsWiki" "EmacsWiki Site Map" (spawn (myBrowser ++ "https://www.emacswiki.org/emacs/SiteMap"))) []
           , Node (TS.TSNode "Emacs StackExchange" "Q&A site for emacs" (spawn (myBrowser ++ "https://emacs.stackexchange.com/"))) []
           ]
       , Node (TS.TSNode "+ Search and Reference" "Search engines, indices and wikis" (return ()))
           [ Node (TS.TSNode "DuckDuckGo" "Privacy-oriented search engine" (spawn (myBrowser ++ "https://duckduckgo.com/"))) []
           , Node (TS.TSNode "Google" "The evil search engine" (spawn (myBrowser ++ "http://www.google.com"))) []
           , Node (TS.TSNode "Thesaurus" "Lookup synonyms and antonyms" (spawn (myBrowser ++ "https://www.thesaurus.com/"))) []
           , Node (TS.TSNode "Wikipedia" "The free encyclopedia" (spawn (myBrowser ++ "https://www.wikipedia.org/"))) []
           ]
       , Node (TS.TSNode "+ Programming" "programming and scripting" (return ()))
           [ Node (TS.TSNode "+ Bash and Shell Scripting" "shell scripting documentation" (return ()))
               [ Node (TS.TSNode "GNU Bash" "Documentation for bash" (spawn (myBrowser ++ "https://www.gnu.org/software/bash/manual/"))) []
               , Node (TS.TSNode "r/bash" "Subreddit for bash" (spawn (myBrowser ++ "https://www.reddit.com/r/bash/"))) []
               , Node (TS.TSNode "r/commandline" "Subreddit for the command line" (spawn (myBrowser ++ "https://www.reddit.com/r/commandline/"))) []
               , Node (TS.TSNode "Learn Shell" "Interactive shell tutorial" (spawn (myBrowser ++ "https://www.learnshell.org/"))) []
               ]
         , Node (TS.TSNode "+ Elisp" "emacs lisp documentation" (return ()))
             [ Node (TS.TSNode "Emacs Lisp" "Reference manual for elisp" (spawn (myBrowser ++ "https://www.gnu.org/software/emacs/manual/html_node/elisp/"))) []
             , Node (TS.TSNode "Learn Elisp in Y Minutes" "Single webpage for elisp basics" (spawn (myBrowser ++ "https://learnxinyminutes.com/docs/elisp/"))) []
             , Node (TS.TSNode "r/Lisp" "Subreddit for lisp languages" (spawn (myBrowser ++ "https://www.reddit.com/r/lisp/"))) []
             ]
         , Node (TS.TSNode "+ Haskell" "haskell documentation" (return ()))
             [ Node (TS.TSNode "Haskell.org" "Homepage for haskell" (spawn (myBrowser ++ "http://www.haskell.org"))) []
             , Node (TS.TSNode "Hoogle" "Haskell API search engine" (spawn "https://hoogle.haskell.org/")) []
             , Node (TS.TSNode "r/haskell" "Subreddit for haskell" (spawn (myBrowser ++ "https://www.reddit.com/r/Python/"))) []
             , Node (TS.TSNode "Haskell on StackExchange" "Newest haskell topics on StackExchange" (spawn (myBrowser ++ "https://stackoverflow.com/questions/tagged/haskell"))) []
             ]
         , Node (TS.TSNode "+ Python" "python documentation" (return ()))
             [ Node (TS.TSNode "Python.org" "Homepage for python" (spawn (myBrowser ++ "https://www.python.org/"))) []
             , Node (TS.TSNode "r/Python" "Subreddit for python" (spawn (myBrowser ++ "https://www.reddit.com/r/Python/"))) []
             , Node (TS.TSNode "Python on StackExchange" "Newest python topics on StackExchange" (spawn (myBrowser ++ "https://stackoverflow.com/questions/tagged/python"))) []
             ]
         ]
       , Node (TS.TSNode "+ Vim" "vim and neovim documentation" (return ()))
           [ Node (TS.TSNode "Vim.org" "Vim, the ubiquitous text editor" (spawn (myBrowser ++ "https://www.vim.org/"))) []
           , Node (TS.TSNode "r/Vim" "Subreddit for vim" (spawn (myBrowser ++ "https://www.reddit.com/r/vim/"))) []
           , Node (TS.TSNode "Vi/m StackExchange" "Vi/m related questions" (spawn (myBrowser ++ "https://vi.stackexchange.com/"))) []
           ]
       , Node (TS.TSNode "My Start Page" "Custom start page for browser" (spawn (myBrowser ++ "file:///home/dt/.surf/html/homepage.html"))) []
       ]
   , Node (TS.TSNode "+ Config Files" "config files that edit often" (return ()))
       [ Node (TS.TSNode "+ emacs configs" "My xmonad config files" (return ()))
         [ Node (TS.TSNode "doom emacs config.org" "doom emacs config" (spawn (myEditor ++ "/home/dt/.doom.d/config.org"))) []
         , Node (TS.TSNode "doom emacs init.el" "doom emacs init" (spawn (myEditor ++ "/home/dt/.doom.d/init.el"))) []
         , Node (TS.TSNode "doom emacs packages.el" "doom emacs packages" (spawn (myEditor ++ "/home/dt/.doom.d/packages.el"))) []
         ]
       , Node (TS.TSNode "+ xmobar configs" "My xmobar config files" (return ()))
           [ Node (TS.TSNode "xmobar mon1" "status bar on monitor 1" (spawn (myEditor ++ "/home/dt/.config/xmobar/xmobarrc0"))) []
           , Node (TS.TSNode "xmobar mon2" "status bar on monitor 2" (spawn (myEditor ++ "/home/dt/.config/xmobar/xmobarrc2"))) []
           , Node (TS.TSNode "xmobar mon3" "status bar on monitor 3" (spawn (myEditor ++ "/home/dt/.config/xmobar/xmobarrc1"))) []
           ]
       , Node (TS.TSNode "+ xmonad configs" "My xmonad config files" (return ()))
           [ Node (TS.TSNode "xmonad.hs" "My XMonad Main" (spawn (myEditor ++ "/home/dt/.xmonad/xmonad.hs"))) []
           , Node (TS.TSNode "xmonadctl.hs" "The xmonadctl script" (spawn (myEditor ++ "/home/dt/.xmonad/xmonadctl.hs"))) []
           ]
       , Node (TS.TSNode "alacritty" "alacritty terminal emulator" (spawn (myEditor ++ "/home/dt/.config/alacritty/alacritty.yml"))) []
       , Node (TS.TSNode "awesome" "awesome window manager" (spawn (myEditor ++ "/home/dt/.config/awesome/rc.lua"))) []
       , Node (TS.TSNode "bashrc" "the bourne again shell" (spawn (myEditor ++ "/home/dt/.bashrc"))) []
       , Node (TS.TSNode "bspwmrc" "binary space partitioning window manager" (spawn (myEditor ++ "/home/dt/.config/bspwm/bspwmrc"))) []
       , Node (TS.TSNode "dmenu config.h" "dynamic menu program" (spawn (myEditor ++ "/home/dt/dmenu-distrotube/config.h"))) []
       , Node (TS.TSNode "dunst" "dunst notifications" (spawn (myEditor ++ "/home/dt/.config/dunst/dunstrc"))) []
       , Node (TS.TSNode "dwm config.h" "dynamic window manager" (spawn (myEditor ++ "/home/dt/dwm-distrotube/config.h"))) []
       , Node (TS.TSNode "herbstluftwm" "herbstluft window manager" (spawn (myEditor ++ "/home/dt/.config/herbstluftwm/autostart"))) []
       , Node (TS.TSNode "neovim init.vim" "neovim text editor" (spawn (myEditor ++ "/home/dt/.config/nvim/init.vim"))) []
       , Node (TS.TSNode "polybar" "easy-to-use status bar" (spawn (myEditor ++ "/home/dt/.config/polybar/config"))) []
       , Node (TS.TSNode "qtile config.py" "qtile window manager" (spawn (myEditor ++ "/home/dt/.config/qtile/config.py"))) []
       , Node (TS.TSNode "qutebrowser config.py" "qutebrowser web browser" (spawn (myEditor ++ "/home/dt/.config/qutebrowser/config.py"))) []
       , Node (TS.TSNode "st config.h" "suckless simple terminal" (spawn (myEditor ++ "home/dt/st-distrotube/config.h"))) []
       , Node (TS.TSNode "sxhkdrc" "simple X hotkey daemon" (spawn (myEditor ++ "/home/dt/.config/sxhkd/sxhkdrc"))) []
       , Node (TS.TSNode "surf config.h" "surf web browser" (spawn (myEditor ++ "/home/dt/surf-distrotube/config.h"))) []
       , Node (TS.TSNode "tabbed config.h" "generic tabbed interface" (spawn (myEditor ++ "home/dt/tabbed-distrotube/config.h"))) []
       , Node (TS.TSNode "xresources" "xresources file" (spawn (myEditor ++ "/home/dt/.Xresources"))) []
       , Node (TS.TSNode "zshrc" "Config for the z shell" (spawn (myEditor ++ "/home/dt/.zshrc"))) []
       ]
   , Node (TS.TSNode "+ Screenshots" "take a screenshot" (return ()))
       [ Node (TS.TSNode "Quick fullscreen" "take screenshot immediately" (spawn "scrot -d 1 ~/scrot/%Y-%m-%d-@%H-%M-%S-scrot.png")) []
       , Node (TS.TSNode "Delayed fullscreen" "take screenshot in 5 secs" (spawn "scrot -d 5 ~/scrot/%Y-%m-%d-@%H-%M-%S-scrot.png")) []
       , Node (TS.TSNode "Section screenshot" "take screenshot of section" (spawn "scrot -s ~/scrot/%Y-%m-%d-@%H-%M-%S-scrot.png")) []
       ]
   , Node (TS.TSNode "------------------------" "" (spawn "xdotool key Escape")) []
   , Node (TS.TSNode "+ XMonad" "window manager commands" (return ()))
       [ Node (TS.TSNode "+ View Workspaces" "View a specific workspace" (return ()))
         [ Node (TS.TSNode "View 1" "View workspace 1" (spawn "~/.xmonad/xmonadctl 1")) []
         , Node (TS.TSNode "View 2" "View workspace 2" (spawn "~/.xmonad/xmonadctl 3")) []
         , Node (TS.TSNode "View 3" "View workspace 3" (spawn "~/.xmonad/xmonadctl 5")) []
         , Node (TS.TSNode "View 4" "View workspace 4" (spawn "~/.xmonad/xmonadctl 7")) []
         , Node (TS.TSNode "View 5" "View workspace 5" (spawn "~/.xmonad/xmonadctl 9")) []
         , Node (TS.TSNode "View 6" "View workspace 6" (spawn "~/.xmonad/xmonadctl 11")) []
         , Node (TS.TSNode "View 7" "View workspace 7" (spawn "~/.xmonad/xmonadctl 13")) []
         , Node (TS.TSNode "View 8" "View workspace 8" (spawn "~/.xmonad/xmonadctl 15")) []
         , Node (TS.TSNode "View 9" "View workspace 9" (spawn "~/.xmonad/xmonadctl 17")) []
         ]
       , Node (TS.TSNode "+ Shift Workspaces" "Send focused window to specific workspace" (return ()))
         [ Node (TS.TSNode "View 1" "View workspace 1" (spawn "~/.xmonad/xmonadctl 2")) []
         , Node (TS.TSNode "View 2" "View workspace 2" (spawn "~/.xmonad/xmonadctl 4")) []
         , Node (TS.TSNode "View 3" "View workspace 3" (spawn "~/.xmonad/xmonadctl 6")) []
         , Node (TS.TSNode "View 4" "View workspace 4" (spawn "~/.xmonad/xmonadctl 8")) []
         , Node (TS.TSNode "View 5" "View workspace 5" (spawn "~/.xmonad/xmonadctl 10")) []
         , Node (TS.TSNode "View 6" "View workspace 6" (spawn "~/.xmonad/xmonadctl 12")) []
         , Node (TS.TSNode "View 7" "View workspace 7" (spawn "~/.xmonad/xmonadctl 14")) []
         , Node (TS.TSNode "View 8" "View workspace 8" (spawn "~/.xmonad/xmonadctl 16")) []
         , Node (TS.TSNode "View 9" "View workspace 9" (spawn "~/.xmonad/xmonadctl 18")) []
         ]
       , Node (TS.TSNode "Next layout" "Switch to next layout" (spawn "~/.xmonad/xmonadctl next-layout")) []
       , Node (TS.TSNode "Recompile" "Recompile XMonad" (spawn "xmonad --recompile")) []
       , Node (TS.TSNode "Restart" "Restart XMonad" (spawn "xmonad --restart")) []
       , Node (TS.TSNode "Quit" "Restart XMonad" (io exitSuccess)) []
       ]
   ]

tsDefaultConfig :: TS.TSConfig a
tsDefaultConfig = TS.TSConfig { TS.ts_hidechildren = True
                              , TS.ts_background   = 0xdd282c34
                              , TS.ts_font         = myFont
                              , TS.ts_node         = (0xffd0d0d0, 0xff1c1f24)
                              , TS.ts_nodealt      = (0xffd0d0d0, 0xff282c34)
                              , TS.ts_highlight    = (0xffffffff, 0xff755999)
                              , TS.ts_extra        = 0xffd0d0d0
                              , TS.ts_node_width   = 200
                              , TS.ts_node_height  = 20
                              , TS.ts_originX      = 100
                              , TS.ts_originY      = 100
                              , TS.ts_indent       = 80
                              , TS.ts_navigate     = myTreeNavigation
                              }

myTreeNavigation = M.fromList
    [ ((0, xK_Escape),   TS.cancel)
    , ((0, xK_Return),   TS.select)
    , ((0, xK_space),    TS.select)
    , ((0, xK_Up),       TS.movePrev)
    , ((0, xK_Down),     TS.moveNext)
    , ((0, xK_Left),     TS.moveParent)
    , ((0, xK_Right),    TS.moveChild)
    , ((0, xK_k),        TS.movePrev)
    , ((0, xK_j),        TS.moveNext)
    , ((0, xK_h),        TS.moveParent)
    , ((0, xK_l),        TS.moveChild)
    , ((0, xK_o),        TS.moveHistBack)
    , ((0, xK_i),        TS.moveHistForward)
    , ((0, xK_a),        TS.moveTo ["+ Accessories"])
    , ((0, xK_e),        TS.moveTo ["+ Games"])
    , ((0, xK_g),        TS.moveTo ["+ Graphics"])
    , ((0, xK_i),        TS.moveTo ["+ Internet"])
    , ((0, xK_m),        TS.moveTo ["+ Multimedia"])
    , ((0, xK_o),        TS.moveTo ["+ Office"])
    , ((0, xK_p),        TS.moveTo ["+ Programming"])
    , ((0, xK_s),        TS.moveTo ["+ System"])
    , ((0, xK_b),        TS.moveTo ["+ Bookmarks"])
    , ((0, xK_c),        TS.moveTo ["+ Config Files"])
    , ((0, xK_r),        TS.moveTo ["+ Screenshots"])
    , ((mod4Mask, xK_l), TS.moveTo ["+ Bookmarks", "+ Linux"])
    , ((mod4Mask, xK_e), TS.moveTo ["+ Bookmarks", "+ Emacs"])
    , ((mod4Mask, xK_s), TS.moveTo ["+ Bookmarks", "+ Search and Reference"])
    , ((mod4Mask, xK_p), TS.moveTo ["+ Bookmarks", "+ Programming"])
    , ((mod4Mask, xK_v), TS.moveTo ["+ Bookmarks", "+ Vim"])
    , ((mod4Mask .|. altMask, xK_a), TS.moveTo ["+ Bookmarks", "+ Linux", "+ Arch Linux"])
    , ((mod4Mask .|. altMask, xK_n), TS.moveTo ["+ Bookmarks", "+ Linux", "+ Linux News"])
    , ((mod4Mask .|. altMask, xK_w), TS.moveTo ["+ Bookmarks", "+ Linux", "+ Window Managers"])
    ]

dtXPConfig :: XPConfig
dtXPConfig = def
      { font                = myFont
      , bgColor             = "#282c34"
      , fgColor             = "#bbc2cf"
      , bgHLight            = "#c792ea"
      , fgHLight            = "#000000"
      , borderColor         = "#535974"
      , promptBorderWidth   = 0
      , promptKeymap        = dtXPKeymap
      , position            = Top
     -- , position            = CenteredAt { xpCenterY = 0.3, xpWidth = 0.3 }
      , height              = 20
      , historySize         = 256
      , historyFilter       = id
      , defaultText         = []
      , autoComplete        = Just 100000  -- set Just 100000 for .1 sec
      , showCompletionOnTab = False
      -- , searchPredicate     = isPrefixOf
      , searchPredicate     = fuzzyMatch
      , defaultPrompter     = id $ map toUpper  -- change prompt to UPPER
      -- , defaultPrompter     = unwords . map reverse . words  -- reverse the prompt
      -- , defaultPrompter     = drop 5 .id (++ "XXXX: ")  -- drop first 5 chars of prompt and add XXXX:
      , alwaysHighlight     = True
      , maxComplRows        = Nothing      -- set to 'Just 5' for 5 rows
      }

-- The same config above minus the autocomplete feature which is annoying
-- on certain Xprompts, like the search engine prompts.
dtXPConfig' :: XPConfig
dtXPConfig' = dtXPConfig
      { autoComplete        = Nothing
      }

-- A list of all of the standard Xmonad prompts and a key press assigned to them.
-- These are used in conjunction with keybinding I set later in the config.
promptList :: [(String, XPConfig -> X ())]
promptList = [ ("m", manPrompt)          -- manpages prompt
             , ("p", passPrompt)         -- get passwords (requires 'pass')
             , ("g", passGeneratePrompt) -- generate passwords (requires 'pass')
             , ("r", passRemovePrompt)   -- remove passwords (requires 'pass')
             , ("s", sshPrompt)          -- ssh prompt
             , ("x", xmonadPrompt)       -- xmonad prompt
             ]

-- Same as the above list except this is for my custom prompts.
promptList' :: [(String, XPConfig -> String -> X (), String)]
promptList' = [ ("c", calcPrompt, "qalc")         -- requires qalculate-gtk
              ]

calcPrompt c ans =
    inputPrompt c (trim ans) ?+ \input ->
        liftIO(runProcessWithInput "qalc" [input] "") >>= calcPrompt c
    where
        trim  = f . f
            where f = reverse . dropWhile isSpace

dtXPKeymap :: M.Map (KeyMask,KeySym) (XP ())
dtXPKeymap = M.fromList $
     map (first $ (,) controlMask)   -- control + <key>
     [ (xK_z, killBefore)            -- kill line backwards
     , (xK_k, killAfter)             -- kill line forwards
     , (xK_a, startOfLine)           -- move to the beginning of the line
     , (xK_e, endOfLine)             -- move to the end of the line
     , (xK_m, deleteString Next)     -- delete a character foward
     , (xK_b, moveCursor Prev)       -- move cursor forward
     , (xK_f, moveCursor Next)       -- move cursor backward
     , (xK_BackSpace, killWord Prev) -- kill the previous word
     , (xK_y, pasteString)           -- paste a string
     , (xK_g, quit)                  -- quit out of prompt
     , (xK_bracketleft, quit)
     ]
     ++
     map (first $ (,) altMask)       -- meta key + <key>
     [ (xK_BackSpace, killWord Prev) -- kill the prev word
     , (xK_f, moveWord Next)         -- move a word forward
     , (xK_b, moveWord Prev)         -- move a word backward
     , (xK_d, killWord Next)         -- kill the next word
     , (xK_n, moveHistory W.focusUp')   -- move up thru history
     , (xK_p, moveHistory W.focusDown') -- move down thru history
     ]
     ++
     map (first $ (,) 0) -- <key>
     [ (xK_Return, setSuccess True >> setDone True)
     , (xK_KP_Enter, setSuccess True >> setDone True)
     , (xK_BackSpace, deleteString Prev)
     , (xK_Delete, deleteString Next)
     , (xK_Left, moveCursor Prev)
     , (xK_Right, moveCursor Next)
     , (xK_Home, startOfLine)
     , (xK_End, endOfLine)
     , (xK_Down, moveHistory W.focusUp')
     , (xK_Up, moveHistory W.focusDown')
     , (xK_Escape, quit)
     ]

archwiki, ebay, news, reddit, urban, yacy :: S.SearchEngine

archwiki = S.searchEngine "archwiki" "https://wiki.archlinux.org/index.php?search="
ebay     = S.searchEngine "ebay" "https://www.ebay.com/sch/i.html?_nkw="
news     = S.searchEngine "news" "https://news.google.com/search?q="
reddit   = S.searchEngine "reddit" "https://www.reddit.com/search/?q="
urban    = S.searchEngine "urban" "https://www.urbandictionary.com/define.php?term="
yacy     = S.searchEngine "yacy" "http://localhost:8090/yacysearch.html?query="

-- This is the list of search engines that I want to use. Some are from
-- XMonad.Actions.Search, and some are the ones that I added above.
searchList :: [(String, S.SearchEngine)]
searchList = [ ("a", archwiki)
             , ("d", S.duckduckgo)
             , ("e", ebay)
             , ("g", S.google)
             , ("h", S.hoogle)
             , ("i", S.images)
             , ("n", news)
             , ("r", reddit)
             , ("s", S.stackage)
             , ("t", S.thesaurus)
             , ("v", S.vocabulary)
             , ("b", S.wayback)
             , ("u", urban)
             , ("w", S.wikipedia)
             , ("y", S.youtube)
             , ("S-y", yacy)
             , ("z", S.amazon)
             ]

myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                , NS "mocp" spawnMocp findMocp manageMocp
                ]
  where
    spawnTerm  = myTerminal ++ " -n scratchpad"
    findTerm   = resource =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnMocp  = myTerminal ++ " -n mocp 'mocp'"
    findMocp   = resource =? "mocp"
    manageMocp = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
tall     = renamed [Replace "tall"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
magnify  = renamed [Replace "magnify"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (Simplest)
           $ magnifier
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (Simplest)
           $ limitWindows 20 Full
floats   = renamed [Replace "floats"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (Simplest)
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
spirals  = renamed [Replace "spirals"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (Simplest)
           $ mySpacing' 8
           $ spiral (6/7)
threeCol = renamed [Replace "threeCol"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (Simplest)
           $ limitWindows 7
           $ mySpacing' 4
           $ ThreeCol 1 (3/100) (1/2)
threeRow = renamed [Replace "threeRow"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (Simplest)
           $ limitWindows 7
           $ mySpacing' 4
           -- Mirror takes a layout and rotates it by 90 degrees.
           -- So we are applying Mirror to the ThreeCol layout.
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           -- I cannot add spacing to this layout because it will
           -- add spacing between window and tabs which looks bad.
           $ tabbed shrinkText myTabTheme

myTabTheme = def { fontName            = myFont
                 , activeColor         = "#46d9ff"
                 , inactiveColor       = "#313846"
                 , activeBorderColor   = "#46d9ff"
                 , inactiveBorderColor = "#282c34"
                 , activeTextColor     = "#282c34"
                 , inactiveTextColor   = "#d0d0d0"
                 }

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:Ubuntu:bold:size=60"
    , swn_fade              = 1.0
    , swn_bgcolor           = "#1c1f24"
    , swn_color             = "#ffffff"
    }

-- The layout hook

myLayoutHook = avoidStruts (mouseResize $ windowArrange $ T.toggleLayouts floats
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout)
                   where
                       myDefaultLayout =     tiled 
                                         ||| Main.magnify
                                         ||| noBorders monocle
                                         ||| floats
                                         ||| noBorders tabs
                                         ||| grid
                                         ||| spirals
                                         ||| threeCol
                                         ||| threeRow
                       tiled = spacingWithEdge 5 tall

myWorkspaces = [" dev ", " www ", " sys ", " doc ", " vbox ", " chat ", " mus ", " vid ", " gfx "]
-- myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]

xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

myClickableWorkspaces :: [String]
myClickableWorkspaces = clickable . (map xmobarEscape)
               -- $ [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
               $ [" dev ", " www ", " sys ", " doc ", " vbox ", " chat ", " mus ", " vid ", " gfx "]
  where
        clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" |
                      (i,ws) <- zip [1..9] l,
                      let n = i ]

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
     -- I'm doing it this way because otherwise I would have to write out the full
     -- name of my workspaces, and the names would very long if using clickable workspaces.
     [ title =? "Mozilla Firefox"     --> doShift ( myWorkspaces !! 1 )
     , className =? "spotify"     --> doShift ( myWorkspaces !! 6 )
     , className =? "discord"     --> doShift ( myWorkspaces !! 5 )
     , className =? "mpv"     --> doShift ( myWorkspaces !! 7 )
     , className =? "vlc"     --> doShift ( myWorkspaces !! 7 )
     , className =? "Gimp"    --> doShift ( myWorkspaces !! 8 )
     , className =? "Gimp"    --> doFloat
     , title =? "Oracle VM VirtualBox Manager"     --> doFloat
     , className =? "VirtualBox Manager" --> doShift  ( myWorkspaces !! 4 )
     , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
     ] <+> namedScratchpadManageHook myScratchPads

myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 1.0

-- The Super/Windows key is ‘M’ (the modkey).
-- The ALT key is ‘M1’.
-- SHIFT is ‘S’ and CTR is ‘C’.
mkey :: String
mkey = "M1"
myKeys :: [(String, X ())]
myKeys =
    -- Xmonad
        [ (mkey ++ "-C-r", spawn "xmonad --recompile") -- Recompiles xmonad
        , (mkey ++ "-S-r", spawn "killall xmobar ; xmonad --restart")   -- Restarts xmonad
        , (mkey ++ "-S-q", io exitSuccess)             -- Quits xmonad

    -- Run Prompt
        , (mkey ++ "-S-<Return>", shellPrompt dtXPConfig) -- Shell Prompt

    -- Useful programs to have a keybinding for launch
        , (mkey ++ "-<Return>", spawn (myTerminal))
        , (mkey ++ "-b", spawn (myBrowser))
        --, (mkey ++ "-M1-h", spawn (myTerminal ++ " -e htop"))

    -- Kill windows
        , (mkey ++ "-S-c", kill1)                         -- Kill the currently focused client
        , (mkey ++ "-S-a", killAll)                       -- Kill all windows on current workspace

    -- Lock screen
        , (mkey ++ "-z", spawn "slock")

    -- Workspaces
        , (mkey ++ "-.", nextScreen)  -- Switch focus to next monitor
        , (mkey ++ "-,", prevScreen)  -- Switch focus to prev monitor
        , (mkey ++ "-S-<KP_Add>", shiftTo Next nonNSP >> moveTo Next nonNSP)       -- Shifts focused window to next ws
        , (mkey ++ "-S-<KP_Subtract>", shiftTo Prev nonNSP >> moveTo Prev nonNSP)  -- Shifts focused window to prev ws

    -- Floating windows
        , (mkey ++ "-f", sendMessage (T.Toggle "floats")) -- Toggles my 'floats' layout
        , (mkey ++ "-t", withFocused $ windows . W.sink)  -- Push floating window back to tile
        , (mkey ++ "-S-t", sinkAll)                       -- Push ALL floating windows to tile

    -- Increase/decrease spacing (gaps)
        , (mkey ++ "-d", decWindowSpacing 4)           -- Decrease window spacing
        , (mkey ++ "-i", incWindowSpacing 4)           -- Increase window spacing
        , (mkey ++ "-S-d", decScreenSpacing 4)         -- Decrease screen spacing
        , (mkey ++ "-S-i", incScreenSpacing 4)         -- Increase screen spacing

    -- Grid Select (CTR-g followed by a key)
        , ("C-g g", spawnSelected' myAppGrid)                 -- grid select favorite apps
        , ("C-g t", goToSelected $ mygridConfig myColorizer)  -- goto selected window
        , ("C-g b", bringSelected $ mygridConfig myColorizer) -- bring selected window

    -- Tree Select
        , ("C-t t", treeselectAction tsDefaultConfig)

    -- Windows navigation
        , (mkey ++ "-m", windows W.focusMaster)  -- Move focus to the master window
        , (mkey ++ "-j", windows W.focusDown)    -- Move focus to the next window
        , (mkey ++ "-k", windows W.focusUp)      -- Move focus to the prev window
        , (mkey ++ "-S-m", windows W.swapMaster) -- Swap the focused window and the master window
        , (mkey ++ "-S-j", windows W.swapDown)   -- Swap focused window with next window
        , (mkey ++ "-S-k", windows W.swapUp)     -- Swap focused window with prev window
        , (mkey ++ "-<Backspace>", promote)      -- Moves focused window to master, others maintain order
        , (mkey ++ "-S-<Tab>", rotSlavesDown)    -- Rotate all windows except master and keep focus in place
        , (mkey ++ "-C-<Tab>", rotAllDown)       -- Rotate all the windows in the current stack

    -- Layouts
        , (mkey ++ "-<Tab>", sendMessage NextLayout)           -- Switch to next layout
       -- , (mkey ++ "-C-M1-<Up>", sendMessage Arrange)
        --, (mkey ++ "-C-M1-<Down>", sendMessage DeArrange)
        , (mkey ++ "-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full
        , (mkey ++ "-S-<Space>", sendMessage ToggleStruts)     -- Toggles struts
        , (mkey ++ "-S-n", sendMessage $ MT.Toggle NOBORDERS)  -- Toggles noborder

    -- Increase/decrease windows in the master pane or the stack
        , (mkey ++ "-S-<Up>", sendMessage (IncMasterN 1))      -- Increase number of clients in master pane
        , (mkey ++ "-S-<Down>", sendMessage (IncMasterN (-1))) -- Decrease number of clients in master pane
        , (mkey ++ "-C-<Up>", increaseLimit)                   -- Increase number of windows
        , (mkey ++ "-C-<Down>", decreaseLimit)                 -- Decrease number of windows

    -- Window resizing
        , (mkey ++ "-h", sendMessage Shrink)                   -- Shrink horiz window width
        , (mkey ++ "-l", sendMessage Expand)                   -- Expand horiz window width
        --, (mkey ++ "-M1-j", sendMessage MirrorShrink)          -- Shrink vert window width
        --, (mkey ++ "-M1-k", sendMessage MirrorExpand)          -- Exoand vert window width

    -- Sublayouts
    -- This is used to push windows to tabbed sublayouts, or pull them out of it.
        , (mkey ++ "-C-h", sendMessage $ pullGroup L)
        , (mkey ++ "-C-l", sendMessage $ pullGroup R)
        , (mkey ++ "-C-k", sendMessage $ pullGroup U)
        , (mkey ++ "-C-j", sendMessage $ pullGroup D)
        , (mkey ++ "-C-m", withFocused (sendMessage . MergeAll))
        , (mkey ++ "-C-u", withFocused (sendMessage . UnMerge))
        , (mkey ++ "-C-/", withFocused (sendMessage . UnMergeAll))
        , (mkey ++ "-C-.", onGroup W.focusUp')    -- Switch focus to next tab
        , (mkey ++ "-C-,", onGroup W.focusDown')  -- Switch focus to prev tab

    -- Scratchpads
        , (mkey ++ "-C-<Return>", namedScratchpadAction myScratchPads "terminal")
        , (mkey ++ "-C-c", namedScratchpadAction myScratchPads "mocp")

    -- Controls for mocp music player (SUPER-u followed by a key)
        , (mkey ++ "-u p", spawn "mocp --play")
        , (mkey ++ "-u l", spawn "mocp --next")
        , (mkey ++ "-u h", spawn "mocp --previous")
        , (mkey ++ "-u <Space>", spawn "mocp --toggle-pause")

    -- Emacs (CTRL-e followed by a key)
        , ("C-e e", spawn "emacsclient -c -a 'emacs'")                            -- start emacs
        , ("C-e b", spawn "emacsclient -c -a 'emacs' --eval '(ibuffer)'")         -- list emacs buffers
        , ("C-e d", spawn "emacsclient -c -a 'emacs' --eval '(dired nil)'")       -- dired emacs file manager
        , ("C-e i", spawn "emacsclient -c -a 'emacs' --eval '(erc)'")             -- erc emacs irc client
        , ("C-e m", spawn "emacsclient -c -a 'emacs' --eval '(mu4e)'")            -- mu4e emacs email client
        , ("C-e n", spawn "emacsclient -c -a 'emacs' --eval '(elfeed)'")          -- elfeed emacs rss client
        , ("C-e s", spawn "emacsclient -c -a 'emacs' --eval '(eshell)'")          -- eshell within emacs
        , ("C-e t", spawn "emacsclient -c -a 'emacs' --eval '(mastodon)'")        -- mastodon within emacs
        , ("C-e v", spawn "emacsclient -c -a 'emacs' --eval '(+vterm/here nil)'") -- vterm within emacs
        -- emms is an emacs audio player. I set it to auto start playing in a specific directory.
        , ("C-e a", spawn "emacsclient -c -a 'emacs' --eval '(emms)' --eval '(emms-play-directory-tree \"~/Music/Non-Classical/70s-80s/\")'")

    -- Multimedia Keys
        , ("<XF86AudioPlay>", spawn (myTerminal ++ "mocp --play"))
        , ("<XF86AudioPrev>", spawn (myTerminal ++ "mocp --previous"))
        , ("<XF86AudioNext>", spawn (myTerminal ++ "mocp --next"))
        -- , ("<XF86AudioMute>",   spawn "amixer set Master toggle")  -- Bug prevents it from toggling correctly in 12.04.
        , ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute")
        , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute")
        , ("<XF86HomePage>", spawn "firefox")
        , ("<XF86Search>", safeSpawn "firefox" ["https://www.duckduckgo.com/"])
        , ("<XF86Mail>", runOrRaise "geary" (resource =? "thunderbird"))
        , ("<XF86Calculator>", runOrRaise "gcalctool" (resource =? "gcalctool"))
        , ("<XF86Eject>", spawn "toggleeject")
        , ("<Print>", spawn "scrotd 0")
        ]
    -- Appending search engine prompts to keybindings list.
    -- Look at "search engines" section of this config for values for "k".
        ++ [(mkey ++ "-s " ++ k, S.promptSearch dtXPConfig' f) | (k,f) <- searchList ]
        ++ [(mkey ++ "-S-s " ++ k, S.selectSearch f) | (k,f) <- searchList ]
    -- Appending some extra xprompts to keybindings list.
    -- Look at "xprompt settings" section this of config for values for "k".
        ++ [(mkey ++ "-p " ++ k, f dtXPConfig') | (k,f) <- promptList ]
        ++ [(mkey ++ "-p " ++ k, f dtXPConfig' g) | (k,f,g) <- promptList' ]
    -- The following lines are needed for named scratchpads.
          where nonNSP          = WSIs (return (\ws -> W.tag ws /= "nsp"))
                nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "nsp"))

main :: IO ()
main = do
    -- Launching three instances of xmobar on their monitors.
    --xmproc0 <- spawnPipe "xmobar -x 0 /home/hayden/.config/xmobar/xmobarrc0"
    --xmproc1 <- spawnPipe "xmobar -x 1 /home/hayden/.config/xmobar/xmobarrc2"
    --xmproc2 <- spawnPipe "xmobar -x 2 /home/hayden/.config/xmobar/xmobarrc1"
    xmproc0 <- spawnPipe "xmobar -x 0 /home/hayden/.config/xmobar/xmobarrc"
    xmproc1 <- spawnPipe "xmobar -x 1 /home/hayden/.config/xmobar/xmobarrc"
    xmproc2 <- spawnPipe "xmobar -x 2 /home/hayden/.config/xmobar/xmobarrc"
    -- the xmonad, ya know...what the WM is named after!
    xmonad $ ewmh def
        { manageHook = ( isFullscreen --> doFullFloat ) <+> myManageHook <+> manageDocks
        -- Run xmonad commands from command line with "xmonadctl command". Commands include:
        -- shrink, expand, next-layout, default-layout, restart-wm, xterm, kill, refresh, run,
        -- focus-up, focus-down, swap-up, swap-down, swap-master, sink, quit-wm. You can run
        -- "xmonadctl 0" to generate full list of commands written to ~/.xsession-errors.
        -- To compile xmonadctl: ghc -dynamic xmonadctl.hs
        , handleEventHook    = serverModeEventHookCmd
                               <+> serverModeEventHook
                               <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn)
                               --  <+> docks
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = showWName' myShowWNameTheme $ myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , logHook = workspaceHistoryHook <+> myLogHook <+> dynamicLogWithPP xmobarPP
                        { ppOutput = \x -> hPutStrLn xmproc0 x >> hPutStrLn xmproc1 x  >> hPutStrLn xmproc2 x
                        , ppCurrent = xmobarColor "#98be65" "" . wrap "[" "]" -- Current workspace in xmobar
                        , ppVisible = xmobarColor "#98be65" ""                -- Visible but not current workspace
                        , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" ""   -- Hidden workspaces in xmobar
                        , ppHiddenNoWindows = xmobarColor "#c792ea" ""        -- Hidden workspaces (no windows)
                        , ppTitle = xmobarColor "#b3afc2" "" . shorten 60     -- Title of active window in xmobar
                        , ppSep =  "<fc=#666666> <fn=2>|</fn> </fc>"          -- Separators in xmobar
                        , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"  -- Urgent workspace
                        , ppExtras  = [windowCount]                           -- # of windows current workspace
                        , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                        }
        } `additionalKeysP` myKeys
