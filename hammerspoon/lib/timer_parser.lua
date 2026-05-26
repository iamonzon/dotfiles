-- Pure parser for the manual-timer input string. No hs.* deps so it can
-- be unit-tested under standalone Lua. The module that owns I/O is
-- modules/timer.lua.

local M = {}

local function trim(s) return (s or ""):gsub("^%s+", ""):gsub("%s+$", "") end

local function matchColon(s)
  local h, m = s:match("^(%d+):(%d+)$")
  return h and (tonumber(h) * 60 + tonumber(m)) or nil
end

local function matchSeconds(s)
  local ss = s:match("^(%d+)s$")
  return ss and (tonumber(ss) / 60) or nil
end

local function matchHourMinute(s)
  local hh = s:match("^(%d+)h")
  local mm = s:match("h(%d+)m?$") or s:match("^(%d+)m$")
  if not (hh or mm) then return nil end
  return (tonumber(hh) or 0) * 60 + (tonumber(mm) or 0)
end

local function matchBareMinutes(s)
  return s:match("^(%d+)$") and tonumber(s) or nil
end

M.MATCHERS = { matchColon, matchSeconds, matchHourMinute, matchBareMinutes }

function M.parseInput(raw)
  local s = trim(raw)
  if s == "" then return nil end
  local timepart, label = s:match("^(%S+)%s+(.+)$")
  if not timepart then timepart, label = s, "Focus" end
  for _, fn in ipairs(M.MATCHERS) do
    local minutes = fn(timepart)
    if minutes and minutes > 0 then return minutes, label end
  end
  return nil
end

function M.durationLabel(minutes)
  if minutes >= 1 then return ("%g min"):format(minutes) end
  return ("%ds"):format(math.floor(minutes * 60))
end

return M
