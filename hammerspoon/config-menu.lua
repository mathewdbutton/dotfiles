-- ---------------------------------------------------------------
-- config-menu.lua
--
-- Replaces Hammerspoon's own menu bar icon with a copy that has the
-- same icon and items, except Open Config opens the whole config
-- folder in Zed. Hotkey for that: Cmd + Alt + Ctrl + H.
--
-- ~/.hammerspoon only holds symlinks into the dotfiles repo, so this
-- opens the real folder they point at and Zed sees the git repo.
--
-- hs.menuIcon() is a saved preference. If this file is ever removed,
-- run hs.menuIcon(true) in the console to bring the original back.
-- ---------------------------------------------------------------

local function configFolder()
  local real = hs.fs.pathToAbsolute(hs.configdir .. "/init.lua")
  return real and real:match("(.*)/") or hs.configdir
end

local function openInZed()
  hs.task.new("/usr/bin/open", nil, { "-a", "Zed", configFolder() }):start()
end

local function quit()
  hs.application.applicationForPID(hs.processInfo.processID):kill()
end

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "H", openInZed)

local icon = hs.image.imageFromPath(hs.processInfo.resourcePath .. "/statusicon.pdf")

local menu = hs.menubar.new()
menu:setIcon(icon, true)
menu:setMenu({
  { title = "Reload Config",        fn = hs.reload },
  { title = "Open Config",          fn = openInZed },
  { title = "Console...",           fn = hs.openConsole },
  { title = "-" },
  { title = "Preferences...",       fn = hs.openPreferences },
  { title = "About Hammerspoon",    fn = hs.openAbout },
  { title = "Check for Updates...", fn = hs.checkForUpdates },
  { title = "-" },
  { title = "Quit Hammerspoon",     fn = quit },
})

hs.menuIcon(false)

-- Returned so require() keeps it referenced; a collected menubar
-- item vanishes from the menu bar.
return { menu = menu }
