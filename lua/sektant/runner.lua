local M = {}

function M.run_code()
	local filetype = vim.bo.filetype
	local filename = vim.fn.expand("%")
	local output_name = vim.fn.expand("%:r")

	if filetype == "python" then
		vim.cmd("vsplit | term python3 " .. filename)
	elseif filetype == "rust" then
		vim.cmd("vsplit | term cargo run")
	elseif filetype == "cpp" then
		vim.cmd("vsplit | term g++ " .. filename .. " -o " .. output_name .. " && ./" .. output_name)
	elseif filetype == "c" then
		vim.cmd("vsplit | term gcc " .. filename .. " -o " .. output_name .. " && ./" .. output_name)
	else
		print("No runner configured for " .. filetype)
	end
end

return M
