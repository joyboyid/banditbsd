return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "williamboman/mason.nvim", opts = {} },
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			local lspconfig = require("lspconfig")
			local mason_lspconfig = require("mason-lspconfig")
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local has_blink, blink = pcall(require, "blink.cmp")
			if has_blink then
				capabilities = blink.get_lsp_capabilities(capabilities)
			end
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
				callback = function(ev)
					local opts = { buffer = ev.buf, silent = true }
					local map = vim.keymap.set

					map("n", "gd", vim.lsp.buf.definition, opts)
					map("n", "K", vim.lsp.buf.hover, opts)
					map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
					map("n", "<leader>rn", vim.lsp.buf.rename, opts)
					map("n", "[d", vim.diagnostic.goto_prev, opts)
					map("n", "]d", vim.diagnostic.goto_next, opts)
					map("n", "<leader>d", vim.diagnostic.open_float, opts)
				end,
			})
			vim.diagnostic.config({
				virtual_text = { severity = { min = vim.diagnostic.severity.WARN } },
				signs = true,
				update_in_insert = false,
				severity_sort = true,
			})
			mason_lspconfig.setup({
				ensure_installed = {
					"lua_ls",
					"clangd",
					"pyright",
					"bashls",
					"ts_ls",
					"html",
					"cssls",
					"rust_analyzer",
					"dockerls",
				},
				automatic_installation = true,
				handlers = {
					function(server_name)
						lspconfig[server_name].setup({
							capabilities = capabilities,
							flags = { debounce_text_changes = 200 },
						})
					end,
					["clangd"] = function()
						lspconfig.clangd.setup({
							capabilities = capabilities,
							cmd = {
								"clangd",
								"--background-index=false",
								"-j=2",
								"--clang-tidy=false",
								"--header-insertion=never",
							},
						})
					end,
					["lua_ls"] = function()
						lspconfig.lua_ls.setup({
							capabilities = capabilities,
							settings = {
								Lua = {
									diagnostics = { globals = { "vim" } },
									workspace = { checkThirdParty = false },
									telemetry = { enable = false },
								},
							},
						})
					end,
					["pyright"] = function()
						lspconfig.pyright.setup({
							capabilities = capabilities,
							settings = {
								python = {
									analysis = { typeCheckingMode = "basic" },
								},
							},
						})
					end,
				},
			})
		end,
	},
}
