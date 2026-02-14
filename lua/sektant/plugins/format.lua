return {
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					javascript = { "prettierd", "prettier" },
					javascriptreact = { "prettierd", "prettier" },
					typescript = { "prettierd", "prettier" },
					typescriptreact = { "prettierd", "prettier" },
					json = { "prettierd", "prettier" },
					jsonc = { "prettierd", "prettier" },
					css = { "prettierd", "prettier" },
					scss = { "prettierd", "prettier" },
					html = { "prettierd", "prettier" },
					yaml = { "prettierd", "prettier" },
				},
			})
		end,
	},
}
