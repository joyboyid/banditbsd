local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.disable_autoformat = true

opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.wrap = false
opt.showmode = false
opt.fillchars = { eob = " " }

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.breakindent = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = "split"

opt.swapfile = false
opt.backup = false
opt.undofile = true

opt.updatetime = 250
opt.timeoutlen = 300

vim.schedule(function()
	opt.clipboard = "unnamedplus"
end)

opt.mouse = "a"
opt.virtualedit = "block"
opt.confirm = true

opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitkeep = "screen"
