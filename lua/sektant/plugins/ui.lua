return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			preset = "modern",
			icons = {
				mappings = true,
			},
			spec = {
				{ "<leader>s", group = "search", icon = " " },
				{ "<leader>b", group = "debug", icon = "󰃤 " },
				{ "<leader>c", group = "cmake", icon = " " },
				{ "<leader>l", group = "lsp", icon = "󰌗 " },
				{ "<leader>t", group = "tabs", icon = "󰓩 " },
			},
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "local kmps",
			},
		},
		config = function(_, opts)
			local wk = require("which-key")
			local function fix_wk_icon()
				vim.api.nvim_set_hl(0, "WhichKeyIcon", {
					fg = vim.api.nvim_get_hl(0, { name = "Identifier" }).fg,
					underline = false,
				})
			end

			fix_wk_icon()

			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = fix_wk_icon,
			})
			wk.setup(opts)

			wk.add({
				-- Groups
				{ "<leader>s", group = "search", icon = " " },
				{ "<leader>b", group = "debug", icon = "󰃤 " },
				{ "<leader>c", group = "cmake", icon = " " },
				{ "<leader>l", group = "lsp", icon = "󰌗 " },
				{ "<leader>t", group = "tabs", icon = "󰓩 " },

				-- General
				{ "<leader>y", desc = "Yank to clipboard", mode = { "n", "x" }, icon = "󰆏 " },
				{ "<leader>D", desc = "Delete to clipboard", mode = { "n", "x" }, icon = "󰆴 " },
				{ "<leader>e", desc = "File manager (Yazi)", icon = " " },
				{ "<leader>a", desc = "Edit alternate file", icon = "󰓩 " },
				{ "<leader><leader>", desc = "Find files", icon = "󰱼 " },
				{ "<leader>g", desc = "Live grep", icon = "󰱼 " },

				-- LSP
				{ "<leader>lf", desc = "Format buffer", mode = { "n", "v", "x" }, icon = "󰉢 " },
				{ "<leader>d", desc = "Diagnostic float", icon = "󰒡 " },

				-- Search (Telescope)
				{ "<leader>sa", desc = "Code actions", icon = "󰌵 " },
				{ "<leader>sb", desc = "Buffers", icon = "󰈔 " },
				{ "<leader>sc", desc = "Buffer commits", icon = " " },
				{ "<leader>sd", desc = "Diagnostics", icon = "󰒡 " },
				{ "<leader>se", desc = "Environment vars", icon = "󰆍 " },
				{ "<leader>sg", desc = "Find all files (no ignore)", icon = "󰱼 " },
				{ "<leader>sh", desc = "Help tags", icon = "󰋖 " },
				{ "<leader>si", desc = "Implementations", icon = "󰌗 " },
				{ "<leader>sk", desc = "Keymaps", icon = "󰌌 " },
				{ "<leader>sm", desc = "Man pages", icon = "󰋚 " },
				{ "<leader>so", desc = "Recent files", icon = "󰋚 " },
				{ "<leader>sr", desc = "References", icon = "󰌹 " },
				{ "<leader>ss", desc = "Fuzzy find in buffer", icon = "󰱼 " },
				{ "<leader>st", desc = "Telescope builtins", icon = "󰋖 " },
				{ "<leader>sT", desc = "Type definitions", icon = "󰌗 " },

				-- Debug (DAP)
				{ "<leader>bb", desc = "Toggle breakpoint", icon = " " },
				{ "<leader>bB", desc = "Conditional breakpoint", icon = "󰃤 " },
				{ "<leader>bc", desc = "Continue", icon = " " },
				{ "<leader>bn", desc = "Step over", icon = "󰆷 " },
				{ "<leader>bi", desc = "Step into", icon = "󰆹 " },
				{ "<leader>bo", desc = "Step out", icon = "󰆸 " },
				{ "<leader>br", desc = "REPL", icon = " " },
				{ "<leader>bu", desc = "Toggle DAP UI", icon = "󰍉 " },

				-- CMake
				{ "<leader>cg", desc = "Generate", icon = "󰜮 " },
				{ "<leader>cb", desc = "Build", icon = "󰣪 " },
				{ "<leader>cr", desc = "Run", icon = " " },
				{ "<leader>cd", desc = "Debug", icon = "󰃤 " },
				{ "<leader>ct", desc = "Select build target", icon = "󰓾 " },
				{ "<leader>cl", desc = "Select launch target", icon = "󰐊 " },
				{ "<leader>cT", desc = "Select build type", icon = "󰗴 " },
				{ "<leader>cp", desc = "Select configure preset", icon = "󰘳 " },
				{ "<leader>cP", desc = "Select build preset", icon = "󰘳 " },
				{ "<leader>cD", desc = "Select build dir", icon = " " },

				-- Tabs
				{ "<leader>tn", desc = "New tab", icon = "󰓩 " },
				{ "<leader>tx", desc = "Close tab", icon = "󰅙 " },
				{ "<leader><S-Tab>", desc = "Previous tab", icon = "󰒮 " },
				{ "<leader><Tab>", desc = "Next tab", icon = "󰒭 " },
			})
		end,
	},
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	{ -- Collection of various small independent plugins/modules
		"nvim-mini/mini.nvim",
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
			--  - ci'  - [C]hange [I]nside [']quote
			require("mini.ai").setup({ n_lines = 500 })

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require("mini.surround").setup()

			-- Simple and easy statusline.
			--  You could remove this setup call if you don't like it,
			--  and try some other statusline plugin
			local statusline = require("mini.statusline")
			-- set use_icons to true if you have a Nerd Font
			statusline.setup({ use_icons = true })

			-- You can configure sections in the statusline by overriding their
			-- default behavior. For example, here we set the section for
			-- cursor location to LINE:COLUMN
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end

			-- ... and there is more!
			--  Check out: https://github.com/nvim-mini/mini.nvim
		end,
	},
}
