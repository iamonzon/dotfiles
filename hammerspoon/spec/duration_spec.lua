local T = require("spec.harness")
local D = require("lib.duration")

T.describe("duration")

T.test("seconds under a minute", function()
  T.eq(D.formatHMS(0),  "0:00")
  T.eq(D.formatHMS(5),  "0:05")
  T.eq(D.formatHMS(59), "0:59")
end)

T.test("minutes:seconds", function()
  T.eq(D.formatHMS(60),   "1:00")
  T.eq(D.formatHMS(201),  "3:21")
  T.eq(D.formatHMS(3599), "59:59")
end)

T.test("hours:minutes:seconds", function()
  T.eq(D.formatHMS(3600), "1:00:00")
  T.eq(D.formatHMS(5025), "1:23:45")
end)

T.test("nil / negative coerce to zero", function()
  T.eq(D.formatHMS(nil),  "0:00")
  T.eq(D.formatHMS(-100), "0:00")
end)

T.test("non-integer floors", function()
  T.eq(D.formatHMS(201.9), "3:21")
end)
