-- ~/.config/hypr/hyprland.lua

-- Monitor Configuration
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Autostart (exec-once)
hl.on("hyprland.start", function()
	hl.exec_cmd("waybar")
end)

-- Variables
local terminal = "kitty tmux"
local fileManager = "thunar"
local menu = "rofi -show drun"
local mainMod = "SUPER"

-- Environment Variables
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("GTK_THEME", "Adwaita:dark")

-- Main Configuration Options
hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		follow_mouse = 1,
		touchpad = {
			natural_scroll = true,
			disable_while_typing = true,
		},
		sensitivity = 0,
	},
	general = {
		gaps_in = 1,
		gaps_out = 0,
		border_size = 2,
		col = {
			-- In Lua, gradients are defined using a colors table and an angle property
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},
		layout = "dwindle",
		allow_tearing = false,
	},
	decoration = {
		rounding = 0,
		blur = {
			enabled = false,
			size = 5,
			passes = 2,
		},
		shadow = {
			enabled = false,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
	},
	animations = {
		enabled = false,
		bezier = {
			{ "myBezier", 0.05, 0.9, 0.1, 1.05 },
		},
		animation = {
			{ "windows", 1, 7, "myBezier" },
			{ "windowsOut", 1, 7, "default", "popin 80%" },
			{ "border", 1, 10, "default" },
			{ "borderangle", 1, 8, "default" },
			{ "fade", 1, 7, "default" },
			{ "workspaces", 1, 6, "default" },
		},
	},
	misc = {
		force_default_wallpaper = 0,
		disable_splash_rendering = true,
		render_unfocused_fps = 10,
	},
})

-- Device Configuration
hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

-- Window Rules
hl.window_rule({
	name = "utils",
	match = { class = "^(blueman-manager|wiremix|org.gnome.Calendar)$" },
	float = true,
	size = { 840, 500 },
	center = true,
})

-- General Keybinds
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("~/.config/hypr/scripts/screen.sh"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("gnome-clocks"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("~/Downloads/apps/helium/helium.AppImage"))

-- Apps to Launch on Specific Workspaces
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("brave-browser", { workspace = "2" }))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("yaak-app", { workspace = "4" }))

hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("~/.config/hypr/scripts/relaunch-waybar.sh"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))

-- Move Focus
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))

-- Workspaces 1-9
for i = 1, 9 do
	hl.bind(mainMod .. " + " .. tostring(i), hl.dsp.focus({ workspace = tostring(i) }))
	hl.bind(mainMod .. " + SHIFT + " .. tostring(i), hl.dsp.window.move({ workspace = tostring(i) }))
end

-- Workspace 10
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "10" }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))

-- Special Workspace (Scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through Workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Mouse Binds for Moving and Resizing Windows (Fixed: Swapped .move() with .drag())
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Wireless Bluetooth Audio Keybinds
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Volume Control
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ repeating = true }
)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

-- Mic Control
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind(
	mainMod .. " + SHIFT + up",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+"),
	{ repeating = true }
)
hl.bind(
	mainMod .. " + SHIFT + down",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-"),
	{ repeating = true }
)

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +10%"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"), { repeating = true, locked = true })

-- Screenshot
hl.bind(
	"Print",
	hl.dsp.exec_cmd(
		'sh -c \'path=~/Pictures/Screenshots/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png; grim -g "$(slurp)" "$path" && notify-send -t 3000 --app-name="Screenshot" --icon="$path" "Screenshot taken" "$(basename "$path")"\''
	)
)
