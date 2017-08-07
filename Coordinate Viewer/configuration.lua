local function ConfigurationWindow(configuration, customTheme)
  local this = {
    title = "Coordinate Viewer - Configuration",
    fontScale = 1.0,
    open = false,
    changed = false,
  }

  local _configuration = configuration

  local _showWindowSettings = function()
    local success

    imgui.Text("General Settings")
    if imgui.Checkbox("Enable", _configuration.EnableWindow) then
      _configuration.EnableWindow = not _configuration.EnableWindow
      this.changed = true
    end
    
    if customTheme then
      if imgui.Checkbox("Use custom theme", _configuration.useCustomTheme) then
          _configuration.useCustomTheme = not _configuration.useCustomTheme
          this.changed = true
      end
    end

    if imgui.Checkbox("No title bar", _configuration.NoTitleBar == "NoTitleBar") then
      if _configuration.NoTitleBar == "NoTitleBar" then
        _configuration.NoTitleBar = ""
      else
        _configuration.NoTitleBar = "NoTitleBar"
      end
      this.changed = true
    end

    if imgui.Checkbox("No resize", _configuration.NoResize == "NoResize") then
      if _configuration.NoResize == "NoResize" then
        _configuration.NoResize = ""
      else
        _configuration.NoResize = "NoResize"
      end
      this.changed = true
    end
    
    if imgui.Checkbox("Transparent window", _configuration.Transparent) then
      _configuration.Transparent = not _configuration.Transparent
      this.changed = true
    end
    
    success, _configuration.fontScale = imgui.InputFloat("Font Scale", _configuration.fontScale)
    if success then
      this.changed = true
    end
    
    
    imgui.Text("\nPosition and Size")
    imgui.PushItemWidth(100)
    success, _configuration.X = imgui.InputInt("X", _configuration.X)
    imgui.PopItemWidth()
    if success then
      _configuration.Changed = true
      this.changed = true
    end
    
    imgui.SameLine(0, 38)
    imgui.PushItemWidth(100)
    success, _configuration.Y = imgui.InputInt("Y", _configuration.Y)
    imgui.PopItemWidth()
    if success then
      _configuration.Changed = true
      this.changed = true
    end
    
    imgui.PushItemWidth(100)
    success, _configuration.Width = imgui.InputInt("Width", _configuration.Width)
    imgui.PopItemWidth()
    if success then
      _configuration.Changed = true
      this.changed = true
    end
    
    imgui.SameLine(0, 10)
    imgui.PushItemWidth(100)
    success, _configuration.Height = imgui.InputInt("Height", _configuration.Height)
    imgui.PopItemWidth()
    if success then
      _configuration.Changed = true
      this.changed = true
    end
    
    
    imgui.Text("\nCoordinate Viewer Options")
    if imgui.Checkbox("Use High Contrast Color", _configuration.HighContrast) then
      _configuration.HighContrast = not _configuration.HighContrast
      this.changed = true
    end
  end

  this.Update = function()
    if this.open == false then
      return
    end

    local success

    imgui.SetNextWindowSize(500, 400, 'FirstUseEver')
    success, this.open = imgui.Begin(this.title, this.open)
    imgui.SetWindowFontScale(this.fontScale)

    _showWindowSettings()

    imgui.End()
  end

  return this
end

return {
  ConfigurationWindow = ConfigurationWindow,
}