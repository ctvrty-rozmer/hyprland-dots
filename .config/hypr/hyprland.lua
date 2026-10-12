-- ─── Environment Variables ─────────────────────────── ✣ ─
hl.env("XCURSOR_SIZE", "16")
hl.env("HYPRCURSOR_SIZE", "16")
hl.env("GDK_SCALE", "1")

-- ─── Monitor ───────────────────────────────────────── ✣ ─
hl.monitor({
    output   = "eDP-1",
    mode     = "highres",
    position = "0x0",
    scale    = "1.33",
})

hl.config({
  xwayland = {
    force_zero_scaling = true
  }
})

-- ─── Input ─────────────────────────────────────────── ✣ ─
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0,        -- [-1.0 - 1.0 ], 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    }
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- ─── Default Applications ──────────────────────────── ✣ ─
local terminal = "kitty"
local fileManagerCLI = "kitty -e yazi"
local fileManager = "thunar"
local menu = "rofi -show drun"

-- ─── On Startup ────────────────────────────────────── ✣ ─
hl.on("hyprland.start", function ()
   hl.exec_cmd("waybar & hyprpaper")
   hl.exec_cmd("wal --theme qifreytheme")
    hl.exec_cmd("hyprland-autoname-workspaces &")
   hl.exec_cmd("pidof -x battery_notify.sh || ~/scripts/Battery_Notify/battery_notify.sh &")
   hl.exec_cmd("pidof -x battery_warning.sh || ~/scripts/Battery_Notify/battery_warning.sh &")
   hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

-- ─── Look And Feel ─────────────────────────────────── ✣ ─
hl.config({
    general = {
        gaps_in  = 2,
        gaps_out = 6,

        border_size = 2,
        resize_on_border = true,
        layout = "dwindle",

        col = {
            active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

    },

    decoration = {
        rounding       = 2,     -- corner radius in px. default: 0 [0 - 100]
        rounding_power = 2,     -- curve used for rounding corners. larger = smoother. 1.0 triangular, 2.0 circular, 4.0 squircle etc. default: 2.0 [1.0 - 10.0]

        active_opacity   = 1.0,     -- opacity will be sum of all opacities. use "override" to set a specific opacity. 
        inactive_opacity = 1.0,     -- opacity over 1.0 is allowed but will cause glitches

        dim_inactive = false,       -- dimming
        dim_strength = 0.45,
        border_part_of_window = false,

        shadow = {
            enabled      = true,
            range        = 20,
            offset       = { 1, 2 },
            render_power = 4,
            color = "rgba(1a1a1aee)",
        },

        blur = {
            enabled   = false,
            xray      = true,
            new_optimizations = true,
            size      = 11,
            passes    = 3,
            brightness = 1.9,
            noise     = 0,
            contrast  = 1.4,
            vibrancy  = 1,
            vibrancy_darkness = 1,
            popups    = true,
            popups_ignorealpha = 0.8,
            input_methods = true,
            input_methods_ignorealpha = 0.8,
            ignore_opacity = true,
        },

    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    }
})

-- ─── Animations ────────────────────────────────────── ✣ ─
hl.config({
    animations = {
        enabled = true
    }
})
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })        -- default curves and animations
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })


hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- ─── Layout Rules ──────────────────────────────────── ✣ ─
hl.config({
    dwindle = {
        preserve_split = true, -- split doesnt change regardless of what happens to the container
    },
    master = {
        new_status = "master", -- new windows are set as master
    },
})

-- ─── Workspace Window And Layer Rules ──────────────── ✣ ─
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })      -- smart gaps / no gaps when only
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })      -- w[tv1] matches single tiled windows, f[1] matches single floating windows. remove gaps
hl.window_rule({
    name  = "smart-gaps-wtv1",
    match = { float = false, workspace = "w[tv1]" },       -- matches single tiled window and removes borders and rounding
    border_size = 0,
    rounding    = 0,
})
hl.window_rule({
    name  = "smart-gaps-f1",
    match = { float = false, workspace = "f[1]" },      -- matches single floating window and removes borders and rounding
    border_size = 0,
    rounding    = 0,
})

local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",     -- ignores maximize requests from all apps
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",       -- fix some dragging issues with XWayland
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",        -- hyprland run window rule
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

local waybarRules = hl.layer_rule({ -- enable blur on waybar layer
  name    = "waybarRules",
  match   = { namespace = "waybar" },
  blur    = true,
})

-- ─── Keybindings ───────────────────────────────────── ✣ ─
local mainMod = "ALT" -- Sets "Alt" key as main modifier

-- launch programs
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))              --terminal
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManagerCLI))             --yazi
hl.bind("SUPER + SHIFT + code:201", hl.dsp.exec_cmd(fileManager))       --thunar : copilot key
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))                       --rofi
hl.bind("SUPER + CTRL + ALT + SHIFT + space", hl.dsp.exec_cmd(menu))    --rofi : emoji key
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots")) -- screenshot

-- close and restart programs
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close()) --close window
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")) --exit hyprland
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("killall -SIGUSR2 waybar"))                  --restart waybar
hl.bind(mainMod .. " + SHIFT + Escape", hl.dsp.exec_cmd("hyprctl reload"))                      --restart hyprland
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("~/.config/swaync/refresh.sh"))              --refresh swaync

-- focus workspaces 1-10 and move windows to workspaces
for i = 1, 10 do
    local key = i % 10      -- switch workspaces with keys 0-9, workspace 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))               -- focus workspace with mainMod + [0-9]
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))         -- move window to workspace with mainMod + SHIFT + [0-9]  
end

-- move windows focus with mainMod + arrow keys and move window with mainMod + SHIFT + arrow keys
for _, dir in ipairs({ "left", "right", "up", "down" }) do
  hl.bind(mainMod .. " + " .. dir, hl.dsp.focus({ direction = dir }))           -- focus window in direction with mainMod + arrow keys
  hl.bind(mainMod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir })) -- move window in direction with mainMod + SHIFT + arrow keys
end

-- move and resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- resize with mainMod + SHIFT + CTRL + arrows
for dir, d in pairs({ right = { 25, 0 }, left = { -25, 0 }, up = { 0, -25 }, down = { 0, 25 } }) do
  hl.bind(mainMod .. " + SHIFT + CTRL + " .. dir, hl.dsp.window.resize({ x = d[1], y = d[2], relative = true }))
end

-- toggle floating windows
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

-- toggle horizontal/vertical split
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.layout("preselect d"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.layout("preselect r"))

-- volume / brightness 
for key, cmd in pairs({
  XF86AudioRaiseVolume  = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+",
  XF86AudioLowerVolume  = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-",
  XF86AudioMute         = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
  XF86AudioMicMute      = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",
  XF86MonBrightnessUp   = "brightnessctl -e4 -n2 set 5%+",
  XF86MonBrightnessDown = "brightnessctl -e4 -n2 set 5%-",
}) do
  hl.bind(key, hl.dsp.exec_cmd(cmd), { locked = true, repeating = true })
end

-- media keys 
for key, cmd in pairs({
  XF86AudioNext  = "playerctl next",
  XF86AudioPause = "playerctl play-pause",
  XF86AudioPlay  = "playerctl play-pause",
  XF86AudioPrev  = "playerctl previous",
}) do
  hl.bind(key, hl.dsp.exec_cmd(cmd), { locked = true })
end
