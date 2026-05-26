-- Calendar source. Polls icalBuddy every CAL_REFRESH_SECONDS and exposes
-- the current event (if any) via source(). Parsing lives in lib/ical_parser.

local parser = require("lib.ical_parser")

local CAL_REFRESH_SECONDS = 60
local ICALBUDDY_PATH      = "/opt/homebrew/bin/icalBuddy"  -- "/usr/local/bin/icalBuddy" on Intel
local MAX_EVENT_HOURS     = 20

local CMD = ICALBUDDY_PATH ..
  [[ -nc -nrd -b "" ]] ..
  [[ -iep 'datetime,title' ]] ..
  [[ -eep 'notes,url,location,attendees' ]] ..
  [[ -df "%Y-%m-%d" -tf "%H:%M:%S" ]] ..
  [[ -po 'datetime,title' eventsNow ]]

local function runIcalBuddy()
  local out, ok = hs.execute(CMD)
  if not ok or not out or out == "" then return nil end
  return out
end

local function refresh(self)
  local raw = runIcalBuddy()
  if not raw then self.current = nil; return end
  self.current = parser.validateEvent(parser.parseOutput(raw), MAX_EVENT_HOURS)
end

return {
  name = "calendar",

  start = function(ctx)
    local self = { current = nil }
    refresh(self)
    self._poll = ctx.track(hs.timer.doEvery(CAL_REFRESH_SECONDS, function()
      refresh(self)
    end))
    return self
  end,

  stop = function(_self) end,  -- registry sweeps the timer

  status = function(self)
    if not self.current then return "no event" end
    local left = self.current.endEpoch - os.time()
    return ("%s · %dm left"):format(self.current.title, math.max(0, math.floor(left / 60)))
  end,

  source = function(self)
    local e = self.current
    if not e then return nil end
    local now = os.time()
    if now < e.startEpoch or now >= e.endEpoch then return nil end
    return {
      startEpoch = e.startEpoch,
      endEpoch   = e.endEpoch,
      title      = e.title,
      kind       = "calendar",
      priority   = 1,
    }
  end,
}
