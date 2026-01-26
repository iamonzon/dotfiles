return {
  "nvim-pack/nvim-spectre",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Spectre",
  keys = {
    { "<leader>R", function() require("spectre").open() end, desc = "Search and replace" },
  },
}
