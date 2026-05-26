-- Pure parser for icalBuddy output. No hs.* deps; the I/O wrapper lives
-- in modules/calendar.lua. Validation takes maxHours as a parameter so
-- the function is fully deterministic and easy to test.

local M = {}

function M.parseDate(s)
  local y, mo, d, h, mi, se = (s or ""):match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
  if not y then return nil end
  return os.time({ year = y, month = mo, day = d, hour = h, min = mi, sec = se })
end

function M.tryLongFormat(out)
  return out:match(
    "(%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d)%s*%-%s*(%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d)"
  )
end

function M.tryShortFormat(out)
  local datePart, sTime, eTime = out:match(
    "(%d%d%d%d%-%d%d%-%d%d) (%d%d:%d%d:%d%d).-(%d%d:%d%d:%d%d)"
  )
  if not datePart then return nil end
  return datePart .. " " .. sTime, datePart .. " " .. eTime
end

function M.extractTitle(out)
  local t = out:match("\n%s*([^\n]+)") or "event"
  return t:gsub("^%s+", ""):gsub("%s+$", "")
end

function M.parseOutput(out)
  if not out or out == "" then return nil end
  local startStr, endStr = M.tryLongFormat(out)
  if not startStr then startStr, endStr = M.tryShortFormat(out) end
  if not startStr then return nil end
  return {
    startEpoch = M.parseDate(startStr),
    endEpoch   = M.parseDate(endStr),
    title      = M.extractTitle(out),
  }
end

function M.validateEvent(evt, maxHours)
  if not evt then return nil end
  if not (evt.startEpoch and evt.endEpoch) then return nil end
  if evt.endEpoch <= evt.startEpoch then return nil end
  if (evt.endEpoch - evt.startEpoch) > (maxHours or 20) * 3600 then return nil end
  return evt
end

return M
