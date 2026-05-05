return {
  "ckinan/ckgrayscale.nvim",
  dependencies = { "rktjmp/lush.nvim" },
  lazy = false,
  priority = 1000,
  config = function()
    vim.opt.background = "dark"
    vim.cmd.colorscheme("ckgrayscale")
  end,
}
