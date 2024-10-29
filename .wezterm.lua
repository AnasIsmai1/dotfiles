-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Catppuccin Mocha'
config.font = wezterm.font_with_fallback {
  { family = 'JetBrains Mono',     weight = "Medium", },
  { family = "Cascadia Code",      weight = "ExtraLight", stretch = "Normal", italic = false },
  { family = 'Hack Nerd Font',     scale = 1.2 },
  { family = 'MesloLGS Nerd Font', scale = 1.2 },
  { family = 'Iosevka Nerd Font',  scale = 1.2 },
  { family = 'Fira Code',          scale = 1.2 },
}

config.font_size = 15.0

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0
}

config.max_fps = 255

config.window_frame = {
  font = wezterm.font { family = "JetBrains Mono", weight = "Bold" },
  font_size = 14.0,
  active_titlebar_bg = '#11111b',
}

config.colors = {
  tab_bar = {
    active_tab = {
      bg_color = "#1e1e2e",
      fg_color = "#b4befe"
    },
    inactive_tab = {
      bg_color = "#11111b",
      fg_color = "#585b70"
    },
    inactive_tab_hover = {
      bg_color = "#151520",
      fg_color = "#9399b2",
      italic = true,
    },
    new_tab = {
      bg_color = "#11111b",
      fg_color = "#585b70"
    },
    new_tab_hover = {
      bg_color = "#11111b",
      fg_color = "#cdd6f4",
      italic = true
    },
  }
}

config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.90
config.window_decorations = "RESIZE"
-- config.window_background_image = './Pictures/Wallpapers/split ken kaneki.png'
config.window_background_image_hsb = {
  -- Darken the background image by reducing it to 1/3rd
  brightness = 0.3,

  -- You can adjust the hue by scaling its value.
  -- a multiplier of 1.0 leaves the value unchanged.
  hue = 1.0,

  -- You can adjust the saturation also.
  saturation = 1.0,
}

return config -- Pull in the wezterm API
