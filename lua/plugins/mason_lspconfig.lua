local options = {
	ensure_installed = { "tsserver", "lua_ls", "eslint", "cssls", "jsonls", "pyright" },
}

require("mason-lspconfig").setup(options)
