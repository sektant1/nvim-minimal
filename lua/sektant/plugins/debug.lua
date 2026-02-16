return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- UI / virtual text
			dapui.setup()
			require("nvim-dap-virtual-text").setup({ commented = true })

			-- Signs
			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "", numhl = "" })

			-- codelldb path (mason)
			local function codelldb_path()
				local mason = vim.fn.stdpath("data") .. "/mason"
				local uv = vim.uv or vim.loop
				local sys = uv.os_uname().sysname
				local ext = (sys:match("Windows")) and ".exe" or ""
				return mason .. "/packages/codelldb/extension/adapter/codelldb" .. ext
			end

			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = codelldb_path(),
					args = { "--port", "${port}" },
				},
			}

			-- Keymaps
			local map = vim.keymap.set
			map("n", "<leader>bb", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
			map("n", "<leader>bB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "DAP: Conditional breakpoint" })
			map("n", "<leader>bc", dap.continue, { desc = "DAP: Continue" })
			map("n", "<leader>bn", dap.step_over, { desc = "DAP: Step over" })
			map("n", "<leader>bi", dap.step_into, { desc = "DAP: Step into" })
			map("n", "<leader>bo", dap.step_out, { desc = "DAP: Step out" })
			map("n", "<leader>br", function()
				dap.repl.open()
			end, { desc = "DAP: REPL" })
			map("n", "<leader>bu", function()
				dapui.toggle()
			end, { desc = "DAP: Toggle UI" })

			-- integrate with cmake-tools if it's already loaded, else fallback to prompt
			local function dap_program()
				local cmake_ok, CMake = pcall(require, "cmake-tools")
				if cmake_ok and CMake.ensure_executable then
					local exe = CMake.ensure_executable()
					if exe and exe ~= "" then
						return exe
					end
				end

				local root = (cmake_ok and CMake.root and CMake.root()) or vim.fn.getcwd()
				local build_dir = (cmake_ok and CMake.build_dir) or "build"
				return vim.fn.input("Executable: ", root .. "/" .. build_dir .. "/", "file")
			end

			dap.configurations.cpp = {
				{
					name = "Launch (codelldb)",
					type = "codelldb",
					request = "launch",
					program = dap_program,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
				},
				{
					name = "Launch (codelldb, terminal)",
					type = "codelldb",
					request = "launch",
					program = dap_program,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
					runInTerminal = true,
				},
				{
					name = "Attach (pick process)",
					type = "codelldb",
					request = "attach",
					pid = require("dap.utils").pick_process,
					cwd = "${workspaceFolder}",
				},
			}
			dap.configurations.c = dap.configurations.cpp

			-- Auto open/close dapui
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},
}
