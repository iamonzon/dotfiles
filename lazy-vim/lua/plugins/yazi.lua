return {
  {
    "mikavilpas/yazi.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    keys = {
      { "<leader>y", "<cmd>Yazi<cr>", desc = "Open yazi at current file" },
      { "<leader>Y", "<cmd>Yazi cwd<cr>", desc = "Open yazi in cwd" },
    },
    opts = {
      open_for_directories = true,
      hooks = {
        yazi_opened = function(_, yazi_buffer_id, _)
          vim.keymap.set("t", "<esc>", "<cmd>close<cr>", { buffer = yazi_buffer_id })
        end,
      },
    },
  },
}
