-- Pure directory scan. Filenames in the ambient/ folder are the source
-- of truth for available moods — no hardcoded list, no manifest. Add a
-- file, it shows up; remove it, it's gone after the next module reload.

local M = {}

local SUPPORTED = {
  mp3 = true, m4a = true, wav = true, aiff = true,
  aif = true, caf = true, flac = true,
}

local function extOf(name)
  local ext = name:match("%.([^%.]+)$")
  return ext and ext:lower() or nil
end

local function prettify(filename)
  local stem = filename:match("(.+)%.[^%.]+$") or filename
  return (stem:gsub("[_%-]+", " "))
end

-- listFn is an iterator factory (e.g. hs.fs.dir). Injected so tests can
-- pass a fake without touching the filesystem.
function M.scan(dir, listFn)
  local out = {}
  -- listFn follows the hs.fs.dir / generic-for protocol: returns
  -- (iter, state, init). pcall it so a missing directory or permission
  -- error gives an empty result rather than crashing module start.
  local ok, iter, state, init = pcall(listFn, dir)
  if not ok or type(iter) ~= "function" then return out end

  for name in iter, state, init do
    if name and name ~= "." and name ~= ".." then
      local ext = extOf(name)
      if ext and SUPPORTED[ext] then
        table.insert(out, { name = prettify(name), path = dir .. "/" .. name })
      end
    end
  end

  table.sort(out, function(a, b) return a.name < b.name end)
  return out
end

return M
