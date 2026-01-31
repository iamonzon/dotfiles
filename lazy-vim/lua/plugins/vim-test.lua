return {
  "vim-test/vim-test",
  keys = {
    { "<leader>tn", "<cmd>TestNearest<CR>", desc = "Test nearest" },
    { "<leader>tf", "<cmd>TestFile<CR>", desc = "Test file" },
    { "<leader>ts", "<cmd>TestSuite<CR>", desc = "Test suite" },
    { "<leader>tl", "<cmd>TestLast<CR>", desc = "Test last" },
    { "<leader>tv", "<cmd>TestVisit<CR>", desc = "Test visit" },
  },
  config = function()
    vim.g["test#strategy"] = "neovim_sticky"

    -- cd to project root before running (handles relative binary paths)
    vim.g["test#custom_transformations"] = {
      cd_project = function(cmd)
        return string.format("cd %s && %s", vim.fn.getcwd(), cmd)
      end,
    }
    vim.g["test#transformation"] = "cd_project"
  end,
}
