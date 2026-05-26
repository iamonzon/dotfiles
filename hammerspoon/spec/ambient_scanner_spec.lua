local T = require("spec.harness")
local scanner = require("lib.ambient_scanner")

T.describe("ambient_scanner")

-- Build a fake hs.fs.dir-style iterator factory from a hardcoded file list.
local function fakeLister(files)
  return function(_dir)
    local i = 0
    return function()
      i = i + 1
      return files[i]
    end
  end
end

T.test("filters out unsupported extensions", function()
  local list = fakeLister({ ".", "..", "rain.mp3", "notes.txt", "song.exe", "wind.wav" })
  local out = scanner.scan("/x", list)
  T.eq(#out, 2)
  T.eq(out[1].name, "rain")
  T.eq(out[2].name, "wind")
end)

T.test("prettifies underscores and hyphens to spaces", function()
  local list = fakeLister({ "coffee_shop.mp3", "soft-storm.m4a" })
  local out = scanner.scan("/x", list)
  T.eq(out[1].name, "coffee shop")
  T.eq(out[2].name, "soft storm")
end)

T.test("sorts alphabetically by display name", function()
  local list = fakeLister({ "wind.wav", "cafe.mp3", "rain.mp3" })
  local out = scanner.scan("/x", list)
  T.eq(out[1].name, "cafe")
  T.eq(out[2].name, "rain")
  T.eq(out[3].name, "wind")
end)

T.test("attaches absolute path from dir + filename", function()
  local list = fakeLister({ "rain.mp3" })
  local out = scanner.scan("/sounds", list)
  T.eq(out[1].path, "/sounds/rain.mp3")
end)

T.test("returns empty list when iterator throws", function()
  local out = scanner.scan("/nope", function() error("ENOENT") end)
  T.eq(#out, 0)
end)

T.test("returns empty list for empty directory", function()
  local out = scanner.scan("/x", fakeLister({ ".", ".." }))
  T.eq(#out, 0)
end)

T.test("extension match is case-insensitive", function()
  local out = scanner.scan("/x", fakeLister({ "RAIN.MP3", "Wind.Wav" }))
  T.eq(#out, 2)
end)
