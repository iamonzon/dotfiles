-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "WW", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "QQ", ":q!<CR>", { desc = "Quit without saving" })

-- Split creation (matching Cursor's Ctrl+Alt+h/j/k/l)
vim.keymap.set("n", "<C-A-l>", "<cmd>vsplit<CR>", { desc = "Split right" })
vim.keymap.set("n", "<C-A-h>", "<cmd>vsplit<CR><C-w>H", { desc = "Split left" })
vim.keymap.set("n", "<C-A-j>", "<cmd>split<CR>", { desc = "Split down" })
vim.keymap.set("n", "<C-A-k>", "<cmd>split<CR><C-w>K", { desc = "Split up" })

-- Navigation history
vim.keymap.set("n", "<leader>h", "<C-o>", { desc = "Navigate back" })
vim.keymap.set("n", "<leader>l", "<C-i>", { desc = "Navigate forward" })

-- Buffer navigation
vim.keymap.set("n", "<leader>nh", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>nl", "<cmd>bnext<CR>", { desc = "Next buffer" })

-- Code folding
vim.keymap.set("n", "<leader>-", "zC", { desc = "Fold recursively" })
vim.keymap.set("n", "<leader>=", "zO", { desc = "Unfold recursively" })

-- Toggle inlay hints (type/parameter inference)
vim.keymap.set("n", "<leader>i", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

-- Rename symbol
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "Rename symbol" })

-- Code actions
vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, { desc = "Code actions" })

-- Diagnostics list
vim.keymap.set("n", "<leader>dl", "<cmd>Trouble diagnostics<CR>", { desc = "Diagnostics list" })

-- Pane maximize toggle
local maximized = false
vim.keymap.set("n", "<leader>pf", function()
  if maximized then
    vim.cmd("wincmd =")
    maximized = false
  else
    vim.cmd("wincmd |")
    vim.cmd("wincmd _")
    maximized = true
  end
end, { desc = "Toggle window fullscreen" })


-- File explorer (matching Cursor's Ctrl+B)
vim.keymap.set("n", "<C-b>", "<cmd>Neotree toggle<CR>", { desc = "Toggle file explorer" })

-- Format document (matching Cursor's Alt+Cmd+L → using leader for compatibility)
vim.keymap.set("n", "<leader>lf", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format document" })

-- LSP navigation (leader+n namespace)
vim.keymap.set("n", "<leader>nd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "<leader>ni", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "<leader>nu", function()
  require("fzf-lua").lsp_references()
end, { desc = "Go to usages (references)" })

-- Pane operations (leader+p namespace)
vim.keymap.set("n", "<leader>pl", function()
  vim.cmd("vsplit")
  vim.lsp.buf.definition()
end, { desc = "Definition in right split" })
vim.keymap.set("n", "<leader>pj", function()
  vim.cmd("split")
  vim.lsp.buf.definition()
end, { desc = "Definition in below split" })
vim.keymap.set("n", "<leader>px", "<cmd>close<CR>", { desc = "Close pane" })

-- Lazy menu
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<CR>", { desc = "Lazy" })

-- Changelog
vim.keymap.set("n", "<leader>C", "<cmd>Lazy changelog<CR>", { desc = "Changelog" })

-- Notification history
vim.keymap.set("n", "<leader>N", function()
  require("noice").cmd("history")
end, { desc = "Notification history" })

-- Escape to focus editor (matching Cursor behavior)
vim.keymap.set("n", "<Esc>", "<cmd>noh<CR><Esc>", { desc = "Clear search and escape" })
