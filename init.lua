vim.g.mapleader = " "
vim.opt.guicursor = ""
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.winborder = "solid"
vim.opt.cmdheight = 1
vim.opt.showmode = true
vim.opt.signcolumn = "number"
vim.opt.cursorcolumn = false
vim.opt.wrap = false
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.showtabline = 1
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.undofile = true

vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })

vim.cmd([[set noswapfile]])
vim.cmd([[set mouse=]])
vim.cmd([[set completeopt+=menuone,noselect,popup]])
vim.cmd([[hi @lsp.type.number gui=italic]])

local default_color = "naysayer"

-- =============================================================================
-- PLUGINS
-- =============================================================================
vim.pack.add({
	{ src = "https://github.com/dgrco/deepwater.nvim" },
	-- { src = "https://github.com/sektant1/naysayer-colors.nvim" },
	{ src = "https://github.com/RostislavArts/naysayer.nvim" },
	{ src = "https://github.com/norcalli/nvim-colorizer.lua" },
	{ src = "https://github.com/uhs-robert/oasis.nvim" },
	{ src = "https://github.com/DeviusVim/deviuspro.nvim" },
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
	{ src = "https://github.com/NTBBloodbath/doom-one.nvim" },
	{ src = "https://github.com/m4xshen/autoclose.nvim" },
	{ src = "https://github.com/rainglow/vim" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	-- { src = "https://github.com/skuzniar/cppgen.nvim" },
	{ src = "https://github.com/Mofiqul/vscode.nvim" },
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },
	{ src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
	{ src = "https://github.com/darkvoid-theme/darkvoid.nvim" },
	{ src = "https://github.com/nyoom-engineering/oxocarbon.nvim" },
	{ src = "https://github.com/michaeljsmith/vim-colours-dark-lord" },
	{ src = "https://github.com/williamboman/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
	{ src = "https://github.com/chentoast/marks.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/mikavilpas/yazi.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/aznhe21/actions-preview.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim", version = "0.1.8" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/LinArcX/telescope-env.nvim" },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
})

-- =============================================================================
-- HELPERS
-- =============================================================================
local function pack_clean()
	local active_plugins = {}
	local unused_plugins = {}

	for _, plugin in ipairs(vim.pack.get()) do
		active_plugins[plugin.spec.name] = plugin.active
	end

	for _, plugin in ipairs(vim.pack.get()) do
		if not active_plugins[plugin.spec.name] then
			table.insert(unused_plugins, plugin.spec.name)
		end
	end

	if #unused_plugins == 0 then
		print("No unused plugins.")
		return
	end

	local choice = vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2)
	if choice == 1 then
		vim.pack.del(unused_plugins)
	end
end

local function cmake_root()
	local buf = vim.api.nvim_get_current_buf()
	local name = vim.api.nvim_buf_get_name(buf)
	if name == "" then
		return nil
	end

	local res = vim.fs.find("CMakeLists.txt", {
		upward = true,
		path = vim.fs.dirname(name),
	})
	return res[1] and vim.fs.dirname(res[1]) or nil
end

local function run(cmd)
	vim.cmd("write")
	vim.cmd("botright split | terminal " .. cmd)
	vim.cmd("startinsert")
end

local function cmake_configure()
	local root = cmake_root()
	if not root then
		vim.notify("CMakeLists.txt not found", vim.log.levels.ERROR)
		return
	end
	run(
		"cd "
			.. root
			.. " && cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug"
			.. " && (ln -sf build/compile_commands.json compile_commands.json || true)"
	)
end

local function cmake_build()
	local root = cmake_root()
	if not root then
		vim.notify("CMakeLists.txt not found", vim.log.levels.ERROR)
		return
	end
	run("cd " .. root .. " && cmake --build build --parallel")
end

local function cmake_build_tests()
	local root = cmake_root()
	if not root then
		vim.notify("CMakeLists.txt not found", vim.log.levels.ERROR)
		return
	end

	run("cd " .. root .. " && cmake --build build --target tests --parallel")
end

local function cmake_rebuild()
	local root = cmake_root()
	if not root then
		vim.notify("CMakeLists.txt not found", vim.log.levels.ERROR)
		return
	end
	run(
		"cd "
			.. root
			.. " && rm -rf build"
			.. " && cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug"
			.. " && (ln -sf build/compile_commands.json compile_commands.json || true)"
			.. " && cmake --build build --parallel"
	)
end
local function write_file_if_missing(path, lines)
	if vim.fn.filereadable(path) == 1 then
		return false
	end
	vim.fn.writefile(lines, path)
	return true
end

local function cmake_template_basic(project)
	return {
		"cmake_minimum_required(VERSION 3.16)",
		"",
		("project(%s LANGUAGES C CXX)"):format(project),
		"",
		"set(CMAKE_C_STANDARD 17)",
		"set(CMAKE_CXX_STANDARD 20)",
		"set(CMAKE_CXX_STANDARD_REQUIRED ON)",
		"",
		"set(CMAKE_EXPORT_COMPILE_COMMANDS ON)",
		"",
		"if(NOT CMAKE_BUILD_TYPE)",
		'  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)',
		"endif()",
		"",
		"file(GLOB_RECURSE SRC",
		"  src/*.c",
		"  src/*.cpp",
		")",
		"",
		"add_executable(${PROJECT_NAME} ${SRC})",
		"",
		"target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -Wpedantic)",
	}
end

local function cmake_template_glfw_opengl(project)
	return {
		"cmake_minimum_required(VERSION 3.16)",
		"",
		("project(%s LANGUAGES C CXX)"):format(project),
		"",
		"set(CMAKE_C_STANDARD 17)",
		"set(CMAKE_CXX_STANDARD 20)",
		"set(CMAKE_CXX_STANDARD_REQUIRED ON)",
		"",
		"set(CMAKE_EXPORT_COMPILE_COMMANDS ON)",
		"",
		"if(NOT CMAKE_BUILD_TYPE)",
		'  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)',
		"endif()",
		"",
		"file(GLOB_RECURSE SRC",
		"  src/*.c",
		"  src/*.cpp",
		")",
		"",
		"add_executable(${PROJECT_NAME} ${SRC})",
		"",
		"find_package(OpenGL REQUIRED)",
		"find_package(glfw3 REQUIRED)",
		"",
		"target_link_libraries(${PROJECT_NAME} PRIVATE OpenGL::GL glfw)",
		"target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -Wpedantic)",
		"",
		"# Se você usa GLAD/GLEW, adicione aqui include dirs e sources da lib/loader.",
	}
end

local function generate_cmakelists()
	local cwd = vim.fn.getcwd()
	local path = cwd .. "/CMakeLists.txt"
	local project = vim.fn.fnamemodify(cwd, ":t")

	if vim.fn.filereadable(path) == 1 then
		vim.notify("CMakeLists.txt já existe", vim.log.levels.WARN)
		return
	end

	local choices = {
		"Basic (C/C++)",
		"GLFW + OpenGL (system packages)",
	}

	vim.ui.select(choices, { prompt = "CMake template" }, function(choice)
		if not choice then
			return
		end

		local lines = nil
		if choice == choices[1] then
			lines = cmake_template_basic(project)
		else
			lines = cmake_template_glfw_opengl(project)
		end

		vim.fn.writefile(lines, path)
		vim.notify("CMakeLists.txt criado", vim.log.levels.INFO)
		vim.cmd("edit CMakeLists.txt")
	end)
end

-- =============================================================================
-- PLUGIN SETUP
-- =============================================================================
require("luasnip").setup({ enable_autosnippets = true })
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })

require("autoclose").setup()

local configs = require("nvim-treesitter")
configs.setup({
	ensure_installed = {
		"python",
		"cpp",
		"c",
		"cmake",
		"proto",
		"glsl",
		"markdown",
		"markdown_inline",
		"dockerfile",
		"toml",
		"bash",
		"javascript",
		"lua",
	},
	auto_install = true,
	sync_install = true,
	highlight = { enable = true },
	indent = { enable = false },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<CR>",
			node_incremental = "<CR>",
			scope_incremental = "<BS>",
			node_decremental = "<TAB>",
		},
	},
})

require("marks").setup({
	builtin_marks = { "<", ">", "^" },
	refresh_interval = 250,
	sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
	excluded_filetypes = {},
	excluded_buftypes = {},
	mappings = {},
})

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

require("yazi").setup({
	open_for_directories = true,
	floating_window_scaling_factor = 0.8,
	keymaps = { show_help = "<f1>" },
})

require("mason").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		"clangd",
		"clang-format",
		"codelldb",
		"cmake-language-server",
		"marksman",
		"cmakelang",
		"stylua",
		"pyright",
		"glsl_analyzer",
		"ruff",
		"black",
		"jdtls",
	},
	auto_update = true,
	run_on_start = true,
})

local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

require("mason-lspconfig").setup({
	ensure_installed = {},
	handlers = {
		function(server_name)
			if server_name == "clangd" then
				lspconfig.clangd.setup({
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--completion-style=detailed",
						"--header-insertion=never",
						"--compile-commands-dir=build",
					},
					root_dir = util.root_pattern("compile_commands.json", "CMakeLists.txt", ".git"),
				})
				return
			end
			lspconfig[server_name].setup({})
		end,
	},
})
require("telescope").setup({
	pickers = {
		colorscheme = { enable_preview = true, previewer = true },
	},
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

require("actions-preview").setup({
	backend = { "telescope" },
	extensions = { "env" },
	telescope = vim.tbl_extend("force", require("telescope.themes").get_dropdown(), {}),
})

vim.diagnostic.config({ float = { border = "solid" } })

-- =============================================================================
-- DAP (C/C++ via codelldb)
-- =============================================================================
local dap_ok, dap = pcall(require, "dap")
if not dap_ok then
	return
end

local dapui_ok, dapui = pcall(require, "dapui")
if dapui_ok then
	dapui.setup()
end

pcall(function()
	require("nvim-dap-virtual-text").setup({ commented = true })
end)

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "", numhl = "" })

local function codelldb_path()
	local mason = vim.fn.stdpath("data") .. "/mason"
	local ext = (vim.loop.os_uname().sysname:match("Windows")) and ".exe" or ""
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

local function is_file(path)
	local stat = vim.loop.fs_stat(path)
	return stat and stat.type == "file"
end

local function list_build_executables(root)
	local build = root .. "/build"
	local paths = vim.fn.globpath(build, "**/*", false, true)
	local out = {}

	for _, p in ipairs(paths) do
		if is_file(p) and vim.fn.executable(p) == 1 then
			-- filtra alguns arquivos comuns que não são “app”
			if not p:match("%.so$") and not p:match("%.a$") and not p:match("%.o$") then
				table.insert(out, p)
			end
		end
	end

	table.sort(out)
	return out
end

local function pick_executable()
	local root = cmake_root() or vim.fn.getcwd()
	local exes = list_build_executables(root)

	if #exes == 0 then
		local guess = root .. "/build/"
		return vim.fn.input("Executable: ", guess, "file")
	end

	local choice = nil
	vim.ui.select(exes, { prompt = "Pick executable" }, function(item)
		choice = item
	end)

	if not choice then
		choice = exes[#exes]
	end

	vim.g.last_cmake_exe = choice
	return choice
end

dap.configurations.cpp = {
	{
		name = "Launch (codelldb)",
		type = "codelldb",
		request = "launch",
		program = pick_executable,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
	},
	{
		name = "Launch (codelldb, terminal)",
		type = "codelldb",
		request = "launch",
		program = pick_executable,
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

if dapui_ok then
	dap.listeners.after.event_initialized["dapui_config"] = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated["dapui_config"] = function()
		dapui.close()
	end
	dap.listeners.before.event_exited["dapui_config"] = function()
		dapui.close()
	end
end

-- =============================================================================
-- LSP
-- =============================================================================
vim.lsp.enable({
	"cssls",
	"clangd",
	"glsl_analyzer",
	"marksman",
	"hlint",
	"jdtls",
	"cmake-language-server",
})

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
				table.insert(chars, string.char(i))
			end
			client.server_capabilities.completionProvider.triggerCharacters = chars
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
	end,
})

local format_on_save_group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	group = format_on_save_group,
	pattern = "*",
	callback = function(args)
		vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 1500 })
	end,
})

-- =============================================================================
-- AUTOCOMMANDS
-- =============================================================================
vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "*.jsx,*.tsx",
	group = vim.api.nvim_create_augroup("TS", { clear = true }),
	callback = function()
		vim.cmd([[set filetype=typescriptreact]])
	end,
})

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

vim.api.nvim_create_user_command("CheckBuildTools", function()
	local function ok(bin)
		return vim.fn.executable(bin) == 1
	end

	local missing = {}
	local tools = { "cmake", "ninja", "gdb", "lldb" }
	for _, t in ipairs(tools) do
		if not ok(t) then
			table.insert(missing, t)
		end
	end

	if #missing == 0 then
		vim.notify("Build/debug tools OK: cmake/ninja/gdb/lldb", vim.log.levels.INFO)
	else
		vim.notify("Missing tools: " .. table.concat(missing, ", "), vim.log.levels.WARN)
	end
end, {})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.vert", "*.frag", "*.geom", "*.comp", "*.tesc", "*.tese", "*.glsl" },
	callback = function()
		vim.bo.filetype = "glsl"
	end,
})

-- =============================================================================
-- KEYMAPS
-- =============================================================================
local map = vim.keymap.set
local ls = require("luasnip")
local builtin = require("telescope.builtin")
local opts = { noremap = true, silent = true }

map("n", "<leader>pc", pack_clean)

map("n", "<leader>cc", cmake_configure, { desc = "CMake configure (Debug)" })
map("n", "<leader>cb", cmake_build, { desc = "CMake build" })
map("n", "<leader>ct", cmake_build_tests, { desc = "CMake build tests target" })
map("n", "<leader>cr", cmake_rebuild, { desc = "CMake rebuild (clean)" })
map("n", "<leader>cg", generate_cmakelists, { desc = "Generate CMakeLists.txt template" })

map("n", "<leader>bb", function()
	dap.toggle_breakpoint()
end, { desc = "DAP breakpoint" })
map("n", "<leader>bB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP conditional breakpoint" })
map("n", "<leader>bc", function()
	dap.continue()
end, { desc = "DAP continue" })
map("n", "<leader>bn", function()
	dap.step_over()
end, { desc = "DAP step over" })
map("n", "<leader>bi", function()
	dap.step_into()
end, { desc = "DAP step into" })
map("n", "<leader>bo", function()
	dap.step_out()
end, { desc = "DAP step out" })
map("n", "<leader>br", function()
	dap.repl.open()
end, { desc = "DAP repl" })
map("n", "<leader>bR", function()
	local exe = vim.g.last_cmake_exe
	if not exe or exe == "" then
		exe = pick_executable()
	end
	run(exe)
end, { desc = "Run last executable" })

map("n", "<leader>bl", function()
	cmake_build()
end, { desc = "Build (then run manually with <leader>rr)" })
if dapui_ok then
	map("n", "<leader>bu", function()
		dapui.toggle()
	end, { desc = "DAP UI toggle" })
end

map("n", "<esc>", ":noh<cr>", opts)
map({ "n", "x" }, "<leader>y", '"+y')
map({ "n", "x" }, "<leader>D", '"+d')
map({ "v", "x", "n" }, "<C-y>", '"+y', { desc = "System clipboard yank." })

map("n", "<leader>w", "<Cmd>update<CR>", { desc = "Write buffer" })
map("n", "<leader>q", "<Cmd>:quit<CR>", { desc = "Quit buffer" })
map("n", "<leader>Q", "<Cmd>:wqa<CR>", { desc = "Quit all and write" })
map("n", "<leader>O", "<Cmd>restart<CR>", { desc = "Restart vim" })
map("n", "<leader>o", "<Cmd>source %<CR>", { desc = "Source current file" })

map({ "n", "v", "x" }, "<leader>v", "<Cmd>edit $MYVIMRC<CR>", { desc = "Edit init.lua" })
map({ "n", "v", "x" }, "<leader>z", "<Cmd>e ~/.bashrc<CR>", { desc = "Edit .bashrc" })

map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move line Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move line Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line Down (Insert)" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line Up (Insert)" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move block Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move block Up" })

map("n", "o", "<cmd>:call append(line('.'), '')<CR>")
map("n", "O", "<cmd>:call append(line('.')-1, '')<CR>")
map("n", "Y", "_y$", { desc = "Yank to end of line" })
map("n", "D", "_d$", { desc = "Delete to end of line" })
map("v", "H", "^", { silent = true, desc = "Start of line" })
map("v", "L", "$", { silent = true, desc = "End of line" })
map("x", "<leader>r", [["_dP]], { desc = "Replace Selection with Buffer" })

map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

map({ "n", "v", "x" }, ";", ":", { desc = "Command mode" })
map({ "n", "v", "x" }, ":", ";", { desc = "Repeat last f/t" })
map({ "n", "v", "x" }, "<C-s>", [[:s/\V]], { desc = "Substitute in selection" })
map({ "n", "v", "x" }, "<leader>n", ":norm ", { desc = "Run normal command" })

vim.keymap.set("n", "<M-b>", function()
	vim.fn.system({ "tmux", "send-keys", "M-b" })
end)
vim.keymap.set("n", "<M-r>", function()
	vim.fn.system({ "tmux", "send-keys", "M-r" })
end)
vim.keymap.set("n", "<M-d>", function()
	vim.fn.system({ "tmux", "send-keys", "M-d" })
end)
vim.keymap.set("n", "<M-t>", function()
	vim.fn.system({ "tmux", "send-keys", "M-t" })
end)

map({ "i", "s" }, "<C-e>", function()
	ls.expand_or_jump(1)
end, { silent = true })
map({ "i", "s" }, "<C-J>", function()
	ls.jump(1)
end, { silent = true })
map({ "i", "s" }, "<C-K>", function()
	ls.jump(-1)
end, { silent = true })

vim.keymap.set("i", "<Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-y>" or "<Tab>"
end, { expr = true, silent = true, desc = "Accept completion or Insert Tab" })

map({ "n", "t" }, "<Leader>t", "<Cmd>tabnew<CR>")
map({ "n", "t" }, "<Leader>x", "<Cmd>tabclose<CR>")
for i = 1, 8 do
	map({ "n", "t" }, "<Leader>" .. i, "<Cmd>tabnext " .. i .. "<CR>")
end

map("n", "<leader>e", "<cmd>Yazi<CR>")
map("n", "<C-f>", "<Cmd>Open .<CR>", { desc = "Open in OS Finder" })
map("n", "<leader>a", ":edit #<CR>", { desc = "Edit alternate file" })

map({ "n", "v", "x" }, "<leader>lf", vim.lsp.buf.format, { desc = "Format buffer" })
map("n", "<C-q>", ":copen<CR>", { silent = true })
map("n", "<leader>d", function()
	vim.diagnostic.open_float()
end, { desc = "Diagnostic float" })

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

vim.cmd([[
    nnoremap g= g+|
    nnoremap gK @='ddkPJ'<cr>
    xnoremap gK <esc><cmd>keeppatterns '<,'>-global/$/normal! ddpkJ<cr>
    noremap! <c-r><c-d> <c-r>=strftime('%F')<cr>
    noremap! <c-r><c-t> <c-r>=strftime('%T')<cr>
    noremap! <c-r><c-f> <c-r>=expand('%:t')<cr>
    noremap! <c-r><c-p> <c-r>=expand('%:p')<cr>
    xnoremap <expr> . "<esc><cmd>'<,'>normal! ".v:count1.'.<cr>'
]])

map("n", "<M-n>", "<cmd>resize +2<CR>")
map("n", "<M-e>", "<cmd>resize -2<CR>")
map("n", "<M-i>", "<cmd>vertical resize +5<CR>")
map("n", "<M-m>", "<cmd>vertical resize -5<CR>")

-- =============================================================================
-- UI
-- =============================================================================
vim.cmd("colorscheme " .. default_color)
vim.api.nvim_set_hl(0, "Operator", { fg = "#FFFFFF" })
vim.api.nvim_set_hl(0, "@operator.cpp", { fg = "#FFFFFF", bold = true })
-- vim.api.nvim_set_hl(0, "@symbol.cpp", { fg = "#FFFFFF", bold = true })
vim.cmd("hi Operator guifg=#FFFFFF")
vim.cmd("hi cppOperator guifg=#FFFFFF")

local statusline = {
	"%t",
	"%r",
	"%m",
	"%=",
	"%{&filetype}",
	" %2p%%",
	" %3l:%-2c ",
}
vim.o.statusline = table.concat(statusline, "")
