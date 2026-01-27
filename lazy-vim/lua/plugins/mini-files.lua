return {
  "nvim-mini/mini.files",
  config = function(_, opts)
    require("mini.files").setup(opts)

    vim.api.nvim_create_autocmd("DirChanged", {
      callback = function()
        if require("mini.files").close() then
          require("mini.files").open(vim.uv.cwd(), true)
        end
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        local buf_id = args.data.buf_id

        local open_split = function(direction)
          local entry = require("mini.files").get_fs_entry()
          if entry and entry.fs_type == "file" then
            local win_id = vim.api.nvim_get_current_win()
            vim.api.nvim_win_call(require("mini.files").get_target_window(), function()
              vim.cmd(direction .. " " .. vim.fn.fnameescape(entry.path))
            end)
            vim.api.nvim_set_current_win(win_id)
          end
        end

        vim.keymap.set("n", "<esc>", function()
          require("mini.files").close()
        end, { buffer = buf_id })

        vim.keymap.set("n", "<C-l>", function()
          open_split("vsplit")
        end, { buffer = buf_id, desc = "Open in vertical split" })

        vim.keymap.set("n", "<C-k>", function()
          open_split("split")
        end, { buffer = buf_id, desc = "Open in horizontal split" })
      end,
    })
  end,
  keys = {
    {
      "<leader>m",
      function()
        if not require("mini.files").close() then
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end
      end,
      desc = "Toggle mini.files (current file)",
    },
    {
      "<leader>M",
      function()
        if not require("mini.files").close() then
          require("mini.files").open(LazyVim.root(), true)
        end
      end,
      desc = "Toggle mini.files (root)",
    },
  },
}
