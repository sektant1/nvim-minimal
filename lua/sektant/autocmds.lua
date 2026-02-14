vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*",
	callback = function()
		if vim.bo.filetype == "" then
			vim.cmd("filetype detect")
		end
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("my.lsp", {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		if client:supports_method("textDocument/completion") then
			local chars = {}
			for i = 32, 126 do
				chars[#chars + 1] = string.char(i)
			end
			client.server_capabilities.completionProvider.triggerCharacters = chars
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true }),
	pattern = "*",
	callback = function(args)
		if conform_ok then
			conform.format({ bufnr = args.buf, lsp_fallback = true, timeout_ms = 1500 })
		else
			vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 1500 })
		end
	end,
})

-- Filetypes
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.tsx",
	callback = function()
		vim.bo.filetype = "typescriptreact"
	end,
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.jsx",
	callback = function()
		vim.bo.filetype = "javascriptreact"
	end,
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.vert", "*.frag", "*.geom", "*.comp", "*.tesc", "*.tese", "*.glsl" },
	callback = function()
		vim.bo.filetype = "glsl"
	end,
})

-- PHP hook
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.php",
	callback = function()
		vim.fn.jobstart("gg-repo-sync", {
			on_exit = function(_, exit_code, _)
				if exit_code == 0 then
					vim.notify("gg-repo-sync successful", vim.log.levels.INFO)
				else
					vim.notify("gg-repo-sync failed", vim.log.levels.ERROR)
				end
			end,
		})
	end,
})

-- Commands
vim.api.nvim_create_user_command("CheckBuildTools", function()
	local missing = {}
	local tools = { "cmake", "ninja", "gdb", "lldb" }
	for _, t in ipairs(tools) do
		if not U.has(t) then
			missing[#missing + 1] = t
		end
	end

	if #missing == 0 then
		vim.notify("Build/debug tools OK: cmake/ninja/gdb/lldb", vim.log.levels.INFO)
	else
		vim.notify("Missing tools: " .. table.concat(missing, ", "), vim.log.levels.WARN)
	end
end, {})
