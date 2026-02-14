return {
	{
		"m4xshen/autoclose.nvim",
		config = function()
			require("autoclose").setup()
		end,
	},
	{
		"chentoast/marks.nvim",
		config = function()
			require("marks").setup({
				builtin_marks = { "<", ">", "^" },
				refresh_interval = 250,
				sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
				excluded_filetypes = {},
				excluded_buftypes = {},
				mappings = {},
			})
		end,
	},
	-- {
	-- 	"norcalli/nvim-colorizer.lua",
	-- 	config = function()
	-- 		require("colorizer").setup()
	-- 	end,
	-- },
}
