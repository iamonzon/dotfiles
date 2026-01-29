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

        local MiniFiles = require("mini.files")
        local open_split = function(direction)
          local entry = MiniFiles.get_fs_entry()
          if entry and entry.fs_type == "file" then
            -- Get the target window from explorer state
            local cur_target = MiniFiles.get_explorer_state().target_window
            -- Create new split in that window
            local new_target = vim.api.nvim_win_call(cur_target, function()
              vim.cmd(direction .. " split")
              return vim.api.nvim_get_current_win()
            end)
            -- Set the new window as target and open the file
            MiniFiles.set_target_window(new_target)
            MiniFiles.go_in({ close_on_file = true })
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

        vim.keymap.set("n", "<CR>", function()
          local entry = MiniFiles.get_fs_entry()
          if entry == nil then return end

          if entry.fs_type == "file" then
            -- Open file and close mini-files
            MiniFiles.go_in({ close_on_file = true })
          else
            -- Directory: close and reopen with this directory as root
            local path = entry.path
            MiniFiles.close()
            MiniFiles.open(path, false)
          end
        end, { buffer = buf_id, desc = "Open file / Enter directory as root" })
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
