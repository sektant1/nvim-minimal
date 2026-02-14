-- lua/sektant/lazy.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		-- 1) LazyVim base plugins FIRST
		-- { "LazyVim/LazyVim", import = "lazyvim.plugins" },

		-- 2) LazyVim extras NEXT (add/remove as you want)
		-- { import = "lazyvim.plugins.extras.lang.typescript" },
		-- { import = "lazyvim.plugins.extras.lang.clangd" },

		-- 3) Your plugins LAST (this must come after the above)
		{ import = "sektant.plugins" }, -- or { import = "sektant.plugins" } depending on your folder
	},
})
