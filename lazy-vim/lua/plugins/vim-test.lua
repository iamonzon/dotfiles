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

    -- LMS: detect Rails project and run rspec through Docker
    local lms_root = vim.fn.expand("~/Work/boddle-projects/learning-management-system/main")

    vim.g["test#custom_transformations"] = {
      docker_lms = function(cmd)
        local file = vim.fn.expand("%:p")
        if file:find(lms_root, 1, true) then
          -- Strip the project root to get the relative spec path
          local rel_cmd = cmd:gsub(lms_root .. "/", "")
          return string.format(
            "docker-compose -f %s/docker-compose-rspec.yml run --rm lms bundle exec %s",
            lms_root,
            rel_cmd
          )
        end
        -- Non-LMS projects: just cd and run normally
        return string.format("cd %s && %s", vim.fn.getcwd(), cmd)
      end,
    }
    vim.g["test#transformation"] = "docker_lms"
  end,
}
