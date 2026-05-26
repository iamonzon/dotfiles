-- Ambient sound loop. Reads the available moods from the contents of
-- the ambient/ directory next to this file — no hardcoded list, no
-- manifest. Drop a `.mp3` / `.wav` / `.m4a` / `.flac` in there and it
-- becomes a mood after the next module reload (⌃⌥⌘M → ambient).
--
-- One sound plays at a time. Cycle order: off → first → second → ... →
-- off. The button label in the timer popup shows the active mood; the
-- hotkey works without a popup so you can start a soundtrack before
-- starting a timer.

local scanner = require("lib.ambient_scanner")

local DIR = os.getenv("HOME") .. "/dotfiles/master/hammerspoon/ambient"

local function stopSound(self)
  if not self.sound then return end
  pcall(function() self.sound:stop() end)
  self.sound = nil
end

local function play(self, mood)
  stopSound(self)
  if not mood then self.current = nil; return end

  local s = hs.sound.getByFile(mood.path)
  if not s then
    hs.alert.show("Couldn't load: " .. mood.name)
    self.current = nil
    return
  end
  s:loopSound(true)
  s:volume(self.volume)
  local ok = pcall(function() s:play() end)
  if not ok then
    hs.alert.show("Couldn't play: " .. mood.name)
    self.current = nil
    return
  end
  self.sound = s
  self.current = mood
end

local function indexOfCurrent(self)
  if not self.current then return 0 end
  for i, m in ipairs(self.moods) do
    if m.path == self.current.path then return i end
  end
  return 0
end

local function cycle(self)
  if #self.moods == 0 then
    hs.alert.show("No ambient sounds in " .. DIR)
    return
  end
  local next_idx = indexOfCurrent(self) + 1
  if next_idx > #self.moods then
    play(self, nil)
    hs.alert.show("♪ off")
  else
    local mood = self.moods[next_idx]
    play(self, mood)
    hs.alert.show("♪ " .. mood.name)
  end
end

return {
  name = "ambient",

  start = function(ctx)
    local self = {
      ctx     = ctx,
      moods   = scanner.scan(DIR, hs.fs.dir),
      current = nil,
      sound   = nil,
      volume  = 0.6,
    }

    self._hotkey = ctx.track(hs.hotkey.bind(
      {"ctrl", "alt", "cmd"}, "A", function() cycle(self) end
    ))

    -- Public methods the tooltip pulls via registry.get("ambient").
    self.cycle = function() cycle(self) end
    self.currentMood = function() return self.current and self.current.name or nil end
    self.hasMoods = function() return #self.moods > 0 end

    -- pause/resume are called by the timer module on timer pause/resume
    -- so the soundscape follows session state. No-op when nothing plays.
    self.pause = function()
      if self.sound then pcall(function() self.sound:pause() end) end
    end
    self.resume = function()
      if self.sound then pcall(function() self.sound:resume() end) end
    end
    self.off = function() play(self, nil) end

    -- Spotlight-style picker. Escape leaves current playback alone — that
    -- way you can dismiss without committing to a change. onDone fires
    -- after the chooser closes (selection or Escape) so callers can defer
    -- side-effects (e.g. starting a timer) until the user actually commits.
    self.pick = function(onDone)
      if #self.moods == 0 then if onDone then onDone() end; return end
      local options = {
        { text = "Off — silence", subText = "no ambient", uuid = "_off" },
      }
      for _, m in ipairs(self.moods) do
        local marker = (self.current and self.current.path == m.path) and "  (current)" or ""
        table.insert(options, { text = m.name .. marker, subText = m.path, uuid = m.path })
      end
      local chooser = hs.chooser.new(function(choice)
        if choice then
          if choice.uuid == "_off" then
            play(self, nil)
          else
            for _, m in ipairs(self.moods) do
              if m.path == choice.uuid then play(self, m); break end
            end
          end
        end
        if onDone then onDone() end
      end)
      chooser:choices(options)
      chooser:placeholderText("Sound for this session…")
      chooser:show()
    end

    return self
  end,

  stop = function(self) stopSound(self) end,

  status = function(self)
    if #self.moods == 0 then return "no sounds in ambient/" end
    if not self.current then return ("off · %d available"):format(#self.moods) end
    return self.current.name
  end,
}
