-- src/inputmap.lua
-- Rebindable keyboard actions with defaults and persistence.

local inputmap = {}

inputmap.actions = { "left", "right", "dash", "focus", "pause", "mute" }
inputmap.defaults = {
  left = "a",
  right = "d",
  dash = "lshift",
  focus = "space",
  pause = "p",
  mute = "m",
}

function inputmap.new()
  local t = {}
  for _, action in ipairs(inputmap.actions) do
    t[action] = inputmap.defaults[action]
  end
  return t
end

function inputmap.bind(map, action, key)
  if map[action] ~= nil then
    map[action] = key
    return true
  end
  return false
end

function inputmap.matches(map, action, key)
  return map[action] == key
end

return inputmap
