-- Requires neovim 0.11 or higher for native LSP integration
vim.opt.clipboard = "unnamedplus"
vim.o.number = true
vim.o.relativenumber = true
vim.g.mapleader = " "
-- vim.cmd.colorscheme("catppuccin")
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.colorcolumn = ""

vim.opt.list = false
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

vim.api.nvim_create_user_command("ToggleVisualHelpers", function()
	vim.wo.list = not vim.wo.list
	vim.wo.colorcolumn = vim.wo.colorcolumn == "80" and "" or "80"
end, { desc = "Toggle visual helpers" })

vim.keymap.set("n", "<leader>v", "<cmd>ToggleVisualHelpers<CR>", {
	desc = "Toggle visual helpers",
})

-- INIT: lazy.nvim
-- Bootstrap lazy.nvim
-- The following section is a copy-paste from official lazy.nvim docs
-- See: https://lazy.folke.io/installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)
-- END: lazy.nvim

-- INIT: Setup plugins
require("lazy").setup({
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				"clang-format",
				"stylua",
				"ruff",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = {
				"clangd",
				"lua_ls",
				"gopls",
				"basedpyright",
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		opts = {
			ensure_installed = {
				"c",
				"gdscript",
				"godot_resource",
				"lua",
				"vim",
				"vimdoc",
				"go",
				"python",
				"markdown",
				"markdown_inline",
			},
		},
	},
	{
		"saghen/blink.cmp",
		-- do not use v2 yet, they say: "active development with many breaking changes"
		branch = "v1",
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			signature = { enabled = true },
			keymap = {
				preset = "none",
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
			},
			completion = {
				documentation = { auto_show = true },
				menu = {
					draw = {
						columns = {
							{ "label", "label_description", gap = 1 },
							{ "kind" },
							{ "source_name" },
						},
					},
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				providers = {
					path = {
						opts = {
							show_hidden_files_by_default = true,
						},
					},
				},
			},
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		opts_extend = { "sources.default" },
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				c = { "clang_format" },
				lua = { "stylua" },
				gdscript = { "gdscript-formatter" },
				go = { "gofmt" },
				python = {
					"ruff_fix",
					"ruff_format",
				},
			},
		},
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "mocha",
			-- for some reason, integration with blink.cmp feels "broken"
			-- TODO investigate why
		},
	},
	{
		"lewis6991/gitsigns.nvim",
	},
	{
		"karb94/neoscroll.nvim",
		opts = {
			easing = "quadratic",
			duration_multiplier = 0.3,
			mappings = {
				-- only want to override behavior for ctrl_u and ctrl_d
				-- that's just my preference, not due to issues/bugs/whatsoever
				"<C-u>",
				"<C-d>",
			},
		},
	},
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		---@module "fzf-lua"
		---@type fzf-lua.Config|{}
		---@diagnostic disable: missing-fields
		opts = {
			grep = {
				-- If fzf-lua auto-detects 'rg' on your system, it uses this:
				rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden -e",
			},
		},
		---@diagnostic enable: missing-fields
	},
})
-- END: Setup plugins

-- INIT: Setup lsp
local capabilities = require("blink.cmp").get_lsp_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = false

vim.lsp.config("clangd", {
	capabilities = capabilities,
})

vim.lsp.config("lua_ls", {
	capabilities = capabilities,
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})

vim.lsp.config("gdscript", {
	capabilities = capabilities,
	cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
	filetypes = { "gdscript" },
	root_markers = { "project.godot" },
})

vim.lsp.config("gopls", {
	capabilities = capabilities,
})

vim.lsp.config("basedpyright", {
	capabilities = capabilities,
})

vim.lsp.enable("clangd")
vim.lsp.enable("lua_ls")
vim.lsp.enable("gdscript")
vim.lsp.enable("gopls")
vim.lsp.enable("basedpyright")

-- LSP navigation
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
-- END: Setup lsp

-- Enable syntax highlight
vim.filetype.add({
	filename = {
		["project.godot"] = "godot_resource",
	},
	extension = {
		tscn = "godot_resource",
		tres = "godot_resource",
	},
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"c",
		"gdscript",
		"godot_resource",
		"lua",
		"vim",
		"vimdoc",
		"go",
		"python",
	},
	callback = function()
		vim.treesitter.start()
	end,
})

-- Diagnostics
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setqflist()
	vim.cmd.copen()
end)

-- Formatting
vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({
		async = true,
		lsp_format = "fallback",
	})
end)

-- Grep
-- Example of use: `:grep! 'printf.*true' **/*.c | copen`
vim.opt.grepprg = "rg --vimgrep"

-- file explorer
vim.g.netrw_liststyle = 1
vim.g.netrw_sizestyle = "H"

-- theme
-- this option draws the border in the floating windows like lsp hover or blink cmp completion suggestions
vim.o.winborder = "single"
-- vim.o.pumborder = "rounded"
vim.cmd.colorscheme("catppuccin-nvim")

-- INIT: neoscroll customizations
-- add the ability to specify how many lines you want to scroll and persist it
-- e.g. `20+ctrl_u` would move up by 20 lines
-- `duration = 250` taken from https://github.com/karb94/neoscroll.nvim/blob/master/lua/neoscroll/init.lua
local neoscroll = require("neoscroll")
neoscroll.setup({ mappings = {} }) -- disable default <C-u>/<C-d> mappings
local modes = { "n", "v", "x" }
-- this number is arbitrary, currently it just feels the right number of lines to scroll by default
vim.wo.scroll = 30

vim.keymap.set(modes, "<C-u>", function()
	if vim.v.count > 0 then
		vim.wo.scroll = vim.v.count
	end
	neoscroll.ctrl_u({ duration = 250 })
end)

vim.keymap.set(modes, "<C-d>", function()
	if vim.v.count > 0 then
		vim.wo.scroll = vim.v.count
	end
	neoscroll.ctrl_d({ duration = 250 })
end)
-- END: neoscroll customizations

-- INIT: fzf-lua customizations
local fzf = require("fzf-lua")
vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Fzf files" })
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Fzf content" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Fzf buffers" })
vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "Fzf help tags" })

-- Structured favorites with shortcuts and aliases
vim.keymap.set("n", "<leader>F", function()
	local absolute_path = vim.fn.expand("~/.config/nvim-favorite-files/config.lua")

	local chunk, err = loadfile(absolute_path)
	if not chunk then
		vim.notify("Could not read favorites file: " .. tostring(err), vim.log.levels.WARN)
		return
	end

	local raw_favorites = chunk()
	if type(raw_favorites) ~= "table" then
		vim.notify("Favorites file must return a valid Lua table matrix", vim.log.levels.WARN)
		return
	end

	local display_entries = {}
	local fzf_bind_flags = {}

	for index, item in ipairs(raw_favorites) do
		local dynamic_id = tostring(index)
		table.insert(display_entries, string.format("[%s] %s  (%s)", dynamic_id, item.alias, item.path))
		table.insert(fzf_bind_flags, string.format("%s:to-entry:[%s]", dynamic_id, dynamic_id))
	end

	fzf.fzf_exec(display_entries, {
		prompt = "Favorites > ",
		fzf_opts = {
			["--bind"] = table.concat(fzf_bind_flags, ","),
		},
		actions = {
			["default"] = function(selected)
				if not selected or #selected == 0 then
					return
				end
				local selection_string = selected[1]
				local actual_path = selection_string:match("%((.-)%)")
				if actual_path then
					vim.cmd("edit " .. vim.fn.expand(actual_path))
				end
			end,
		},
	})
end, { desc = "Fzf modular favorite files" })
-- END: fzf-lua customizations

-- INIT: folding (collapse/expand)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99
-- END: folding

-- INIT: keymap to insert timestamp
vim.keymap.set("i", "<C-g>i", function()
	return os.date("%Y%m%d%H%M%S")
end, { expr = true, desc = "Insert timestamp" })
-- END: keymap to insert timestamp
