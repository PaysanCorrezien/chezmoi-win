local wezterm = require("wezterm")

-- OS detection
local function is_windows()
	return wezterm.target_triple:find("windows") ~= nil
end

-- Set up path based on OS
local config_path = is_windows() and "C:\\Users\\admin\\repo\\config.wezterm\\?.lua"
	or "/home/dylan/repo/config.wezterm/?.lua"
-- Add the config directory to package path
package.path = package.path .. ";" .. config_path

-- Create the base config object
local config = {
	color_scheme = "stylix",
	font = wezterm.font_with_fallback({
		{
			family = "FiraCode Nerd Font",
			weight = "Regular",
			stretch = "Normal",
			style = "Normal",
		},
		"Noto Color Emoji",
		"Segoe UI", -- Windows fallback
		"Consolas", -- Windows fallback
	}),
	font_size = 12,
	window_background_opacity = 0.900000,
	window_frame = {
		active_titlebar_bg = "#6e6a86",
		active_titlebar_fg = "#e0def4",
		active_titlebar_border_bottom = "#6e6a86",
		border_left_color = "#1f1d2e",
		border_right_color = "#1f1d2e",
		border_bottom_color = "#1f1d2e",
		border_top_color = "#1f1d2e",
		button_bg = "#1f1d2e",
		button_fg = "#e0def4",
		button_hover_bg = "#e0def4",
		button_hover_fg = "#6e6a86",
		inactive_titlebar_bg = "#1f1d2e",
		inactive_titlebar_fg = "#e0def4",
		inactive_titlebar_border_bottom = "#6e6a86",
	},
	colors = {
		tab_bar = {
			background = "#1f1d2e",
			inactive_tab_edge = "#1f1d2e",
			active_tab = {
				bg_color = "#191724",
				fg_color = "#e0def4",
			},
			inactive_tab = {
				bg_color = "#6e6a86",
				fg_color = "#e0def4",
			},
			inactive_tab_hover = {
				bg_color = "#e0def4",
				fg_color = "#191724",
			},
			new_tab = {
				bg_color = "#6e6a86",
				fg_color = "#e0def4",
			},
			new_tab_hover = {
				bg_color = "#e0def4",
				fg_color = "#191724",
			},
		},
	},
	command_palette_bg_color = "#1f1d2e",
	command_palette_fg_color = "#e0def4",
	command_palette_font_size = 10,
}

-- Make config globally accessible
_G.config = config

local init_config = require("init")

-- Only merge if init_config is a table
if type(init_config) == "table" then
	for k, v in pairs(init_config) do
		if type(config[k]) == "table" and type(v) == "table" then
			-- If both are tables, merge them
			for k2, v2 in pairs(v) do
				config[k][k2] = v2
			end
		else
			-- Otherwise just override
			config[k] = v
		end
	end
end

if is_windows() then
	local windows_config = require("windows")
	if type(windows_config) == "table" then
		for k, v in pairs(windows_config) do
			if type(config[k]) == "table" and type(v) == "table" then
				-- If both are tables, merge them
				for k2, v2 in pairs(v) do
					config[k][k2] = v2
				end
			else
				-- Otherwise just override
				config[k] = v
			end
		end
	end
end

return config
