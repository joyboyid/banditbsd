return {
	"mason-org/mason.nvim",
	cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonInstallAll" },
	build = ":MasonUpdate",
	opts = {
		ui = {
			border = "rounded",
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
		},
	},
	config = function(_, opts)
		require("mason").setup(opts)
		local ensure_installed = {
			"clangd",
			"clang-format",
			"pyright",
			"ruff",
			"lua-language-server",
			"stylua",
			"typescript-language-server",
			"html-lsp",
			"css-lsp",
			"tailwindcss-language-server",
			"emmet-ls",
			"prettier",
		}

		vim.api.nvim_create_user_command("MasonInstallAll", function()
			local mr = require("mason-registry")
			mr.refresh(function()
				for _, tool in ipairs(ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
				vim.notify("Verification/Mason package installation complete.", vim.log.levels.INFO)
			end)
		end, {})
	end,
}
