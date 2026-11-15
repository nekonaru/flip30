-- src/modloader.lua
-- Optional mod support: additional rules placed in `rules/` inside the LÖVE
-- save directory are loaded next to the bundled ones. Mod files run inside a
-- strict sandbox: no `os`, no `io`, no direct `love` access. Everything is
-- wrapped in pcall so a broken mod can never crash the game; it is logged
-- and skipped instead.
--
-- Bundled rules (trusted, in the game source) load with a normal environment.
-- This module only handles the save-directory extras.

local modloader = {}

local function normalize(path)
  return (path or ""):gsub("\\", "/"):gsub("/+$", ""):lower()
end

-- Detect whether `rules/<file>` resolves into the save directory
-- (a mod) rather than the game source (bundled rules).
-- getRealDirectory returns the search-root directory of the file,
-- not the file path, so compare the normalized root for equality.
local function is_mod_path(path)
  if not (love and love.filesystem and love.filesystem.getRealDirectory) then
    return false
  end
  local ok, real = pcall(love.filesystem.getRealDirectory, path)
  if not (ok and real) then
    return false
  end
  local real_dir = normalize(real)
  local save_dir = normalize(love.filesystem.getSaveDirectory())
  return real_dir == save_dir or real_dir:find(save_dir .. "/", 1, true) == 1
end

local function sandbox_env()
  local env = {
    assert = assert,
    error = error,
    getmetatable = getmetatable,
    ipairs = ipairs,
    next = next,
    pairs = pairs,
    pcall = pcall,
    print = print,
    rawequal = rawequal,
    rawget = rawget,
    rawset = rawset,
    select = select,
    setmetatable = setmetatable,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    unpack = unpack or table.unpack,
    xpcall = xpcall,
    math = {
      abs = math.abs,
      acos = math.acos,
      asin = math.asin,
      atan = math.atan,
      ceil = math.ceil,
      cos = math.cos,
      deg = math.deg,
      exp = math.exp,
      floor = math.floor,
      fmod = math.fmod,
      huge = math.huge,
      log = math.log,
      max = math.max,
      min = math.min,
      pi = math.pi,
      rad = math.rad,
      random = math.random,
      randomseed = math.randomseed,
      sin = math.sin,
      sqrt = math.sqrt,
      tan = math.tan,
    },
    string = {
      byte = string.byte,
      char = string.char,
      find = string.find,
      format = string.format,
      gmatch = string.gmatch,
      gsub = string.gsub,
      len = string.len,
      lower = string.lower,
      match = string.match,
      rep = string.rep,
      reverse = string.reverse,
      sub = string.sub,
      upper = string.upper,
    },
    table = {
      concat = table.concat,
      insert = table.insert,
      remove = table.remove,
      sort = table.sort,
      unpack = table.unpack or unpack,
    },
  }
  env._G = env
  return env
end

local function load_mod_file(path)
  local ok_read, source = pcall(love.filesystem.read, path)
  if not (ok_read and type(source) == "string") then
    print("[modloader] could not read " .. path)
    return nil
  end
  local load_fn = loadstring or load
  local chunk, load_err = load_fn(source, "@" .. path)
  if not chunk then
    print("[modloader] syntax error in " .. path .. ": " .. tostring(load_err))
    return nil
  end
  if setfenv then
    setfenv(chunk, sandbox_env())
  end
  local ok_call, result = pcall(chunk)
  if not ok_call then
    print("[modloader] error loading " .. path .. ": " .. tostring(result))
    return nil
  end
  return result
end

-- Exposed so rulemanager can skip mod files when registering bundled rules.
modloader.isModPath = is_mod_path

-- Returns an array of { rule = <table>, source = <path> } for every valid
-- mod found in the save directory's rules/ folder.
function modloader.loadMods()
  local mods = {}
  if not (love and love.filesystem) then
    return mods
  end
  local ok, items = pcall(love.filesystem.getDirectoryItems, "rules")
  if not (ok and items) then
    return mods
  end
  for _, file in ipairs(items) do
    if file:match("%.lua$") then
      local path = "rules/" .. file
      if is_mod_path(path) then
        local rule = load_mod_file(path)
        if rule then
          table.insert(mods, { rule = rule, source = path })
          print("[modloader] mod loaded: " .. path)
        end
      end
    end
  end
  return mods
end

-- Absolute path where players drop their mods. Printed for convenience.
function modloader.modDirectory()
  if love and love.filesystem then
    return love.filesystem.getSaveDirectory() .. "/rules"
  end
  return nil
end

return modloader
