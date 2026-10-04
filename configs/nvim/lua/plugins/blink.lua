return {
	"saghen/blink.cmp",
	version = "*",
	event = "InsertEnter",
	dependencies = {
		{ "rafamadriz/friendly-snippets", lazy = true },
	},
	opts = {
		keymap = {
			preset = "enter",
			["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
			["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
		},
		appearance = {
			use_nvim_cmp_as_default = false,
			nerd_font_variant = "mono",
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			providers = {
				buffer = {
					score_offset = -3,
					min_keyword_length = 3,
					max_items = 5,
				},
			},
		},
		completion = {
			accept = {
				auto_brackets = { enabled = false },
			},
			menu = {
				max_height = 10,
				border = "rounded",
				draw = {
					treesitter = {},
					columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 350,
				window = { border = "rounded" },
			},
			ghost_text = { enabled = true },
		},
		signature = {
			enabled = true,
			window = { border = "rounded" },
		},
	},
	opts_extend = { "sources.default" },
}
