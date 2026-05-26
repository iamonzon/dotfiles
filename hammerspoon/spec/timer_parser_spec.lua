local T = require("spec.harness")
local P = require("lib.timer_parser")

T.describe("timer_parser")

T.test("bare minutes", function()
  local m, label = P.parseInput("25")
  T.eq(m, 25); T.eq(label, "Focus")
end)

T.test("bare minutes with label", function()
  local m, label = P.parseInput("25 deep work")
  T.eq(m, 25); T.eq(label, "deep work")
end)

T.test("colon form", function()
  local m, label = P.parseInput("1:30")
  T.eq(m, 90); T.eq(label, "Focus")
end)

T.test("hour-minute compact (1h30)", function()
  local m = P.parseInput("1h30")
  T.eq(m, 90)
end)

T.test("hour-minute with m suffix (1h30m)", function()
  local m = P.parseInput("1h30m")
  T.eq(m, 90)
end)

T.test("hour only (2h)", function()
  local m = P.parseInput("2h")
  T.eq(m, 120)
end)

T.test("minutes with m suffix (45m)", function()
  local m = P.parseInput("45m")
  T.eq(m, 45)
end)

T.test("seconds form (90s = 1.5 min)", function()
  local m = P.parseInput("90s")
  T.eq(m, 1.5)
end)

T.test("empty input returns nil", function()
  T.is_nil(P.parseInput(""))
  T.is_nil(P.parseInput("   "))
  T.is_nil(P.parseInput(nil))
end)

T.test("garbage input returns nil", function()
  T.is_nil(P.parseInput("abc"))
  T.is_nil(P.parseInput("0"))           -- zero is rejected
end)

T.test("trims surrounding whitespace", function()
  local m, label = P.parseInput("  25 deep work  ")
  T.eq(m, 25); T.eq(label, "deep work")
end)

T.test("multi-word label preserved", function()
  local _, label = P.parseInput("25 read the paper")
  T.eq(label, "read the paper")
end)

T.test("durationLabel formats minutes", function()
  T.eq(P.durationLabel(25),   "25 min")
  T.eq(P.durationLabel(1.5),  "1.5 min")
end)

T.test("durationLabel formats sub-minute as seconds", function()
  T.eq(P.durationLabel(0.5),  "30s")
  T.eq(P.durationLabel(0.25), "15s")
end)
