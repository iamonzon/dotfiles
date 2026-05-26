-- Hover tooltip + control surface. Reads the active source from the
-- registry, shows title / elapsed / remaining, and renders buttons for
-- whichever actions the source exposes (timer: Pause/Resume + Stop;
-- calendar: info only).
--
-- Two canvases:
--   hotZone — small invisible mouse-aware region at the screen corner
--   popup   — appears on hover, refreshed each tick

local duration = require("lib.duration")

local HOT_W      = 120
local HOT_H      = 28
local POPUP_W    = 260
local POPUP_H    = 92
local CORNER_PAD = 4
local REFRESH    = 0.15  -- s between cursor polls / popup refreshes

local function hotZoneFrame(screen, position)
  local f = screen:frame()
  if position == "top" then
    return { x = f.x + CORNER_PAD, y = f.y, w = HOT_W, h = HOT_H }
  end
  return { x = f.x + CORNER_PAD, y = f.y + f.h - HOT_H, w = HOT_W, h = HOT_H }
end

local function popupFrame(screen, position)
  local f = screen:frame()
  if position == "top" then
    return { x = f.x + CORNER_PAD, y = f.y + HOT_H, w = POPUP_W, h = POPUP_H }
  end
  return { x = f.x + CORNER_PAD, y = f.y + f.h - HOT_H - POPUP_H, w = POPUP_W, h = POPUP_H }
end

local function makeHotZone(frame, onEnter)
  -- Hot zone is at popUpMenu level (above the bar) so that the bar's
  -- per-tick redraw at overlay level can't shadow it and cause spurious
  -- mouseExit events. We only use mouseEnter for instant show; hide is
  -- driven by absolute-position polling in the refresh tick.
  local c = hs.canvas.new(frame)
  c:level(hs.canvas.windowLevels.popUpMenu)
  c:behavior({"canJoinAllSpaces", "stationary"})
  c:clickActivating(false)
  c[1] = {
    type = "rectangle", action = "fill",
    fillColor = { white = 1, alpha = 0.001 },  -- effectively invisible, still hit-testable
    frame = { x = 0, y = 0, w = "100%", h = "100%" },
    trackMouseEnterExit = true,
    id = "hot",
  }
  c:canvasMouseEvents(false, false, true, false)
  c:mouseCallback(function(_, message)
    if message == "mouseEnter" then onEnter() end
  end)
  c:show()
  return c
end

local function buildPopup(frame, onClick)
  local c = hs.canvas.new(frame)
  c:level(hs.canvas.windowLevels.popUpMenu)
  c:behavior({"canJoinAllSpaces", "stationary"})
  c:clickActivating(false)
  c[1] = {  -- background plate
    type = "rectangle", action = "fill",
    fillColor = { white = 0.10, alpha = 0.93 },
    strokeColor = { white = 0.30, alpha = 0.6 },
    strokeWidth = 1,
    roundedRectRadii = { xRadius = 8, yRadius = 8 },
    frame = { x = 0, y = 0, w = "100%", h = "100%" },
    id = "bg",
  }
  c:canvasMouseEvents(true, false, false, false)
  c:mouseCallback(function(_, message, id)
    if message == "mouseDown" then onClick(id) end
  end)
  return c
end

local function clearButtons(c)
  -- Keep elements 1..3 (bg, title, line2). Remove anything after.
  while c:elementCount() > 3 do c:removeElement(c:elementCount()) end
end

local function appendButton(c, x, y, w, h, id, label)
  c:appendElements({
    type = "rectangle", action = "fill",
    fillColor = { white = 0.22, alpha = 0.95 },
    strokeColor = { white = 0.40, alpha = 0.9 },
    strokeWidth = 1,
    roundedRectRadii = { xRadius = 5, yRadius = 5 },
    frame = { x = x, y = y, w = w, h = h },
    trackMouseDown = true,
    id = "btn:" .. id,
  })
  c:appendElements({
    type = "text", text = label,
    textColor = { white = 0.98 },
    textSize = 12,
    textAlignment = "center",
    frame = { x = x, y = y + 4, w = w, h = h - 6 },
  })
end

local function refreshPopup(c, src)
  local now      = src.now or os.time()
  local total    = src.endEpoch - src.startEpoch
  local elapsed  = math.max(0, math.min(total, now - src.startEpoch))
  local left     = total - elapsed
  local pausedTag = src.paused and "  ·  paused" or ""

  c[2] = {
    type = "text",
    text = src.title or "",
    textColor = { white = 0.98 },
    textSize = 14,
    textFont = ".AppleSystemUIFont",
    frame = { x = 12, y = 8, w = POPUP_W - 24, h = 20 },
  }
  c[3] = {
    type = "text",
    text = ("%s elapsed  ·  %s left%s"):format(
      duration.formatHMS(elapsed),
      duration.formatHMS(left),
      pausedTag
    ),
    textColor = { white = 0.72 },
    textSize = 11,
    frame = { x = 12, y = 30, w = POPUP_W - 24, h = 16 },
  }

  clearButtons(c)
  local actions = src.actions or {}
  local layout = { y = 54, h = 26, w = 70, gap = 8, x = 12 }
  if actions.edit   then appendButton(c, layout.x, layout.y, layout.w, layout.h, "edit",   "Edit");   layout.x = layout.x + layout.w + layout.gap end
  if actions.pause  then appendButton(c, layout.x, layout.y, layout.w, layout.h, "pause",  "Pause");  layout.x = layout.x + layout.w + layout.gap end
  if actions.resume then appendButton(c, layout.x, layout.y, layout.w, layout.h, "resume", "Resume"); layout.x = layout.x + layout.w + layout.gap end
  if actions.stop   then appendButton(c, layout.x, layout.y, layout.w, layout.h, "stop",   "Stop")   end
end

local function activeSource(registry)
  local best
  for _, s in ipairs(registry.sources()) do
    if not best or (s.priority or 0) > (best.priority or 0) then best = s end
  end
  return best
end

local function showIfSource(self)
  local src = activeSource(self.ctx.registry)
  if not src then return end
  refreshPopup(self.popup, src)
  self.popup:show()
  self.visible = true
end

local function hidePopup(self)
  if not self.visible then return end
  self.popup:hide()
  self.visible = false
end

local function pointInFrame(p, f)
  return p.x >= f.x and p.x <= f.x + f.w
     and p.y >= f.y and p.y <= f.y + f.h
end

local function cursorOverEitherFrame(self)
  local p = hs.mouse.absolutePosition()
  return pointInFrame(p, self.hotFrame) or pointInFrame(p, self.popupFrame)
end

local function handleClick(self, id)
  local src = activeSource(self.ctx.registry)
  if not src or not src.actions then return end
  local key = id and id:match("^btn:(.+)$")
  local fn = key and src.actions[key]
  if fn then
    fn()
    -- Re-render immediately so Pause flips to Resume without waiting a tick.
    showIfSource(self)
  end
end

return {
  name = "tooltip",

  start = function(ctx)
    local position = ctx.config.BAR_POSITION
    local screen   = hs.screen.primaryScreen()

    local self = {
      ctx        = ctx,
      visible    = false,
      hotFrame   = hotZoneFrame(screen, position),
      popupFrame = popupFrame(screen, position),
    }

    self.hotZone = ctx.track(makeHotZone(
      self.hotFrame,
      function() showIfSource(self) end
    ))

    self.popup = ctx.track(buildPopup(
      self.popupFrame,
      function(id) handleClick(self, id) end
    ))

    -- Drive visibility from the real cursor position. Per-tick polling
    -- sidesteps the spurious mouseExit events the bar's overlay redraw
    -- triggers on the hot zone every second.
    self._refresh = ctx.track(hs.timer.doEvery(REFRESH, function()
      local over = cursorOverEitherFrame(self)
      if not over then
        if self.visible then hidePopup(self) end
        return
      end
      local src = activeSource(ctx.registry)
      if not src then
        if self.visible then hidePopup(self) end
        return
      end
      if not self.visible then
        self.popup:show()
        self.visible = true
      end
      pcall(refreshPopup, self.popup, src)
    end))

    return self
  end,

  stop = function(self)
    if self.popup   then pcall(function() self.popup:delete()   end); self.popup   = nil end
    if self.hotZone then pcall(function() self.hotZone:delete() end); self.hotZone = nil end
  end,

  status = function(self)
    return self.visible and "visible" or "idle"
  end,
}
