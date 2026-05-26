-- Global constants. A value belongs here only if more than one module
-- would otherwise need to duplicate it. Module-specific tuning stays
-- inside the module that owns it.

return {
  TICK_SECONDS = 1,
  BAR_POSITION = "bottom",  -- "top" or "bottom"
}
