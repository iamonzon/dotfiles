-- Entry point. Adds the project root to package.path so `lib.*` and
-- `spec.*` resolve, then loads every *_spec.lua next to it and runs.
--
-- Usage:  lua spec/run.lua

local function projectRoot()
  local here = arg[0]:match("(.*/)") or "./"
  return here .. ".."
end

local root = projectRoot()
package.path = table.concat({
  root .. "/?.lua",
  root .. "/?/init.lua",
  package.path,
}, ";")

local T = require("spec.harness")

require("spec.timer_parser_spec")
require("spec.ical_parser_spec")
require("spec.duration_spec")
require("spec.ambient_scanner_spec")

T.run()
