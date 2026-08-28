-- ==============================================================================
-- Chef_Carthy OS - Hyprland Native Lua Desktop Configuration (Omarchy-Inspired)
-- Designed for maximum performance, minimal latency, and aesthetic cyber HUD
-- ==============================================================================

-- 1. Monitors
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.monitor({ output = "Virtual-1", mode = "preferred", position = "auto", scale = 1 })
for i = 2, 8 do
    hl.monitor({ output = "Virtual-" .. i, disabled = true })
end

-- 2. Environment Variables (VMware & Wayland Compatibility)
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("AQ_NO_MODIFIERS", "1")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")
hl.env("LIBGL_ALWAYS_SOFTWARE", "1")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("GDK_BACKEND", "wayland")

-- 3. Autostart Daemons & Services
hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP", true)
hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1", true)
hl.exec_cmd("pipewire & wireplumber & pipewire-pulse", true)
hl.exec_cmd("waybar", true)
hl.exec_cmd("swaybg -c '#0d1118'", true)
hl.exec_cmd("mako", true)

-- 4. Core System & Visual Configuration
hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        col = {
            active_border = { colors = { "rgb(58a6ff)", "rgb(7aa2f7)" }, angle = 45 },
            inactive_border = "rgb(30363d)",
        },
        layout = "dwindle",
    },

    decoration = {
        rounding = 8,
        active_opacity = 1.0,
        inactive_opacity = 0.96,
        blur = {
            enabled = false,
        },
        shadow = {
            enabled = false,
        },
    },

    dwindle = {
        preserve_split = true,
        force_split = 2,
    },

    input = {
        kb_layout = "us",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
        },
        sensitivity = 0,
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        disable_scale_notification = true,
        focus_on_activate = true,
    },
})

-- 5. Window Rules (Omarchy / Hyprland Native Lua API)
hl.window_rule({ match = { class = "^(alacritty)$" }, float = true, size = "780 500", center = true })
hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true })
hl.window_rule({ match = { class = "^(thunar)$" }, float = true })

-- 6. Keybindings
local mainMod = "SUPER"

-- Launchers & Terminals
hl.bind(mainMod, "Return", hl.dsp.exec_cmd("alacritty || kitty || foot"))
hl.bind(mainMod, "t", hl.dsp.exec_cmd("alacritty || kitty || foot"))
hl.bind(mainMod, "o", hl.dsp.exec_cmd("alacritty || kitty || foot"))
hl.bind(mainMod, "space", hl.dsp.exec_cmd("pkill wofi || wofi --show drun"))
hl.bind(mainMod, "c", hl.dsp.exec_cmd("alacritty -t 'Chef Control Center' -e chef menu"))
hl.bind(mainMod, "g", hl.dsp.exec_cmd("chef-gui"))
hl.bind(mainMod, "a", hl.dsp.exec_cmd("alacritty -e chef agent"))
hl.bind(mainMod, "e", hl.dsp.exec_cmd("thunar || alacritty -e yazi"))
hl.bind(mainMod .. " SHIFT", "t", hl.dsp.exec_cmd("chef-theme pick"))

-- Window Management
hl.bind(mainMod, "q", hl.dsp.window.close())
hl.bind(mainMod .. " SHIFT", "q", hl.dsp.window.close())
hl.bind(mainMod, "Escape", hl.dsp.window.close())
hl.bind(mainMod, "m", hl.dsp.exit())
hl.bind(mainMod, "f", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod, "v", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod, "p", hl.dsp.window.pseudo())
hl.bind(mainMod, "j", hl.dsp.layout("togglesplit"))

-- Focus Navigation
hl.bind(mainMod, "left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod, "right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod, "up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod, "down", hl.dsp.focus({ direction = "d" }))

hl.bind(mainMod, "h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod, "l", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod, "k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod, "j", hl.dsp.focus({ direction = "d" }))

-- Workspaces Navigation (1-6)
for i = 1, 6 do
    hl.bind(mainMod, tostring(i), hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(mainMod .. " SHIFT", tostring(i), hl.dsp.window.move({ workspace = tostring(i) }))
end
