local opt = vim.opt

opt.guicursor = ""
opt.termguicolors = true
opt.background = "dark"
opt.winborder = "solid"
opt.cmdheight = 1
opt.showmode = true
opt.signcolumn = "number"
opt.cursorcolumn = false
opt.wrap = false
opt.number = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.showtabline = 1
opt.smartindent = true
opt.ignorecase = true
opt.undofile = true

vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })

vim.cmd([[set noswapfile]])
vim.cmd([[set mouse=]])
vim.cmd([[set completeopt+=menuone,noselect,popup]])
vim.cmd([[hi @lsp.type.number gui=italic]])

local statusline = {
	"%t",
	"%r",
	"%m",
	"%=",
	"%{&filetype}",
	" %2p%%",
	" %3l:%-2c ",
}
vim.o.statusline = table.concat(statusline, "")

