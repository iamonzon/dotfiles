return {
  {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = false,
    keys = {
      { "<leader>cc", desc = "Claude Code" },
      { "<leader>cf", desc = "Claude Code with file" },
    },
    config = function()
      require("claude-code").setup({
        window = {
          position = "float",
          float_opts = {
            width = 0.8,
            height = 0.8,
            border = "rounded",
          },
        },
        keymaps = {
          toggle = {
            normal = "<leader>cc",
            terminal = nil, -- Disabled - use <Esc> then <leader>cc to close
          },
        },
      })

      -- Set buffer-local mapping when LSP attaches to override codelens
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          vim.keymap.set("n", "<leader>cc", function()
            require("claude-code").toggle()
          end, { buffer = args.buf, desc = "Toggle Claude Code" })
        end,
      })

      -- Global fallback for non-LSP buffers
      vim.keymap.set("n", "<leader>cc", function()
        require("claude-code").toggle()
      end, { desc = "Toggle Claude Code" })

      vim.keymap.set("n", "<leader>cf", function()
        local relative_path = vim.fn.expand("%:.")
        local text = "@" .. relative_path .. " "

        -- Toggle to open/focus Claude terminal
        require("claude-code").toggle()

        -- Send file path to terminal after it's focused
        vim.defer_fn(function()
          local chan = vim.b.terminal_job_id
          if chan then
            vim.fn.chansend(chan, text)
          end
        end, 50)
      end, { desc = "Claude Code with current file" })
    end,
  },
}
