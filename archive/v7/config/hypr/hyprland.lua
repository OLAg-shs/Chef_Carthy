-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv(\"OMARCHY_PATH\") or \"/usr/share/omarchy\") .. \"/default/hypr/bootstrap.lua\")

-- VMware Graphics & Software Render Flags
hl.env(\"WLR_NO_HARDWARE_CURSORS\", \"1\")
hl.env(\"WLR_RENDERER_ALLOW_SOFTWARE\", \"1\")
hl.env(\"AQ_NO_MODIFIERS\", \"1\")

-- Load Omarchy defaults.
require(\"default.hypr.omarchy\")

-- Put your personal overrides in these files.
require(\"hypr.monitors\")
require(\"hypr.input\")
require(\"hypr.bindings\")
require(\"hypr.looknfeel\")
require(\"hypr.autostart\")

-- Toggle config flags dynamically.
require(\"default.hypr.toggles\")