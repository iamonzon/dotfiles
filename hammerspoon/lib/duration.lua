-- Format integer seconds as compact human duration. Pure; tested.

local M = {}

local function pad2(n) return ("%02d"):format(n) end

function M.formatHMS(seconds)
  if not seconds or seconds < 0 then seconds = 0 end
  seconds = math.floor(seconds)
  local h = math.floor(seconds / 3600)
  local m = math.floor((seconds % 3600) / 60)
  local s = seconds % 60
  if h > 0 then return ("%d:%s:%s"):format(h, pad2(m), pad2(s)) end
  return ("%d:%s"):format(m, pad2(s))
end

return M
