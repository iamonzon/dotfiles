-- JSON preview and diff tools (no plugin dependency, just keymaps)
-- <leader>jq  — preview selection as formatted JSON
-- <leader>j1  — stash selection for diff
-- <leader>j2  — diff stashed JSON against current selection
-- <leader>jc  — yank buffer as compacted JSON to clipboard
-- <leader>jp  — yank buffer as pretty JSON to clipboard

local function set_json_buffer_keymaps(buf)
  vim.keymap.set("n", "<leader>jc", function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local json = table.concat(lines, "\n")
    local result = vim.fn.system("jq -c .", json)
    result = result:gsub("%s+$", "")
    vim.fn.setreg("+", result)
    vim.notify("Compacted JSON copied to clipboard", vim.log.levels.INFO)
  end, { buffer = buf, desc = "Copy compacted JSON to clipboard" })

  vim.keymap.set("n", "<leader>jp", function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local json = table.concat(lines, "\n")
    local result = vim.fn.system("jq .", json)
    result = result:gsub("%s+$", "")
    vim.fn.setreg("+", result)
    vim.notify("Pretty JSON copied to clipboard", vim.log.levels.INFO)
  end, { buffer = buf, desc = "Copy pretty JSON to clipboard" })
end

vim.keymap.set("v", "<leader>jq", function()
  vim.cmd('normal! "jy')
  vim.cmd("new")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.filetype = "json"
  vim.cmd("put j")
  vim.cmd("1delete")
  vim.cmd("%!jq .")
  set_json_buffer_keymaps(vim.api.nvim_get_current_buf())
end, { desc = "Preview JSON formatted" })

vim.keymap.set("v", "<leader>j1", function()
  vim.cmd('normal! "jy')
  vim.g.json_diff_stash = vim.fn.getreg("j")
  vim.notify("JSON stashed for diff", vim.log.levels.INFO)
end, { desc = "Stash JSON for diff" })

vim.keymap.set("v", "<leader>j2", function()
  if not vim.g.json_diff_stash then
    vim.notify("No stashed JSON — select first with <leader>j1", vim.log.levels.WARN)
    return
  end
  vim.cmd('normal! "jy')
  vim.cmd("tabnew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.filetype = "json"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(vim.g.json_diff_stash, "\n"))
  vim.cmd("%!jq .")
  set_json_buffer_keymaps(vim.api.nvim_get_current_buf())
  vim.cmd("diffthis")
  vim.cmd("vnew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.filetype = "json"
  vim.cmd("put j")
  vim.cmd("1delete")
  vim.cmd("%!jq .")
  set_json_buffer_keymaps(vim.api.nvim_get_current_buf())
  vim.cmd("diffthis")
  vim.g.json_diff_stash = nil
end, { desc = "Diff stashed JSON against selection" })

return {}
