-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- Omarchy's defaults load before this file, so a key it already claims has to
-- be unbound before it can be rebound. The comment on each unbind records what
-- the key does by default.

-- Default: Spotify
hl.unbind("SUPER + SHIFT + M")
o.bind("SUPER + SHIFT + M", "YouTube Music", { webapp = "https://music.youtube.com", focus = true })

-- Default: Signal
hl.unbind("SUPER + SHIFT + G")
o.bind("SUPER + SHIFT + G", "GitHub", { webapp = "https://github.com" })

-- Default: Email (Hey)
hl.unbind("SUPER + SHIFT + E")
o.bind("SUPER + SHIFT + E", "Email", { webapp = "https://mail.google.com" })

-- Default: Grok
hl.unbind("SUPER + SHIFT + ALT + A")
o.bind("SUPER + SHIFT + ALT + A", "Gemini", { webapp = "https://gemini.google.com/app" })

-- Unclaimed by Omarchy's defaults, so no unbind needed.
o.bind("SUPER + SHIFT + L", "Linear", { webapp = "https://linear.app", focus = true })
