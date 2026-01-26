return {
  "nvim-mini/mini.animate",
  opts = function()
    local animate = require("mini.animate")
    return {
      cursor = {
        timing = animate.gen_timing.linear({ duration = 80, unit = "total" }),
        -- Try: exponential, quadratic, cubic for different feels
        -- path = animate.gen_path.line(),
      },
      scroll = {
        timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),
      },
      resize = {
        timing = animate.gen_timing.linear({ duration = 50, unit = "total" }),
      },
    }
  end,
}
