-- Module registry. Loads modules, holds strong refs to every hs.* handle
-- they create (the GC pin from IDEATION.md §6), and provides hot reload
-- without re-bootstrapping Hammerspoon.

local config = require("core.config")

local M = {}

-- name -> { mod, inst, refs = { hs.timer | hs.canvas | hs.screen.watcher | hs.hotkey, ... } }
local instances = {}

-- Weak-keyed set of every canvas ever handed out, so we can sweep
-- orphans if a module's stop() forgets one before reload.
local seenCanvases = setmetatable({}, { __mode = "k" })

local function classify(handle)
  if type(handle) ~= "userdata" and type(handle) ~= "table" then return nil end
  local s = tostring(handle)
  if s:find("hs.canvas",         1, true) then return "canvas" end
  if s:find("hs.hotkey",         1, true) then return "hotkey" end
  if s:find("hs.timer",          1, true) then return "timer_or_watcher" end
  if s:find("hs.screen.watcher", 1, true) then return "timer_or_watcher" end
  return nil
end

local function releaseRef(handle)
  local kind = classify(handle)
  if kind == "canvas" then
    pcall(function() handle:delete() end)
  elseif kind == "hotkey" then
    pcall(function() handle:delete() end)
  elseif kind == "timer_or_watcher" then
    pcall(function() handle:stop() end)
  end
end

local function sweepOrphanCanvases()
  for c, _ in pairs(seenCanvases) do
    pcall(function() c:delete() end)
    seenCanvases[c] = nil
  end
end

local function makeCtx(name)
  local refs = {}
  return {
    config = config,
    registry = M,
    log = function(msg) print(("[%s] %s"):format(name, msg)) end,
    track = function(handle)
      refs[#refs + 1] = handle
      if classify(handle) == "canvas" then seenCanvases[handle] = true end
      return handle
    end,
    _refs = refs,
  }
end

function M.register(mod)
  if instances[mod.name] then
    error("registry: module already registered: " .. mod.name)
  end
  local ctx = makeCtx(mod.name)
  local ok, inst = pcall(mod.start, ctx)
  if not ok then
    hs.alert.show(("✖ %s failed to start: %s"):format(mod.name, inst))
    return
  end
  instances[mod.name] = { mod = mod, inst = inst, refs = ctx._refs }
end

function M.stop(name)
  local entry = instances[name]
  if not entry then return end
  if entry.mod.stop then pcall(entry.mod.stop, entry.inst) end
  for _, handle in ipairs(entry.refs) do releaseRef(handle) end
  entry.inst, entry.refs = nil, nil
end

function M.reload(name)
  local entry = instances[name]
  if not entry then return end
  M.stop(name)
  sweepOrphanCanvases()
  package.loaded["modules." .. name] = nil
  local ok, mod = pcall(require, "modules." .. name)
  if not ok then
    hs.alert.show(("✖ reload %s failed: %s"):format(name, mod))
    instances[name] = nil
    return
  end
  local ctx = makeCtx(name)
  local ok2, inst = pcall(mod.start, ctx)
  if not ok2 then
    hs.alert.show(("✖ %s restart failed: %s"):format(name, inst))
    instances[name] = nil
    return
  end
  instances[name] = { mod = mod, inst = inst, refs = ctx._refs }
  hs.alert.show("↻ " .. name)
end

function M.get(name)
  local entry = instances[name]
  return entry and entry.inst or nil
end

function M.list()
  local names = {}
  for name in pairs(instances) do names[#names + 1] = name end
  table.sort(names)
  return names
end

function M.status(name)
  local entry = instances[name]
  if not entry or not entry.mod.status then return "" end
  local ok, s = pcall(entry.mod.status, entry.inst)
  return ok and s or "(status error)"
end

function M.sources()
  local out = {}
  for _, name in ipairs(M.list()) do
    local entry = instances[name]
    if entry.mod.source then
      local ok, src = pcall(entry.mod.source, entry.inst)
      if ok and src then out[#out + 1] = src end
    end
  end
  return out
end

return M
