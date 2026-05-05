return {
  "zenbones-theme/zenbones.nvim",
  dependencies = { "rktjmp/lush.nvim" },
  lazy = false,
  priority = 1000,
  config = function()
    vim.opt.background = "light"
    vim.cmd.colorscheme("zenbones")
  end,
}
