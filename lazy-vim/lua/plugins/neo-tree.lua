return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    init = function() end, -- Don't auto-open when starting with a directory
    opts = {
      window = {
        position = "right",
      },
    },
  },
  {
    "folke/edgy.nvim",
    opts = function(_, opts)
      -- Move neo-tree from left to right
      opts.right = opts.right or {}
      table.insert(opts.right, {
        title = "Neo-Tree",
        ft = "neo-tree",
        size = { width = 40 },
      })
      -- Remove neo-tree from left if present
      if opts.left then
        opts.left = vim.tbl_filter(function(win)
          return win.ft ~= "neo-tree"
        end, opts.left)
      end
    end,
  },
}
