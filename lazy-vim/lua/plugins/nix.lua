return {
  -- Use system-installed nil instead of Mason
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {},
      -- Don't auto-install nil_ls, we use system nil
      handlers = {
        nil_ls = function() end,
      },
    },
  },
  -- Configure nil LSP directly
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = {
          mason = false,
        },
      },
    },
  },
}
