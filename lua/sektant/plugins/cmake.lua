return {
	{
		"Civitasv/cmake-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },

		init = function()
			pcall(function()
				require("sektant.templates").setup()
			end)
		end,

		cmd = {
			"CMakeGenerate",
			"CMakeBuild",
			"CMakeRun",
			"CMakeDebug",
			"CMakeRunTest",
			"CMakeInstall",
			"CMakeSettings",
			"CMakeSelectBuildType",
			"CMakeSelectBuildTarget",
			"CMakeSelectLaunchTarget",
			"CMakeSelectConfigurePreset",
			"CMakeSelectBuildPreset",
			"CMakeSelectBuildDir",
			"CMakeQuickStart",
		},
		keys = {
			{ "<leader>cg", "<cmd>CMakeGenerate<cr>", desc = "CMake: Generate" },
			{ "<leader>cb", "<cmd>CMakeBuild<cr>", desc = "CMake: Build" },
			{ "<leader>cr", "<cmd>CMakeRun<cr>", desc = "CMake: Run" },
			{ "<leader>ct", "<cmd>CMakeRunTest<cr>", desc = "CMake: Run Tests" },
			{ "<leader>cd", "<cmd>CMakeDebug<cr>", desc = "CMake: Debug" },
			{ "<leader>ci", "<cmd>CMakeInstall<cr>", desc = "CMake: Install" },
			{ "<leader>cs", "<cmd>CMakeSettings<cr>", desc = "CMake: Settings" },
			{ "<leader>ct", "<cmd>CMakeSelectBuildTarget<cr>", desc = "CMake: Select build target" },
			{ "<leader>cl", "<cmd>CMakeSelectLaunchTarget<cr>", desc = "CMake: Select launch target" },
			{ "<leader>cT", "<cmd>CMakeSelectBuildType<cr>", desc = "CMake: Select build type" },
			{ "<leader>cp", "<cmd>CMakeSelectConfigurePreset<cr>", desc = "CMake: Select configure preset" },
			{ "<leader>cP", "<cmd>CMakeSelectBuildPreset<cr>", desc = "CMake: Select build preset" },
			{ "<leader>cD", "<cmd>CMakeSelectBuildDir<cr>", desc = "CMake: Select build dir" },
			{ "<leader>cq", "<cmd>CMakeQuickStart<cr>", desc = "CMake: Quick Start" },
		},

		config = function()
			local osys = require("cmake-tools.osys")
			local uv = vim.uv or vim.loop

			require("cmake-tools").setup({
				cmake_command = "cmake",
				ctest_command = "ctest",

				cmake_use_preset = false,

				cmake_regenerate_on_save = true,

				-- generate compile_commands.json for clangd:
				cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1 -G Ninja" },
				cmake_build_options = {},

				cmake_build_directory = function()
					if osys.iswin32 then
						return "build\\${variant:buildType}"
					end
					return "build/${variant:buildType}"
				end,

				cmake_compile_commands_options = {
					action = "soft_link", -- soft_link | copy | lsp | none
					target = uv.cwd(),
				},

				cmake_dap_configuration = {
					name = "CMake Debug",
					type = "codelldb",
					request = "launch",
					stopOnEntry = false,
					runInTerminal = true,
					console = "integratedTerminal",
				},

				cmake_executor = {
					name = "quickfix",
					opts = {},
				},

				cmake_runner = { -- runner to use
					name = "terminal", -- name of the runner
					opts = {}, -- the options the runner will get, possible values depend on the runner type. See `default_opts` for possible values.
					default_opts = { -- a list of default and possible values for runners
						quickfix = {
							show = "always", -- "always", "only_on_error"
							position = "belowright", -- "bottom", "top"
							size = 10,
							encoding = "utf-8",
							auto_close_when_success = true, -- typically, you can use it with the "always" option; it will auto-close the quickfix buffer if the execution is successful.
						},
						toggleterm = {
							direction = "float", -- 'vertical' | 'horizontal' | 'tab' | 'float'
							close_on_exit = false, -- whether close the terminal when exit
							auto_scroll = true, -- whether auto scroll to the bottom
							singleton = true, -- single instance, autocloses the opened one, if present
						},
						overseer = {
							new_task_opts = {
								strategy = {
									"toggleterm",
									direction = "horizontal",
									autos_croll = true,
									quit_on_exit = "success",
								},
							}, -- options to pass into the `overseer.new_task` command
							on_new_task = function(task) end, -- a function that gets overseer.Task when it is created, before calling `task:start`
						},
						terminal = {
							name = "Main Terminal",
							prefix_name = "[CMakeTools]: ", -- This must be included and must be unique, otherwise the terminals will not work. Do not use a simple spacebar " ", or any generic name
							split_direction = "horizontal", -- "horizontal", "vertical"
							split_size = 11,

							-- Window handling
							single_terminal_per_instance = true, -- Single viewport, multiple windows
							single_terminal_per_tab = true, -- Single viewport per tab
							keep_terminal_static_location = true, -- Static location of the viewport if avialable
							auto_resize = true, -- Resize the terminal if it already exists

							-- Running Tasks
							start_insert = false, -- If you want to enter terminal with :startinsert upon using :CMakeRun
							focus = false, -- Focus on terminal when cmake task is launched.
							do_not_add_newline = false, -- Do not hit enter on the command inserted when using :CMakeRun, allowing a chance to review or modify the command before hitting enter.
							use_shell_alias = false, -- Hide the verbose command wrapper by using a shell alias, showing only the program's output (currently not supported on Windows)
						},
					},
				},
				cmake_notifications = {
					runner = { enabled = true },
					executor = { enabled = true },
					spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }, -- icons used for progress display
					refresh_rate_ms = 100, -- how often to iterate icons
				},
				cmake_virtual_text_support = true, -- Show the target related to current file using virtual text (at right corner)
				cmake_use_scratch_buffer = false, -- A buffer that shows what cmake-tools has done
			})
		end,
	},
}
