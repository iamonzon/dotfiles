-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Use nix-installed zsh (not /usr/bin/zsh which doesn't exist)
vim.opt.shell = vim.fn.exepath("zsh")
