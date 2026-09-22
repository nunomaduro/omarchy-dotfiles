o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

local key_press_milliseconds = 50

local function send_chords(chords)
  for index, chord in ipairs(chords) do
    local start = (index - 1) * key_press_milliseconds * 2

    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = chord[1], key = chord[2], state = "down" }))
    end, { timeout = math.max(start, 1), type = "oneshot" })

    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = chord[1], key = chord[2], state = "up" }))
    end, { timeout = start + key_press_milliseconds, type = "oneshot" })
  end
end

local function active_window_is_terminal()
  local window = hl.get_active_window()
  if not window then
    return false
  end

  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then
      return true
    end
  end

  return false
end

local function mac_shortcut(keys, description, app_chords, terminal_chords)
  hl.unbind(keys)
  o.bind(keys, description, function()
    if active_window_is_terminal() then
      send_chords(terminal_chords)
    else
      send_chords(app_chords)
    end
  end)
end

local function same_everywhere(keys, description, chords)
  mac_shortcut(keys, description, chords, chords)
end

local command_letters = {
  { "B", "Bold" },
  { "D", "Bookmark" },
  { "F", "Find" },
  { "G", "Find next" },
  { "I", "Italic" },
  { "J", "Downloads" },
  { "K", "Insert link" },
  { "L", "Address bar" },
  { "N", "New window" },
  { "O", "Open" },
  { "P", "Print" },
  { "R", "Reload" },
  { "S", "Save" },
  { "U", "Underline" },
  { "W", "Close tab" },
  { "Z", "Undo" },
}

for _, letter in ipairs(command_letters) do
  mac_shortcut("SUPER + " .. letter[1], "Mac " .. letter[2], { { "CTRL", letter[1] } }, { { "CTRL SHIFT", letter[1] } })
end

hl.unbind("SUPER + T")
o.bind("SUPER + T", "Mac New tab, or new terminal in a terminal", function()
  if active_window_is_terminal() then
    hl.exec_cmd("omarchy-launch-terminal")
  else
    send_chords({ { "CTRL", "T" } })
  end
end)

same_everywhere("SUPER + A", "Mac Select all", { { "CTRL", "A" } })
same_everywhere("SUPER + SHIFT + Z", "Mac Redo", { { "CTRL SHIFT", "Z" } })
same_everywhere("SUPER + SHIFT + T", "Mac Reopen closed tab", { { "CTRL SHIFT", "T" } })

hl.unbind("SUPER + code:19")
same_everywhere("SUPER + code:19", "Mac Actual size", { { "CTRL", "0" } })

hl.unbind("SUPER + code:20")
same_everywhere("SUPER + MINUS", "Mac Zoom out", { { "CTRL", "minus" } })

hl.unbind("SUPER + code:21")
same_everywhere("SUPER + EQUAL", "Mac Zoom in", { { "CTRL", "equal" } })

same_everywhere("SUPER + BRACKETLEFT", "Mac Back", { { "ALT", "Left" } })
same_everywhere("SUPER + BRACKETRIGHT", "Mac Forward", { { "ALT", "Right" } })
same_everywhere("SUPER + SHIFT + BRACKETLEFT", "Mac Previous tab", { { "CTRL SHIFT", "Tab" } })
same_everywhere("SUPER + SHIFT + BRACKETRIGHT", "Mac Next tab", { { "CTRL", "Tab" } })

same_everywhere("SUPER + LEFT", "Mac Line start", { { "", "Home" } })
same_everywhere("SUPER + RIGHT", "Mac Line end", { { "", "End" } })
same_everywhere("SUPER + UP", "Mac Document start", { { "CTRL", "Home" } })
same_everywhere("SUPER + DOWN", "Mac Document end", { { "CTRL", "End" } })
same_everywhere("SUPER + SHIFT + LEFT", "Mac Select to line start", { { "SHIFT", "Home" } })
same_everywhere("SUPER + SHIFT + RIGHT", "Mac Select to line end", { { "SHIFT", "End" } })
same_everywhere("SUPER + SHIFT + UP", "Mac Select to document start", { { "CTRL SHIFT", "Home" } })
same_everywhere("SUPER + SHIFT + DOWN", "Mac Select to document end", { { "CTRL SHIFT", "End" } })
mac_shortcut("SUPER + BACKSPACE", "Mac Delete to line start", { { "SHIFT", "Home" }, { "", "BackSpace" } }, { { "CTRL", "U" } })

same_everywhere("ALT + LEFT", "Mac Word left", { { "CTRL", "Left" } })
same_everywhere("ALT + RIGHT", "Mac Word right", { { "CTRL", "Right" } })
same_everywhere("ALT + SHIFT + LEFT", "Mac Select word left", { { "CTRL SHIFT", "Left" } })
same_everywhere("ALT + SHIFT + RIGHT", "Mac Select word right", { { "CTRL SHIFT", "Right" } })
mac_shortcut("ALT + BACKSPACE", "Mac Delete word left", { { "CTRL", "BackSpace" } }, { { "CTRL", "W" } })
mac_shortcut("ALT + DELETE", "Mac Delete word right", { { "CTRL", "Delete" } }, { { "ALT", "D" } })
