-- Renderer. Consumes sources from the registry, picks the highest-priority
-- one, and updates a thin always-on-top canvas. Knows nothing about timers
-- or calendars — just frames, percentages, and colors.

local BAR_HEIGHT = 3

-- high = ≤10% remaining (red), mid = ≤25% remaining (orange), low = starting color.
-- Warning colors (mid/high) are shared across sources; the starting color
-- differs (blue for manual, green for calendar) so you can tell at a glance
-- which source owns the bar before it heats up.
local PALETTE = {
  manual = {
    high = { red = 0.95, green = 0.20, blue = 0.20, alpha = 0.95 },
    mid  = { red = 1.00, green = 0.55, blue = 0.10, alpha = 0.95 },
    low  = { red = 0.30, green = 0.55, blue = 0.85, alpha = 0.95 },
  },
  calendar = {
    high = { red = 0.95, green = 0.20, blue = 0.20, alpha = 0.95 },
    mid  = { red = 1.00, green = 0.55, blue = 0.10, alpha = 0.95 },
    low  = { red = 0.40, green = 0.80, blue = 0.50, alpha = 0.95 },
  },
}

local function pickColor(kind, pct)
  local p = PALETTE[kind] or PALETTE.manual
  if pct >= 0.90 then return p.high end   -- ≤10% remaining
  if pct >= 0.75 then return p.mid  end   -- ≤25% remaining
  return p.low
end

local function computeBarFrame(screen, position, height)
  local f = screen:frame()
  local y = (position == "top") and f.y or (f.y + f.h - height)
  return { x = f.x, y = y, w = f.w, h = height }
end

local function makeCanvas(frame)
  local c = hs.canvas.new(frame)
  c:level(hs.canvas.windowLevels.overlay)
  c:behavior({"canJoinAllSpaces", "stationary"})
  c:clickActivating(false)
  c[1] = {  -- background track
    type = "rectangle", action = "fill",
    fillColor = { red = 0, green = 0, blue = 0, alpha = 0.25 },
    frame = { x = 0, y = 0, w = "100%", h = "100%" },
  }
  c[2] = {  -- filled portion
    type = "rectangle", action = "fill",
    fillColor = PALETTE.manual.low,
    frame = { x = 0, y = 0, w = "0%", h = "100%" },
  }
  c:show()
  return c
end

local function pickSource(list)
  local best = nil
  for _, s in ipairs(list) do
    if not best or (s.priority or 0) > (best.priority or 0) then best = s end
  end
  return best
end

local function computeProgress(src, fallbackNow)
  local now     = src.now or fallbackNow
  local total   = src.endEpoch - src.startEpoch
  local elapsed = now - src.startEpoch
  local pct = elapsed / total
  if pct < 0 then return 0 end
  if pct > 1 then return 1 end
  return pct
end

local function render(canvas, pct, color)
  canvas:alpha(1.0)
  canvas[2].frame = { x = 0, y = 0, w = tostring(pct * 100) .. "%", h = "100%" }
  canvas[2].fillColor = color
end

local function clear(canvas)
  canvas[2].frame = { x = 0, y = 0, w = "0%", h = "100%" }
  canvas:alpha(0.0)
end

local function tick(self)
  -- Let any source module fire its own one-shot completion side-effect.
  local timer = self.ctx.registry.get("timer")
  if timer and timer.fireExpiryIfDue then timer.fireExpiryIfDue() end

  local src = pickSource(self.ctx.registry.sources())
  if not src then clear(self.canvas); return end
  local pct = computeProgress(src, os.time())
  render(self.canvas, pct, pickColor(src.kind, pct))
end

return {
  name = "progress_bar",

  start = function(ctx)
    local position = ctx.config.BAR_POSITION
    local tickSecs = ctx.config.TICK_SECONDS

    local self = { ctx = ctx }
    self.canvas = ctx.track(makeCanvas(
      computeBarFrame(hs.screen.primaryScreen(), position, BAR_HEIGHT)
    ))

    self._tick = ctx.track(hs.timer.doEvery(tickSecs, function()
      local ok, err = pcall(tick, self)
      if not ok then ctx.log("tick error: " .. tostring(err)) end
    end))

    self._screenWatcher = ctx.track(hs.screen.watcher.new(function()
      pcall(function() self.canvas:delete() end)
      self.canvas = ctx.track(makeCanvas(
        computeBarFrame(hs.screen.primaryScreen(), position, BAR_HEIGHT)
      ))
    end))
    self._screenWatcher:start()

    return self
  end,

  stop = function(self)
    if self.canvas then
      pcall(function() self.canvas:delete() end)
      self.canvas = nil
    end
  end,

  status = function(_self)
    return ("h=%dpx · tick=%ds"):format(BAR_HEIGHT, 1)
  end,
}
