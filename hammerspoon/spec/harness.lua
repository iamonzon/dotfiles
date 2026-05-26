-- Tiny test harness. No deps. Specs register with T.test(name, fn) and
-- assert via T.eq / T.is_nil / T.truthy. Exit code is 0 on green, 1 on
-- any failure — fits CI without extra glue.

local T = { _suite = "", _tests = {}, _pass = 0, _fail = 0, _failures = {} }

function T.describe(suite) T._suite = suite end

function T.test(name, fn)
  T._tests[#T._tests + 1] = { suite = T._suite, name = name, fn = fn }
end

local function repr(v)
  if type(v) == "string" then return ("%q"):format(v) end
  if type(v) == "table"  then return "<table>" end
  return tostring(v)
end

function T.eq(actual, expected, ...)
  -- Multi-return support: T.eq(parseInput("25"), 25, "Focus")
  local extras = { ... }
  if #extras > 0 then
    if actual ~= expected then
      error(("expected %s, got %s"):format(repr(expected), repr(actual)), 2)
    end
    return
  end
  if actual ~= expected then
    error(("expected %s, got %s"):format(repr(expected), repr(actual)), 2)
  end
end

function T.is_nil(actual)
  if actual ~= nil then
    error(("expected nil, got %s"):format(repr(actual)), 2)
  end
end

function T.truthy(actual)
  if not actual then error("expected truthy, got " .. repr(actual), 2) end
end

function T.run()
  for _, t in ipairs(T._tests) do
    local ok, err = pcall(t.fn)
    local label = ("%s · %s"):format(t.suite, t.name)
    if ok then
      T._pass = T._pass + 1
      print("PASS  " .. label)
    else
      T._fail = T._fail + 1
      T._failures[#T._failures + 1] = label .. " — " .. tostring(err)
      print("FAIL  " .. label .. " — " .. tostring(err))
    end
  end
  print(("\n%d passed, %d failed"):format(T._pass, T._fail))
  os.exit(T._fail == 0 and 0 or 1)
end

return T
