-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.font = wezterm.font("FiraCode Nerd Font Mono")
config.font_size = 11.0

-- Terminal color scheme (One Dark Pro)
config.colors = {
	foreground = "#abb2bf",
	background = "#282c34",
	cursor_bg = "#528bff",
	cursor_fg = "#282c34",
	cursor_border = "#528bff",
	selection_fg = "#282c34",
	selection_bg = "#979eab",
	scrollbar_thumb = "#3e4452",
	split = "#528bff",
	ansi = {
		"#282c34", -- Black
		"#e06c75", -- Red
		"#98c379", -- Green
		"#e5c07b", -- Yellow
		"#61afef", -- Blue
		"#c678dd", -- Purple/Magenta
		"#56b6c2", -- Cyan
		"#abb2bf", -- White
	},
	brights = {
		"#5c6370", -- Bright Black
		"#e06c75", -- Bright Red
		"#98c379", -- Bright Green
		"#e5c07b", -- Bright Yellow
		"#61afef", -- Bright Blue
		"#c678dd", -- Bright Purple/Magenta
		"#56b6c2", -- Bright Cyan
		"#ffffff", -- Bright White
	},
}

-- This is where you actually apply your config choices
config.window_padding = {
	top = 5,
	right = 0,
	left = 5,
	bottom = 0,
}

-- Background
config.window_background_opacity = 1.00 -- Adjust this value as needed
-- config.win32_system_backdrop = "Acrylic" -- Only Works in Windows

-- UI
config.window_decorations = "NONE | RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.max_fps = 144 -- hack for smoothness

-- activate only if windows --

config.default_domain = "WSL:Ubuntu"
config.front_end = "OpenGL"
local gpus = wezterm.gui.enumerate_gpus()
if #gpus > 0 then
	config.webgpu_preferred_adapter = gpus[1] -- only set if there's at least one GPU
else
	-- fallback to default behavior or log a message
	wezterm.log_info("No GPUs found, using default settings")
end

config.keys = {
	{ key = "d", mods = "CTRL|ALT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "v", mods = "CTRL|ALT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "q", mods = "CTRL|ALT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
	{ key = "h", mods = "CTRL|ALT", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "l", mods = "CTRL|ALT", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "k", mods = "CTRL|ALT", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "j", mods = "CTRL|ALT", action = wezterm.action.ActivatePaneDirection("Down") },
}
-- and finally, return the configuration to wezterm
return config
