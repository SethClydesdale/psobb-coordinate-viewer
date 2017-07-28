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
  options.ShowZ = options.ShowZ == nil and true or options.ShowZ
else
  options = {
    configurationEnableWindow = true,
    enable = true,
    EnableWindow = true,
    NoTitleBar = "",
    NoResize = "",
    Transparent = false,
    fontScale = 1.0,
    ShowZ = false,
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
    io.write(string.format("  ShowZ = %s,\n", tostring(options.ShowZ)))
    io.write("}\n")

    io.close(file)
  end
end


-- pointer
local PlayerPointer = 0x00A94254

-- shows your coordinates
local showCoordinates = function()
  local CoordAddress = pso.read_u32(PlayerPointer)
  
  if CoordAddress ~= 0 then
    local X = pso.read_f32(CoordAddress + 0x38)
    local Y = pso.read_f32(CoordAddress + 0x40)
    
    imgui.Text(string.format("X : %.3f", X))
    imgui.Text(string.format("Y : %.3f", Y))
    
    -- show Z coordinate if enabled
    if options.ShowZ then
      local Z = pso.read_f32(CoordAddress + 0x3C)
      imgui.Text(string.format("Z : %.3f", Z))
    end
    
  -- show placeholder if the pointer is null
  else
    imgui.Text("X : 0")
    imgui.Text("Y : 0")
    if options.ShowZ then
      imgui.Text("Z : 0")
    end
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
    imgui.SetNextWindowSize(150, 80, "FirstUseEver");
    
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
    version = "1.0.0",
    author = "Seth Clydesdale",
    description = "Tool for viewing your XYZ coordinates.",
    present = present
  }
end

return {
  __addon = {
    init = init
  }
}