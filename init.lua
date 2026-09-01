-- Requires neovim 0.11 or higher for native LSP integration
vim.opt.clipboard = "unnamedplus"
vim.o.number = true
vim.g.mapleader = " "
-- vim.cmd.colorscheme("catppuccin")
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.colorcolumn = "80"

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
			auto_integrations = true,
		},
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

-- Instead of showing the default nvim intro, we will show a custom one
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() ~= 0 or vim.api.nvim_buf_get_name(0) ~= "" then
			return
		end
		-- needs env var in .zshrc (or .bashrc) to load the golang binary
		-- ref: https://github.com/ckinan/lab/tree/main/apps/ckintro.nvim
		local go_cmd = os.getenv("CKINTRO_NVIM") or ""
		local handle = io.popen(go_cmd)
		if not handle then
			return
		end

		-- Read everything and split into lines
		local output = handle:read("*a")
		handle:close()
		local lines = {}
		for line in string.gmatch(output, "[^\r\n]+") do
			table.insert(lines, line)
		end

		-- Set up buffer
		local bufnr = vim.api.nvim_get_current_buf()
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
		vim.bo[bufnr].buftype, vim.bo[bufnr].bufhidden, vim.bo[bufnr].modifiable = "nofile", "wipe", false

		-- Tiny Keymap: Just grabs the line and runs ":edit <line>"
		vim.keymap.set("n", "<CR>", function()
			local path = vim.fn.trim(vim.api.nvim_get_current_line())
			vim.cmd("edit " .. vim.fn.fnameescape(vim.fn.expand(path)))
		end, { buffer = bufnr, silent = true })
	end,
})
