return {
	-- current Theme
	{
		"dgrco/deepwater.nvim",
		lazy = false, -- load at startup
		priority = 1000, -- load before other UI plugins
		config = function()
			vim.opt.termguicolors = true
			vim.cmd.colorscheme("deepwater")
		end,
	},

	-- other themes
	{ "RostislavArts/naysayer.nvim" },
	{ "uhs-robert/oasis.nvim" },
	{ "DeviusVim/deviuspro.nvim" },
	{ "NTBBloodbath/doom-one.nvim" },
	{ "rainglow/vim" },
	{ "Mofiqul/vscode.nvim" },
	{ "darkvoid-theme/darkvoid.nvim" },
	{ "nyoom-engineering/oxocarbon.nvim" },
	{ "michaeljsmith/vim-colours-dark-lord" },
}
