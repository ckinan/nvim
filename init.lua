vim.opt.statuscolumn = "%s %{v:relnum} %{v:lnum}"
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.opt.cursorline = true
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local hl = vim.api.nvim_get_hl(0, { name = "CursorLine" })
    hl.underline = true
    vim.api.nvim_set_hl(0, "CursorLine", hl)
  end,
})
vim.opt.list = true
vim.opt.listchars = {
  eol = "↵",
  tab = "→ ",
  space = "·",
  multispace = "···+",
  lead = "·",
  trail = "•",
  extends = ">",
  precedes = "<",
  conceal = "░",
  nbsp = "␣",
}
vim.opt.clipboard = "unnamedplus"
vim.opt.updatetime = 500  -- Trigger CursorHold faster (default is 4000ms)

require("config.lazy")

-- Exit terminal mode with Alt+, Alt+n
vim.keymap.set('t', '<A-,><A-n>', '<C-\\><C-n>')





