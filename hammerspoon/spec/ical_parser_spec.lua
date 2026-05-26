local T = require("spec.harness")
local P = require("lib.ical_parser")

T.describe("ical_parser")

local LONG_FORMAT = [[
2026-05-24 14:30:00 - 2026-05-24 15:00:00
    Team standup
]]

local SHORT_FORMAT = [[
2026-05-24 14:30:00 - 15:00:00
    Quick sync
]]

local ALL_DAY = [[
2026-05-24 00:00:00 - 2026-05-25 00:00:00
    Office Hours
]]

T.test("parseDate roundtrips a known timestamp", function()
  local epoch = P.parseDate("2026-05-24 14:30:00")
  T.truthy(epoch)
  -- Re-parse via os.date should give back the same fields.
  local t = os.date("*t", epoch)
  T.eq(t.year, 2026); T.eq(t.month, 5); T.eq(t.day, 24)
  T.eq(t.hour, 14); T.eq(t.min, 30); T.eq(t.sec, 0)
end)

T.test("parseDate returns nil on garbage", function()
  T.is_nil(P.parseDate(""))
  T.is_nil(P.parseDate("not a date"))
  T.is_nil(P.parseDate(nil))
end)

T.test("tryLongFormat extracts both endpoints", function()
  local s, e = P.tryLongFormat(LONG_FORMAT)
  T.eq(s, "2026-05-24 14:30:00")
  T.eq(e, "2026-05-24 15:00:00")
end)

T.test("tryLongFormat returns nil on short-form input", function()
  T.is_nil(P.tryLongFormat(SHORT_FORMAT))
end)

T.test("tryShortFormat handles single-date + two times", function()
  local s, e = P.tryShortFormat(SHORT_FORMAT)
  T.eq(s, "2026-05-24 14:30:00")
  T.eq(e, "2026-05-24 15:00:00")
end)

T.test("extractTitle pulls the indented title line", function()
  T.eq(P.extractTitle(LONG_FORMAT),  "Team standup")
  T.eq(P.extractTitle(SHORT_FORMAT), "Quick sync")
end)

T.test("extractTitle falls back to 'event' when missing", function()
  T.eq(P.extractTitle("2026-05-24 14:30:00 - 2026-05-24 15:00:00"), "event")
end)

T.test("parseOutput returns full event for long format", function()
  local evt = P.parseOutput(LONG_FORMAT)
  T.truthy(evt)
  T.eq(evt.title, "Team standup")
  T.truthy(evt.startEpoch); T.truthy(evt.endEpoch)
  T.eq(evt.endEpoch - evt.startEpoch, 30 * 60)  -- 30 min
end)

T.test("parseOutput returns full event for short format", function()
  local evt = P.parseOutput(SHORT_FORMAT)
  T.truthy(evt)
  T.eq(evt.title, "Quick sync")
  T.eq(evt.endEpoch - evt.startEpoch, 30 * 60)
end)

T.test("parseOutput nil on empty / unmatched", function()
  T.is_nil(P.parseOutput(""))
  T.is_nil(P.parseOutput(nil))
  T.is_nil(P.parseOutput("no dates here"))
end)

T.test("validateEvent passes a normal event", function()
  local evt = P.parseOutput(LONG_FORMAT)
  T.truthy(P.validateEvent(evt, 20))
end)

T.test("validateEvent rejects all-day blocks past maxHours", function()
  local evt = P.parseOutput(ALL_DAY)
  T.truthy(evt)            -- parse succeeded
  T.is_nil(P.validateEvent(evt, 20))  -- but 24h > 20h cap
end)

T.test("validateEvent rejects nil / inverted / zero-length", function()
  T.is_nil(P.validateEvent(nil, 20))
  T.is_nil(P.validateEvent({ startEpoch = 100, endEpoch = 100 }, 20))
  T.is_nil(P.validateEvent({ startEpoch = 200, endEpoch = 100 }, 20))
end)

T.test("validateEvent defaults maxHours to 20 when omitted", function()
  local evt = P.parseOutput(ALL_DAY)
  T.is_nil(P.validateEvent(evt))
end)
