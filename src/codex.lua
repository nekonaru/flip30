-- src/codex.lua
-- Rules codex: lists every bundled rule with name, hint and tags.

local codex = {}

function codex.build(rulemanager)
  local entries = {}
  for _, rule in ipairs(rulemanager.rules or {}) do
    table.insert(entries, {
      name = rule.name,
      hint = rule.hint or "-",
      tags = table.concat(rule.tags or {}, ", "),
    })
  end
  table.sort(entries, function(a, b)
    return a.name < b.name
  end)
  return entries
end

return codex
