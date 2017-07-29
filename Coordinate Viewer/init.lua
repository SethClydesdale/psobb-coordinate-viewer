-- imports
local core_mainmenu = require("core_mainmenu")
local cfg = require("Coordinate Viewer.configuration")

-- options
local optionsLoaded, options = pcall(require, "Coordinate Viewer.options")
local optionsFileName = "addons/Coordinate Viewer/options.lua"
local ConfigurationWindow


if optionsLoaded then
  options.configurationEnableWindow = options.configurationEnableWindow == nil and true or options.configurationEnableWindow
  options.enable = options.enable == nil and true or options.enable
  options.EnableWindow = options.EnableWindow == nil and true or options.EnableWindow
  options.NoTitleBar = options.NoTitleBar or ""
  options.NoResize = options.NoResize or ""
  options.Transparent = options.Transparent == nil and true or options.Transparent
  options.fontScale = options.fontScale or 1.0
else
  options = {
    configurationEnableWindow = true,
    enable = true,
    EnableWindow = true,
    NoTitleBar = "",
    NoResize = "",
    Transparent = false,
    fontScale = 1.0,
  }
end


local function SaveOptions(options)
  local file = io.open(optionsFileName, "w")
  if file ~= nil then
    io.output(file)

    io.write("return {\n")
    io.write(string.format("  configurationEnableWindow = %s,\n", tostring(options.configurationEnableWindow)))
    io.write(string.format("  enable = %s,\n", tostring(options.enable)))
    io.write("\n")
    io.write(string.format("  EnableWindow = %s,\n", tostring(options.EnableWindow)))
    io.write(string.format("  NoTitleBar = \"%s\",\n", options.NoTitleBar))
    io.write(string.format("  NoResize = \"%s\",\n", options.NoResize))
    io.write(string.format("  Transparent = %s,\n", tostring(options.Transparent)))
    io.write(string.format("  fontScale = %s,\n", tostring(options.fontScale)))
    io.write("}\n")

    io.close(file)
  end
end

-- player data
local _PlayerArray = 0x00A94254
local _PlayerIndex = 0x00A9C4F4

-- shows your coordinates
local showCoordinates = function()
  local playerIndex = pso.read_u32(_PlayerIndex)
  local playerAddr = pso.read_u32(_PlayerArray + 4 * playerIndex)
  
  if playerAddr ~= 0 then
    local X = pso.read_f32(playerAddr + 0x38) -- left/right
    local Y = pso.read_f32(playerAddr + 0x3C) -- up/down
    local Z = pso.read_f32(playerAddr + 0x40) -- out/in
    
    imgui.Text(string.format("X : %.3f", X))
    imgui.Text(string.format("Y : %.3f", Y))
    imgui.Text(string.format("Z : %.3f", Z))
    
  -- show placeholder if the pointer is null
  else
    imgui.Text("X : 0")
    imgui.Text("Y : 0")
    imgui.Text("Z : 0")
  end
end

-- config setup and drawing
local function present()
  if options.configurationEnableWindow then
    ConfigurationWindow.open = true
    options.configurationEnableWindow = false
  end

  ConfigurationWindow.Update()
  if ConfigurationWindow.changed then
    ConfigurationWindow.changed = false
    SaveOptions(options)
  end

  if options.enable == false then
    return
  end
  
  if options.Transparent == true then
    imgui.PushStyleColor("WindowBg", 0.0, 0.0, 0.0, 0.0)
  end

  if options.EnableWindow then
    imgui.SetNextWindowSize(150, 80, "Always");
    
    if imgui.Begin("Coordinate Viewer", nil, { options.NoTitleBar, options.NoResize }) then
      imgui.SetWindowFontScale(options.fontScale)
      showCoordinates();
    end
    imgui.End()
  end
  
  if options.Transparent == true then
    imgui.PopStyleColor()
  end
end


local function init()
  ConfigurationWindow = cfg.ConfigurationWindow(options)

  local function mainMenuButtonHandler()
    ConfigurationWindow.open = not ConfigurationWindow.open
  end

  core_mainmenu.add_button("Coordinate Viewer", mainMenuButtonHandler)
  
  return {
    name = "Coordinate Viewer",
    version = "1.0.3",
    author = "Seth Clydesdale",
    description = "Displays your X, Y, and Z coordinates.",
    present = present
  }
end

return {
  __addon = {
    init = init
  }
}