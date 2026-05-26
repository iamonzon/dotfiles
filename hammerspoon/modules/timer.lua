-- Manual countdown timer. Owns its hotkeys and a one-shot expiry
-- notification. Exposes a snapshot via source() that progress_bar reads
-- and a control surface (stop/pause/resume) that tooltip invokes.

local parser = require("lib.timer_parser")

local function editPreset(self)
  if not self.active then return "" end
  local now = self.pausedAt or os.time()
  local remaining = math.max(1, math.ceil((self.active.endEpoch - now) / 60))
  return ("%d %s"):format(remaining, self.active.title)
end

local function prompt(self, preset)
  local btn, text = hs.dialog.textPrompt(
    "Manual timer",
    "Examples:  25  ·  25 deep work  ·  1h30  ·  1:30  ·  90s",
    preset or "", "Start", "Cancel"
  )
  if btn ~= "Start" then return end

  local minutes, title = parser.parseInput(text)
  if not minutes then
    hs.alert.show("Couldn't parse: " .. tostring(text))
    return
  end

  local now = os.time()
  self.active = {
    startEpoch = now,
    endEpoch   = now + math.floor(minutes * 60),
    title      = title,
  }
  self.pausedAt = nil
  self.expiredFired = false
  hs.alert.show(("⏱  %s · %s"):format(title, parser.durationLabel(minutes)))
end

local function stop(self, silent)
  if not self.active then return end
  self.active = nil
  self.pausedAt = nil
  if not silent then hs.alert.show("Timer cancelled") end
end

local function pause(self)
  if not self.active or self.pausedAt then return end
  self.pausedAt = os.time()
  hs.alert.show("⏸  Paused")
end

local function resume(self)
  if not self.active or not self.pausedAt then return end
  local elapsedPause = os.time() - self.pausedAt
  self.active.endEpoch = self.active.endEpoch + elapsedPause
  self.pausedAt = nil
  hs.alert.show("▶  Resumed")
end

return {
  name = "timer",

  start = function(ctx)
    local self = { active = nil, pausedAt = nil, expiredFired = false }

    self._startHotkey = ctx.track(hs.hotkey.bind(
      {"ctrl", "alt", "cmd"}, "T", function() prompt(self) end
    ))
    self._cancelHotkey = ctx.track(hs.hotkey.bind(
      {"ctrl", "alt", "cmd"}, ".", function() stop(self) end
    ))

    self.fireExpiryIfDue = function()
      if not self.active or self.pausedAt then return false end
      if os.time() < self.active.endEpoch then return false end
      if self.expiredFired then return false end
      hs.notify.new({
        title           = "Timer done",
        informativeText = self.active.title,
        soundName       = hs.notify.defaultNotificationSound,
      }):send()
      self.expiredFired = true
      self.active = nil
      return true
    end

    return self
  end,

  stop = function(_self) end,  -- registry sweeps the hotkeys

  status = function(self)
    if not self.active then return "idle" end
    if self.pausedAt then return ("%s · paused"):format(self.active.title) end
    local remaining = self.active.endEpoch - os.time()
    if remaining < 0 then remaining = 0 end
    return ("%s · %ds left"):format(self.active.title, remaining)
  end,

  source = function(self)
    local a = self.active
    if not a then return nil end
    if not self.pausedAt and os.time() >= a.endEpoch then return nil end
    return {
      startEpoch = a.startEpoch,
      endEpoch   = a.endEpoch,
      title      = a.title,
      kind       = "manual",
      priority   = 10,                          -- manual wins over calendar
      now        = self.pausedAt,               -- nil ⇒ live clock; set ⇒ frozen
      paused     = self.pausedAt ~= nil,
      actions = {
        edit   = function() prompt(self, editPreset(self)) end,
        stop   = function() stop(self) end,
        pause  = (not self.pausedAt) and function() pause(self) end  or nil,
        resume = (self.pausedAt)     and function() resume(self) end or nil,
      },
    }
  end,
}
