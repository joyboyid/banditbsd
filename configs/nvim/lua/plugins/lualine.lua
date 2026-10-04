return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = {
		{ "nvim-tree/nvim-web-devicons", lazy = true },
	},
	opts = {
		options = {
			theme = "everforest",
			component_separators = "",
			section_separators = { left = "", right = "" },
			globalstatus = true,
			disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
		},
		sections = {
			lualine_a = {
				{
					"mode",
					icon = "",
					separator = { right = "" },
					padding = { left = 1, right = 1 },
				},
			},
			lualine_b = {
				{
					"branch",
					icon = "",
					padding = { left = 1, right = 1 },
				},
				{
					"diff",
					symbols = { added = " ", modified = " ", removed = " " },
					padding = { left = 0, right = 1 },
				},
			},
			lualine_c = {
				{
					"filename",
					path = 1,
					symbols = { modified = " ●", readonly = " ", unnamed = "[Unamed File]" },
				},
				{
					"diagnostics",
					sources = { "nvim_diagnostic" },
					symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
				},
			},
			lualine_x = {
				{
					function()
						local msg = "Sin LSP"
						local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
						local clients = vim.lsp.get_clients({ bufnr = 0 })
						if next(clients) == nil then
							return msg
						end
						local client_names = {}
						for _, client in ipairs(clients) do
							table.insert(client_names, client.name)
						end
						return "" .. table.concat(client_names, ", ")
					end,
					color = { gui = "bold" },
					padding = { left = 1, right = 1 },
				},
				{
					"filetype",
					icon_only = false,
					separator = { left = "" },
					padding = { left = 1, right = 1 },
				},
			},
			lualine_y = {
				{
					"progress",
					icon = "",
					padding = { left = 1, right = 1 },
				},
			},
			lualine_z = {
				{
					"location",
					icon = "",
					padding = { left = 1, right = 1 },
				},
			},
		},
	},
}
