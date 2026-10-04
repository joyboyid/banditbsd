return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "v" },
			desc = "Formatear archivo",
		},
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			python = { "isort", "black" },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			html = { "prettierd", "prettier", stop_after_first = true },
			css = { "prettierd", "prettier", stop_after_first = true },
		},
		formatters = {
			["clang-format"] = {
				prepend_args = {
					"-style={BasedOnStyle: LLVM, IndentWidth: 4, AlignConsecutiveAssignments: true, AlignConsecutiveDeclarations: true, AlignTrailingComments: true}",
				},
			},
			prettierd = {
				prepend_args = { "--tab-width", "4" },
			},
			prettier = {
				prepend_args = { "--tab-width", "4" },
			},
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
	},
}
