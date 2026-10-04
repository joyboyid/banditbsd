return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").install({
			"c",
			"cpp",
			"python",
			"lua",
			"luadoc",
			"vim",
			"vimdoc",
			"query",
			"html",
			"css",
			"javascript",
			"typescript",
			"tsx",
			"json",
		})
		local MAX_FILESIZE = 100 * 1024
		local function is_too_large(buf)
			local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
			return ok and stats and stats.size > MAX_FILESIZE
		end
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local buf = args.buf
				local lang = vim.treesitter.language.get_lang(args.match)
				if not lang then
					return
				end
				if is_too_large(buf) then
					return
				end
				vim.treesitter.start(buf, lang)
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				vim.wo[buf].foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.wo[buf].foldmethod = "expr"
				vim.wo[buf].foldlevel = 99
			end,
		})
	end,
}
