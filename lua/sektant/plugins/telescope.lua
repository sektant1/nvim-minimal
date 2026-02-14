return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("telescope").setup({
				pickers = { colorscheme = { enable_preview = true, previewer = true } },
				defaults = {
					preview = { treesitter = false },
					color_devicons = true,
					sorting_strategy = "ascending",
					borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
					path_displays = { "smart" },
					layout_strategy = "horizontal",
					layout_config = {
						height = 100,
						width = 400,
						prompt_position = "top",
						preview_cutoff = 60,
					},
				},
			})

			-- Load extensions
			require("telescope").load_extension("ui-select")
			require("telescope").load_extension("env")

			require("actions-preview").setup({
				backend = { "telescope" },
				extensions = { "env" },
				telescope = vim.tbl_extend("force", require("telescope.themes").get_dropdown(), {}),
			})

			local map = vim.keymap.set
			local builtin = require("telescope.builtin")
			local function git_files()
				builtin.find_files({ no_ignore = true })
			end

			map("n", "<leader><leader>", builtin.find_files, { desc = "Find files" })
			map("n", "<leader>g", builtin.live_grep, { desc = "Live grep" })
			map("n", "<leader>sg", git_files, { desc = "Find all files (git ignored)" })
			map("n", "<leader>sb", builtin.buffers, { desc = "Buffers" })
			map("n", "<leader>so", builtin.oldfiles, { desc = "Recent files" })
			map("n", "<leader>sh", builtin.help_tags, { desc = "Help tags" })
			map("n", "<leader>sm", builtin.man_pages, { desc = "Man pages" })
			map("n", "<leader>sr", builtin.lsp_references, { desc = "LSP References" })
			map("n", "<leader>sd", builtin.diagnostics, { desc = "LSP Diagnostics" })
			map("n", "<leader>si", builtin.lsp_implementations, { desc = "LSP Implementations" })
			map("n", "<leader>sT", builtin.lsp_type_definitions, { desc = "LSP Type Defs" })
			map("n", "<leader>ss", builtin.current_buffer_fuzzy_find, { desc = "Buffer fuzzy find" })
			map("n", "<leader>st", builtin.builtin, { desc = "Telescope builtins" })
			map("n", "<leader>sc", builtin.git_bcommits, { desc = "Buffer commits" })
			map("n", "<leader>sk", builtin.keymaps, { desc = "Keymaps" })
			map("n", "<leader>se", "<cmd>Telescope env<cr>", { desc = "Environment vars" })
			map("n", "<leader>sa", require("actions-preview").code_actions, { desc = "Code Actions" })
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
	},
	{
		"LinArcX/telescope-env.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
	},
}
