return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	keys = {
		{ "ff", "<cmd>Telescope find_files<CR>", desc = "Buscar archivos" },
		{ "fb", "<cmd>Telescope buffers<CR>", desc = "Buscar buffers" },
		{ "fh", "<cmd>Telescope help_tags<CR>", desc = "Buscar ayuda" },
		{ "fd", "<cmd>Telescope diagnostics<CR>", desc = "Buscar diagnósticos" },
	},
	dependencies = {
		{ "nvim-lua/plenary.nvim", lazy = true },
	},
	opts = {
		defaults = {
			prompt_prefix = "   ",
			selection_caret = "  ",
			sorting_strategy = "ascending",
			layout_strategy = "horizontal",
			mappings = {
				i = {
					["<C-j>"] = "move_selection_next",
					["<C-k>"] = "move_selection_previous",
				},
			},
			layout_config = {
				horizontal = {
					prompt_position = "top",
					preview_width = 0.50,
				},
				width = 0.85,
				height = 0.80,
			},
			results_title = false,
			preview_title = false,
			prompt_title = false,
			file_ignore_patterns = { "node_modules", "%.git/", "__pycache__", "build/", "%.o", "%.a" },
		},
	},
}
