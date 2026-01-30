return {
  "ibhagwan/fzf-lua",
  keys = {
    -- Override default file search to use cwd
    { "<leader>ff", function() require("fzf-lua").files({ cwd = vim.uv.cwd() }) end, desc = "Find Files (cwd)" },
    { "<leader><space>", function() require("fzf-lua").files({ cwd = vim.uv.cwd() }) end, desc = "Find Files (cwd)" },
    -- Override grep to use cwd
    { "<leader>sg", function() require("fzf-lua").live_grep({ cwd = vim.uv.cwd() }) end, desc = "Grep (cwd)" },
    { "<leader>/", function() require("fzf-lua").live_grep({ cwd = vim.uv.cwd() }) end, desc = "Grep (cwd)" },
  },
}
