-- =============================================================================
--  GLOBALS
-- =============================================================================
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
vim.opt.showtabline = 4
vim.opt.smartindent = true
vim.opt.ignorecase = true

vim.opt.undofile = true

vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })

vim.cmd([[set noswapfile]])
vim.cmd([[set mouse=]])

vim.cmd([[set completeopt+=menuone,noselect,popup]])

vim.cmd([[hi @lsp.type.number gui=italic]])

local default_color = "doom-one"

-- =============================================================================
--  PLUGINS
-- =============================================================================
vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
	{ src = "https://github.com/NTBBloodbath/doom-one.nvim" },
	{ src = "https://github.com/m4xshen/autoclose.nvim" },
	{ src = "https://github.com/rainglow/vim" },
	{ src = "https://github.com/xiyaowong/transparent.nvim" },
	{ src = "https://github.com/Mofiqul/vscode.nvim" },
	{ src = "https://github.com/elvessousa/sobrio" },
	{ src = "https://github.com/NLKNguyen/papercolor-theme" },
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

vim.keymap.set("n", "<leader>pc", pack_clean)

-- =============================================================================
-- PLUGINS SETUP
-- =============================================================================

require("luasnip").setup({ enable_autosnippets = true })
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })

require("autoclose").setup()
require("nvim-treesitter").setup({
	ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "python", "cpp" },
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})
local configs = require("nvim-treesitter")

configs.setup({
	ensure_installed = {
		"python",
		"cpp",
		"c",
		"proto",
		"markdown",
		"dockerfile",
		"starlark",
		"bash",
		"javascript",
		"lua",
	},
	sync_install = false,
	highlight = { enable = true },
	indent = { enable = false },
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
		"codelldb", -- C/C++
		"cmake-language-server",
		"marksman",
		"cmakelang", -- CMake
		"stylua", -- Lua
		"pyright",
		"ruff",
		"black", -- Python
		"jdtls", -- Java
	},
	auto_update = true,
	run_on_start = true,
})

require("mason-lspconfig").setup({
	ensure_installed = {},
	handlers = {
		function(server_name)
			require("lspconfig")[server_name].setup({})
		end,
	},
})

-- Add color to cursor
vim.g.doom_one_cursor_coloring = false
-- Set :terminal colors
vim.g.doom_one_terminal_colors = false
-- Enable italic comments
vim.g.doom_one_italic_comments = false
-- Enable TS support
vim.g.doom_one_enable_treesitter = true
-- Color whole diagnostic text or only underline
vim.g.doom_one_diagnostics_text_color = false
-- Enable transparent background
vim.g.doom_one_transparent_background = true

require("telescope").setup({
	pickers = {
		colorscheme = {
			enable_preview = true,
		},
	},
	defaults = {
		preview = {
			treesitter = false,
		},
		color_devicons = true,
		sorting_strategy = "ascending",
		borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
		path_displays = { "smart" },
		layout_strategy = "horizontal",
		layout_config = {
			height = 100,
			width = 400,
			prompt_position = "top",
			preview_cutoff = 40,
			preview_width = 0.6,
		},
	},
})

require("actions-preview").setup({
	backend = { "telescope" },
	extensions = { "env" },
	telescope = vim.tbl_extend("force", require("telescope.themes").get_dropdown(), {}),
})

vim.diagnostic.config({
	float = { border = "solid" },
})

-- =============================================================================
-- LSP SETUP & AUTOCOMMANDS
-- =============================================================================
local function find_cmake_root(path)
	local res = vim.fs.find("CMakeLists.txt", {
		upward = true,
		path = vim.fs.dirname(path),
	})
	return res[1] and vim.fs.dirname(res[1]) or nil
end

local function sync_project()
	local buf = vim.api.nvim_get_current_buf()
	local name = vim.api.nvim_buf_get_name(buf)
	if name == "" then
		return
	end

	local root = find_cmake_root(name)
	if not root then
		return
	end

	-- Neovim cwd
	vim.cmd("lcd " .. root)

	-- Push to tmux (force + silent)
	vim.fn.system({
		"tmux",
		"set-option",
		"-gq",
		"@project_root",
		root,
	})
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost" }, { callback = sync_project })

vim.lsp.enable({
	"cssls",
	"clangd",
	"glsl_analyzer",
	"marksman",
	"hlint",
	"jdtls",
	"cmake-language-server",
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
-- MISC
-- =============================================================================

local color_group = vim.api.nvim_create_augroup("colors", { clear = true })

vim.cmd("colorscheme " .. default_color)

vim.api.nvim_create_autocmd("TabEnter", {
	group = color_group,
	callback = function(args)
		if vim.t.color then
			vim.cmd("colorscheme " .. vim.t.color)
		else
			vim.cmd("colorscheme " .. default_color)
		end
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.cmd("TransparentEnable")
	end,
})

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

-- =============================================================================
-- KEYMAPPINGS
-- =============================================================================
local map = vim.keymap.set
local ls = require("luasnip")
local builtin = require("telescope.builtin")

map({ "n", "x" }, "<leader>y", '"+y') -- Clipboard
map({ "n", "x" }, "<leader>d", '"+d') -- Clipboard
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

map({ "n" }, "<leader>e", "<cmd>Yazi<CR>")
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

map("n", "<leader>f", builtin.find_files, { desc = "Find files" })
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
-- STATUSLINE
-- =============================================================================
_G.get_status_mode = function()
	local modes = {
		["n"] = "N",
		["no"] = "N",
		["v"] = "V",
		["V"] = "V-L",
		["\22"] = "V-B",
		["s"] = "S",
		["S"] = "S-L",
		["\19"] = "S-B",
		["i"] = "I",
		["ic"] = "I",
		["R"] = "R",
		["Rv"] = "V-R",
		["c"] = "CMD",
		["cv"] = "V-EX",
		["ce"] = "EX",
		["r"] = "P",
		["rm"] = "M",
		["r?"] = "CFM",
		["!"] = "SH",
		["t"] = "TERM",
	}
	local current_mode = vim.api.nvim_get_mode().mode
	return string.format("[%s]", modes[current_mode] or current_mode:upper())
end

local statusline = {
	" %{v:lua.get_status_mode()} ",
	"%t", -- Filename
	"%r", -- Readonly
	"%m", -- Modified
	"%=", -- Spacer
	"%{&filetype}",
	" %2p%%", -- Percentage
	" %3l:%-2c ", -- Line:Col
}
vim.o.statusline = table.concat(statusline, "")
