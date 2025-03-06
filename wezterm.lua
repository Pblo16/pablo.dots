-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.font = wezterm.font("FiraCode Nerd Font Mono")
config.font_size = 12.0


-- Terminal color scheme
config.colors = {
    foreground = "#fff",
    background = "#0e0e0e",
    cursor_bg = "#97979B",
    cursor_fg = "#EFF0EB",
    cursor_border = "#97979B",
    selection_fg = "#0e0e0e",
    selection_bg = "#808080",
    scrollbar_thumb = "#4F4F4F",
    split = "#30a1a2",
    ansi = {
        "#878787", -- Black
        "#c44753", -- Red
        "#e7881c", -- Green
        "#D19A66", -- Yellow
        "#30a1a2", -- Blue
        "#12D8DD", -- Purple
        "#66C4C4", -- Cyan
        "#F1F1F0", -- White
    },
    brights = {
        "#878787", -- Bright Black
        "#c44753", -- Bright Red
        "#e7881c", -- Bright Green
        "#D19A66", -- Bright Yellow
        "#30a1a2", -- Bright Blue
        "#12D8DD", -- Bright Purple
        "#66C4C4", -- Bright Cyan
        "#F1F1F0", -- Bright White
    },
}

-- This is where you actually apply your config choices
config.window_padding = {
	top = 0,
	right = 0,
	left = 0,
  bottom = 0,
}

-- Background
config.window_background_opacity = .90 -- Adjust this value as needed
-- config.win32_system_backdrop = "Acrylic" -- Only Works in Windows

-- UI
config.window_decorations = "NONE | RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.max_fps = 144 -- hack for smoothness

-- activate ONLY if windows --

config.default_domain = 'WSL:Ubuntu'
config.front_end = "OpenGL"
local gpus = wezterm.gui.enumerate_gpus()
if #gpus > 0 then
  config.webgpu_preferred_adapter = gpus[1]  -- only set if there's at least one GPU
else
  -- fallback to default behavior or log a message
  wezterm.log_info("No GPUs found, using default settings")
end


-- and finally, return the configuration to wezterm
return config
