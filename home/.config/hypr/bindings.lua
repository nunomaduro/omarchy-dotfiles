hl.unbind("SUPER + W")
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

local function send_shortcut_once(mods, key)
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))

    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
    end, { timeout = 50, type = "oneshot" })
  end
end

o.bind("SUPER + A", "Universal select all", send_shortcut_once("CTRL", "A"))

hl.unbind("SUPER + MINUS")
o.bind("SUPER + MINUS", "Universal zoom out", send_shortcut_once("CTRL", "minus"))

hl.unbind("SUPER + EQUAL")
o.bind("SUPER + EQUAL", "Universal zoom in", send_shortcut_once("CTRL", "equal"))
