-- src/modmanager.lua
-- In-game mod list with enable and disable, built on the sandbox loader.

local modmanager = {}

function modmanager.scan(rulemanager, loaded)
  local list = {}
  for _, entry in ipairs(loaded or {}) do
    table.insert(list, {
      name = entry.rule and entry.rule.name or "MOD",
      source = entry.source or "unknown",
      enabled = true,
      tags = entry.rule and entry.rule.tags or {},
    })
  end
  return list
end

function modmanager.toggle(list, index)
  local item = list[index]
  if item then
    item.enabled = not item.enabled
    return item
  end
  return nil
end

function modmanager.conflict(list)
  local seen = {}
  for _, item in ipairs(list) do
    if item.enabled then
      for _, tag in ipairs(item.tags or {}) do
        if seen[tag] then
          return tag, seen[tag], item.name
        end
        seen[tag] = item.name
      end
    end
  end
  return nil
end

return modmanager
