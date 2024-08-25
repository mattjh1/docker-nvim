local options = {
	automatic_installation = true,

	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
}

require("mason").setup(options)

require("mason-lspconfig").setup({
	ensure_installed = {
		"tsserver",
		"html",
		"cssls",
		"lua_ls",
		"jsonls",
		"emmet_ls",
	},
	-- auto-install configured servers (with lspconfig)
	automatic_installation = true,
})

require("mason-tool-installer").setup({
	ensure_installed = {
		"prettierd",
		"eslint_d",
		"stylua",
		"pyright",
		"jq",
		"isort",
	},
})
