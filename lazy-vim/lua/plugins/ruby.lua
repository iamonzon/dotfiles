return {
  -- Solargraph LSP tuning for Rails projects
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        solargraph = {
          settings = {
            solargraph = {
              diagnostics = true,
              completion = true,
              hover = true,
              references = true,
              rename = true,
              symbols = true,
              folding = false,
            },
          },
        },
      },
    },
  },

  -- vim-rails: :A (alternate file), :R (related), gf in routes
  {
    "tpope/vim-rails",
    ft = { "ruby", "eruby" },
  },

  -- vim-bundler: gf on Gemfile entries
  {
    "tpope/vim-bundler",
    ft = { "ruby" },
  },

  -- endwise: auto-insert `end` after def/do/if
  {
    "tpope/vim-endwise",
    ft = { "ruby", "eruby" },
  },
}
