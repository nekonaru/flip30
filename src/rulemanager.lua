-- src/rulemanager.lua
-- The heart of Flip30. Loads every rule from rules/, picks a random next
-- rule (never repeating the previous one), applies/reverts it cleanly, and
-- swaps on a fixed real-time interval (default: 30 seconds).
--
-- Revert contract: every rule must restore exactly the state it changed in
-- apply(). resetToDefaults() performs a full wipe for new runs and is called
-- on game over / restart.

local rulemanager = {}

rulemanager.rules = {}
rulemanager.active = {}
rulemanager.last_name = nil
rulemanager.max_active = 1 -- N active rules at once; tags prevent conflicts
rulemanager.rule_duration = 30
rulemanager.timer = rulemanager.rule_duration

local function tags_of(rule)
  if type(rule.tags) == "table" then
    return rule.tags
  end
  return {}
end

local function tags_conflict(a, b)
  for _, tag_a in ipairs(a) do
    for _, tag_b in ipairs(b) do
      if tag_a == tag_b then
        return true
      end
    end
  end
  return false
end

-- Sound flavour per tag family, passed to the swap jingle
local TAG_PITCH = {
  control = 0.8,
  gravity = 1.0,
  speed = 1.25,
  scoring = 0.9,
  colors = 1.1,
  vision = 0.7,
}

local function tag_pitch(rule)
  local tags = tags_of(rule)
  return TAG_PITCH[tags[1]] or 1.0
end

-- Validates and registers a rule table. Returns true when accepted.
function rulemanager.registerRule(rule, source)
  source = source or "unknown"
  if type(rule) ~= "table" then
    print("[rulemanager] rule from " .. source .. " did not return a table, skipped")
    return false
  end
  if type(rule.name) ~= "string" or rule.name == "" then
    print("[rulemanager] rule from " .. source .. " has no name, skipped")
    return false
  end
  if type(rule.apply) ~= "function" or type(rule.revert) ~= "function" then
    print("[rulemanager] rule '" .. rule.name .. "' must define apply() and revert(), skipped")
    return false
  end
  if rule.tags ~= nil then
    if type(rule.tags) ~= "table" then
      print("[rulemanager] rule '" .. rule.name .. "': tags must be a table, skipped")
      return false
    end
    for _, tag in ipairs(rule.tags) do
      if type(tag) ~= "string" then
        print("[rulemanager] rule '" .. rule.name .. "': tags must be strings, skipped")
        return false
      end
    end
  end
  table.insert(rulemanager.rules, rule)
  return true
end

local function load_bundled_rules()
  if not (love and love.filesystem) then
    return
  end
  -- Mod files in the save directory share the merged rules/ listing.
  -- Skip them here so only genuine bundled (trusted) rules get the full environment.
  local ok_mod, modloader = pcall(require, "src.modloader")
  local modloader_ok = ok_mod and modloader and modloader.isModPath and modloader.loadMods
  local ok, items = pcall(love.filesystem.getDirectoryItems, "rules")
  if not (ok and items) then
    print("[rulemanager] could not list rules/: " .. tostring(items))
    return
  end
  table.sort(items)
  for _, file in ipairs(items) do
    if file:match("%.lua$") then
      local path = "rules/" .. file
      local skip = modloader_ok and modloader.isModPath(path) or false
      if not skip then
        local chunk, load_err = love.filesystem.load(path)
        if not chunk then
          print("[rulemanager] cannot load " .. path .. ": " .. tostring(load_err))
        else
          local ok_call, result = pcall(chunk)
          if ok_call then
            rulemanager.registerRule(result, path)
          else
            print("[rulemanager] error loading " .. path .. ": " .. tostring(result))
          end
        end
      end
    end
  end
end

-- `mod_rules` is an array of already-sandbox-validated rule tables
-- (see src/modloader.lua). Bundled rules always load first.
function rulemanager.loadRules(mod_rules)
  rulemanager.rules = {}
  load_bundled_rules()
  if type(mod_rules) == "table" then
    for _, entry in ipairs(mod_rules) do
      rulemanager.registerRule(entry.rule or entry, entry.source or "mod")
    end
  end
  print(string.format("[rulemanager] %d rule(s) loaded", #rulemanager.rules))
end

function rulemanager.revertAll(ctx)
  for _, rule in ipairs(rulemanager.active) do
    local ok, err = pcall(rule.revert, ctx)
    if not ok then
      print("[rulemanager] error reverting '" .. rule.name .. "': " .. tostring(err))
    end
  end
  rulemanager.active = {}
end

-- Candidates: not the previous rule, no tag conflicts with current picks.
local function shuffled_candidates()
  local candidates = {}
  for _, rule in ipairs(rulemanager.rules) do
    if rule.name ~= rulemanager.last_name then
      local conflict = false
      for _, active in ipairs(rulemanager.active) do
        if tags_conflict(tags_of(rule), tags_of(active)) then
          conflict = true
          break
        end
      end
      if not conflict then
        table.insert(candidates, rule)
      end
    end
  end
  for i = #candidates, 2, -1 do
    local j = math.random(i)
    candidates[i], candidates[j] = candidates[j], candidates[i]
  end
  return candidates
end

local function try_apply(rule, ctx)
  local ok, err = pcall(rule.apply, ctx)
  if ok then
    return true
  end
  print("[rulemanager] apply failed for '" .. rule.name .. "': " .. tostring(err))
  pcall(rule.revert, ctx) -- leave no half-applied state behind
  return false
end

function rulemanager.swap(ctx)
  rulemanager.revertAll(ctx)

  local picked = {}
  for _, candidate in ipairs(shuffled_candidates()) do
    if #picked >= rulemanager.max_active then
      break
    end
    local clash = false
    for _, chosen in ipairs(picked) do
      if tags_conflict(tags_of(candidate), tags_of(chosen)) then
        clash = true
        break
      end
    end
    if not clash and try_apply(candidate, ctx) then
      table.insert(picked, candidate)
    end
  end

  rulemanager.active = picked
  rulemanager.timer = rulemanager.rule_duration

  if #picked > 0 then
    rulemanager.last_name = picked[#picked].name
    local label = picked[1].name
    if #picked > 1 then
      label = label .. " +" .. (#picked - 1)
    end
    if ctx and ctx.ui and ctx.ui.showBanner then
      ctx.ui.showBanner(label)
    end
    if ctx and ctx.sfx and ctx.sfx.play then
      pcall(ctx.sfx.play, "swap", tag_pitch(picked[1]))
    end
  else
    if ctx and ctx.ui and ctx.ui.showBanner then
      ctx.ui.showBanner("NORMAL")
    end
  end
end

function rulemanager.update(ctx, dt)
  rulemanager.timer = rulemanager.timer - dt
  for _, rule in ipairs(rulemanager.active) do
    if type(rule.update) == "function" then
      local ok, err = pcall(rule.update, ctx, dt)
      if not ok then
        print("[rulemanager] update error in '" .. rule.name .. "': " .. tostring(err))
      end
    end
  end
  if rulemanager.timer <= 0 then
    rulemanager.swap(ctx)
  end
end

function rulemanager.draw(ctx)
  for _, rule in ipairs(rulemanager.active) do
    if type(rule.draw) == "function" then
      local ok, err = pcall(rule.draw, ctx)
      if not ok then
        print("[rulemanager] draw error in '" .. rule.name .. "': " .. tostring(err))
      end
    end
  end
end

-- Full wipe back to stock behaviour: call on new run / game over.
function rulemanager.resetToDefaults(ctx)
  rulemanager.revertAll(ctx)
  rulemanager.last_name = nil
  rulemanager.timer = rulemanager.rule_duration
  if ctx then
    if ctx.world and ctx.world.reset then
      ctx.world.reset()
    end
    if ctx.player and ctx.player.reset then
      ctx.player.reset()
    end
  end
end

function rulemanager.activeName()
  if #rulemanager.active == 0 then
    return "NORMAL"
  end
  local names = {}
  for _, rule in ipairs(rulemanager.active) do
    table.insert(names, rule.name)
  end
  return table.concat(names, " + ")
end

return rulemanager
