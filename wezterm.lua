-- Pull in the wezterm API
local wezterm = require 'wezterm'
local launch_menu = {}
local act = wezterm.action
-- This table will hold the configuration.
local config = {}
local function get_process_name(pane)
	local cmd = pane:get_foreground_process_name()
	return cmd or ""
end
local function trim_title(title, max_len)
	if #title > max_len then
		return title:sub(1, max_len) .. "..."
	end
	return title
end
-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end
config.tab_bar_at_bottom = true
-- This is where you actually apply your config choices
config.font = wezterm.font 'IosevkaTerm Nerd Font Mono'
config.colors = {
	tab_bar = {
		-- The color of the inactive tab bar edge/divider
		inactive_tab_edge = '#575757',
	},
}
-- Keys
--
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	-- Send C-a when pressing C-a twice
	{ key = "a",          mods = "LEADER|CTRL", action = act.SendKey { key = "a", mods = "CTRL" } },
	{ key = "c",          mods = "LEADER",      action = act.ActivateCopyMode },
	{ key = "phys:Space", mods = "LEADER",      action = act.ActivateCommandPalette },

	-- Pane keybindings
	{ key = "s",          mods = "LEADER",      action = act.SplitVertical { domain = "CurrentPaneDomain" } },
	{ key = "v",          mods = "LEADER",      action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
	{ key = "h",          mods = "LEADER",      action = act.ActivatePaneDirection("Left") },
	{ key = "j",          mods = "LEADER",      action = act.ActivatePaneDirection("Down") },
	{ key = "k",          mods = "LEADER",      action = act.ActivatePaneDirection("Up") },
	{ key = "l",          mods = "LEADER",      action = act.ActivatePaneDirection("Right") },
	{ key = "q",          mods = "LEADER",      action = act.CloseCurrentPane { confirm = true } },
	{ key = "z",          mods = "LEADER",      action = act.TogglePaneZoomState },
	{ key = "o",          mods = "LEADER",      action = act.RotatePanes "Clockwise" },
	-- We can make separate keybindings for resizing panes
	-- But Wezterm offers custom "mode" in the name of "KeyTable"
	{ key = "r",          mods = "LEADER",      action = act.ActivateKeyTable { name = "resize_pane", one_shot = false } },

	-- Tab keybindings
	{ key = "t",          mods = "LEADER",      action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "[",          mods = "LEADER",      action = act.ActivateTabRelative(-1) },
	{ key = "]",          mods = "LEADER",      action = act.ActivateTabRelative(1) },
	{ key = "n",          mods = "LEADER",      action = act.ShowTabNavigator },
	{
		key = "e",
		mods = "LEADER",
		action = act.PromptInputLine {
			description = wezterm.format {
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Renaming Tab Title...:" },
			},
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end)
		}
	},
	-- Key table for moving tabs around
	{ key = "m", mods = "LEADER",       action = act.ActivateKeyTable { name = "move_tab", one_shot = false } },
	-- Or shortcuts to move tab w/o move_tab table. SHIFT is for when caps lock is on
	{ key = "{", mods = "LEADER|SHIFT", action = act.MoveTabRelative(-1) },
	{ key = "}", mods = "LEADER|SHIFT", action = act.MoveTabRelative(1) },

	-- Lastly, workspace
	{ key = "w", mods = "LEADER",       action = act.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" } },

}
-- I can use the tab navigator (LDR t), but I also want to quickly navigate tabs with index
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1)
	})
end
-- For example, changing the color scheme:
config.color_scheme = 'kanagawabones'
-- config.default_prog = { "pwsh", "-NoLogo" }
config.default_prog = { "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe" }
config.use_fancy_tab_bar = true
config.scrollback_lines = 3500
config.enable_scroll_bar = true
-- config.hide_tab_bar_if_only_one_tab = true
config.tab_and_split_indices_are_zero_based = true
config.enable_scroll_bar = true
config.window_decorations = "RESIZE"
wezterm.on("update-status", function(window, pane)
	-- Workspace name
	local stat = window:active_workspace()
	local stat_color = "#f7768e"

	if window:active_key_table() then
		stat = window:active_key_table()
		stat_color = "#7dcfff"
	end
	if window:leader_is_active() then
		stat = "LDR"
		stat_color = "#bb9af7"
	end

	-- Time
	local time = wezterm.strftime(' %H:%M %Y-%m-%d')

	-- Left status (left of the tab line)
	window:set_left_status(wezterm.format({
		{ Foreground = { Color = stat_color } },
		{ Text = "  " },
		{ Text = stat },
		{ Text = "  " },
	}))

	-- Right status
	window:set_right_status(wezterm.format({
		{ Text = time },
		{ Text = "  " },
	}))
end)

return config
