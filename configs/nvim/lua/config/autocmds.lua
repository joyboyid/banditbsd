--@diagnostic disable: undefined-global

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local antigravity_group = augroup("AntigravityGroup", { clear = true })

autocmd("TextYankPost", {
	group = antigravity_group,
	callback = function()
		vim.highlight.on_yank({
			hlgroup = "IncSearch",
			timeout = 150,
		})
	end,
})

local ignore_restore_ft = { gitcommit = true, gitrebase = true, commit = true }

autocmd("BufReadPost", {
	group = antigravity_group,
	callback = function(event)
		local ft = vim.bo[event.buf].filetype
		if ignore_restore_ft[ft] then
			return
		end
		local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
		local lcount = vim.api.nvim_buf_line_count(event.buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

autocmd("FileType", {
	group = antigravity_group,
	pattern = {
		"PlenaryOutline",
		"checkhealth",
		"grug-far",
		"help",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"query",
		"spectre_panel",
		"startuptime",
		"tsplaygr",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close!<cr>", { buffer = event.buf, silent = true, nowait = true })
	end,
})

autocmd("FileType", {
	group = antigravity_group,
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

autocmd("BufWritePre", {
	group = antigravity_group,
	callback = function(event)
		if event.match:match("^%w%w+:[\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		local dir = vim.fn.fnamemodify(file, ":h")
		if not vim.uv.fs_stat(dir) then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

autocmd("LspAttach", {
	group = antigravity_group,
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client then
			client.server_capabilities.semanticTokensProvider = nil
		end
	end,
})
