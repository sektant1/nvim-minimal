return {
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("oil").setup({
				lsp_file_methods = {
					enabled = true,
					timeout_ms = 1000,
					autosave_changes = true,
				},
				columns = { "permissions", "icon" },
				float = {
					max_width = 0.7,
					max_height = 0.6,
					border = "solid",
				},
			})
		end,
	},
	{
		"mikavilpas/yazi.nvim",
		config = function()
			require("yazi").setup({
				open_for_directories = true,
				floating_window_scaling_factor = 0.8,
				keymaps = { show_help = "<f1>" },
			})
		end,
	},
}
