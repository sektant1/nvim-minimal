vim.cmd([[set mouse=]])
vim.cmd([[set noswapfile]])
vim.opt.guicursor = ""
vim.opt.winborder = "rounded"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.showtabline = 4
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.cursorcolumn = false
vim.opt.ignorecase = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.number = true
vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/elvessousa/sobrio" },
	{ src = "https://github.com/NLKNguyen/papercolor-theme" },
	{ src = "https://github.com/darkvoid-theme/darkvoid.nvim" },
	{ src = "https://github.com/nyoom-engineering/oxocarbon.nvim" },
	{ src = "https://github.com/michaeljsmith/vim-colours-dark-lord" },
	{ src = "https://github.com/williamboman/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
	{ src = "https://github.com/chentoast/marks.nvim" }, -- Gerenciador de "marcas" (bookmarks)
	{ src = "https://github.com/stevearc/oil.nvim" }, -- Gerenciador de arquivos (substituto do netrw)
	{ src = "https://github.com/mikavilpas/yazi.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" }, -- Ícones
	{ src = "https://github.com/aznhe21/actions-preview.nvim" }, -- Preview de code actions
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" }, -- Parser de sintaxe
	{ src = "https://github.com/neovim/nvim-lspconfig" }, -- Configuração base do LSP
	{ src = "https://github.com/mason-org/mason.nvim" }, -- Gerenciador de LSPs e formatters
	{ src = "https://github.com/nvim-telescope/telescope.nvim", version = "0.1.8" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" }, -- Dependência comum (Telescope, etc)
	{ src = "https://github.com/LinArcX/telescope-env.nvim" }, -- Extensão para variáveis de ambiente
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" }, -- Preview para Typst
})

require("marks").setup({
	builtin_marks = { "<", ">", "^" },
	refresh_interval = 250,
	sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
	excluded_filetypes = {},
	excluded_buftypes = {},
	mappings = {},
})

local default_color = "sobrio_ghost_vim"
-- vim.o.background = "dark"

require("mason").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		-- C / C++
		"clangd", -- LSP
		"clang-format", -- Formatter
		"codelldb", -- Debugger (optional, but good to have)
		-- CMake
		"neocmakelsp", -- LSP
		"cmakelang", -- Formatter
		-- Lua
		"stylua", -- Formatter
		-- Python
		"pyright", -- LSP
		"ruff", -- Fast Linter/Formatter
		"black", -- Standard Formatter
		-- Java
		"jdtls", -- LSP
	},
	auto_update = true,
	run_on_start = true,
})

-- Attach Handler: Enables features like completion when LSP starts
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
	end,
})

-- Mason LSP Config: Auto-setup handlers for installed servers
require("mason-lspconfig").setup({
	-- Automatically install LSPs that are missing from the tool-installer list?
	-- We rely on mason-tool-installer for the list, so we keep this minimal.
	ensure_installed = {},
	handlers = {
		-- The default handler: setup any server with default config
		function(server_name)
			require("lspconfig")[server_name].setup({})
		end,

		-- You can add specific handlers for clangd or jdtls here if you need
		-- special compile_commands.json flags or JVM args later.
	},
})

local telescope = require("telescope")
telescope.setup({
	defaults = {
		preview = { treesitter = false }, -- Desliga o preview do treesitter (pode ser lento)
		color_devicons = true,
		sorting_strategy = "ascending",
		borderchars = {
			"─", -- top
			"│", -- right
			"─", -- bottom
			"│", -- left
			"┌", -- top-left
			"┐", -- top-right
			"┘", -- bottom-right
			"└", -- bottom-left
		},
		path_displays = { "smart" },
		layout_config = {
			height = 100,
			width = 400,
			prompt_position = "top",
			preview_cutoff = 40,
		},
	},
})

telescope.load_extension("ui-select")

require("yazi").setup({
	open_for_directories = true,
	floating_window_scaling_factor = 0.8,
	yazi_floating_window_border = "rounded",
	keymaps = { show_help = "<f1>" },
})

require("actions-preview").setup({
	backend = { "telescope" },
	extensions = { "env" },
	telescope = vim.tbl_extend("force", require("telescope.themes").get_dropdown(), {}),
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("my.lsp", {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		-- Verifica se o servidor suporta "completion"
		if client:supports_method("textDocument/completion") then
			-- Opcional: Ativa autocompletion em CADA tecla. Pode ser lento.
			local chars = {}
			for i = 32, 126 do
				table.insert(chars, string.char(i))
			end
			client.server_capabilities.completionProvider.triggerCharacters = chars
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
	end,
})

-- Opções do menu de autocompletar.
vim.cmd([[set completeopt+=menuone,noselect,popup]])

vim.lsp.enable({
	"cssls",
	"clangd",
	"glsl_analyzer",
	"hlint",
	"jdtls",
	"cmake-language-server",
})

require("oil").setup({
	lsp_file_methods = {
		enabled = true,
		timeout_ms = 1000,
		autosave_changes = true,
	},
	columns = {
		"permissions",
		"icon",
	},
	float = {
		max_width = 0.7,
		max_height = 0.6,
		border = "rounded",
	},
})

require("vague").setup({ transparent = true })

require("luasnip").setup({ enable_autosnippets = true })

require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })

local function pack_clean()
	local active_plugins = {}
	local unused_plugins = {}

	-- Constrói uma tabela de plugins ativos
	for _, plugin in ipairs(vim.pack.get()) do
		active_plugins[plugin.spec.name] = plugin.active
	end

	-- Encontra plugins que não estão na lista de ativos
	for _, plugin in ipairs(vim.pack.get()) do
		if not active_plugins[plugin.spec.name] then
			table.insert(unused_plugins, plugin.spec.name)
		end
	end

	if #unused_plugins == 0 then
		print("No unused plugins.")
		return
	end

	-- Pede confirmação antes de remover
	local choice = vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2)
	if choice == 1 then
		vim.pack.del(unused_plugins)
	end
end

vim.keymap.set("n", "<leader>pc", pack_clean)

local color_group = vim.api.nvim_create_augroup("colors", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
	group = color_group,
	callback = function(args)
		if vim.t.color then
			vim.cmd("colorscheme " .. vim.t.color)
		else
			vim.cmd("colorscheme " .. default_color)
		end
	end,
})

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

local ls = require("luasnip")
local builtin = require("telescope.builtin")
local map = vim.keymap.set
local current = 1

map("n", "<leader>b", "<cmd>make<CR>")
map("n", "<leader>B", "<cmd>make run<CR>")
map("n", "<leader>cc", "<cmd>!cmake -S . -B build<CR>")
map("n", "<leader>cb", "<cmd>!cmake --build build<CR>")
map("n", "<leader>ct", "<cmd>cd build && ctest<CR>")

map("i", "<Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-y>" or "<Tab>"
end, { expr = true, desc = "Accept completion" })

vim.g.mapleader = " "

map({ "n", "x" }, "<leader>y", '"+y')
map({ "n", "x" }, "<leader>d", '"+d')

map({ "i", "s" }, "<C-e>", function()
	ls.expand_or_jump(1)
end, { silent = true })
map({ "i", "s" }, "<C-J>", function()
	ls.jump(1)
end, { silent = true })
map({ "i", "s" }, "<C-K>", function()
	ls.jump(-1)
end, { silent = true })

map({ "n", "t" }, "<Leader>t", "<Cmd>tabnew<CR>")
map({ "n", "t" }, "<Leader>x", "<Cmd>tabclose<CR>")

vim.cmd([[
	nnoremap g= g+|
	" Junta linhas ao contrário (ddkPJ)
	nnoremap gK @='ddkPJ'<cr>|
	xnoremap gK <esc><cmd>keeppatterns '<,'>-global/$/normal! ddpkJ<cr>
	" Insere data/hora (modo Insert)
	noremap! <c-r><c-d> <c-r>=strftime('%F')<cr>
	noremap! <c-r><c-t> <c-r>=strftime('%T')<cr>
	" Insere nome/caminho do arquivo (modo Insert)
	noremap! <c-r><c-f> <c-r>=expand('%:t')<cr>
	noremap! <c-r><c-p> <c-r>=expand('%:p')<cr>
	" Repete o comando '.' em modo visual
	xnoremap <expr> . "<esc><cmd>'<,'>normal! ".v:count1.'.<cr>'
]])

-- Cria atalhos <Leader>1, <Leader>2, ... <Leader>8
for i = 1, 8 do
	map({ "n", "t" }, "<Leader>" .. i, "<Cmd>tabnext " .. i .. "<CR>")
end

map({ "n", "v", "x" }, ";", ":", { desc = "Self explanatory" })
map({ "n", "v", "x" }, ":", ";", { desc = "Self explanatory" })
map({ "n", "v", "x" }, "<leader>v", "<Cmd>edit $MYVIMRC<CR>", { desc = "Edit " .. vim.fn.expand("$MYVIMRC") })
map({ "n", "v", "x" }, "<leader>z", "<Cmd>e ~/.bashrc<CR>", { desc = "Edit .bashrc" })
map({ "n", "v", "x" }, "<leader>n", ":norm ", { desc = "ENTER NORM COMMAND." })
map({ "n", "v", "x" }, "<leader>o", "<Cmd>source %<CR>", { desc = "Source " .. vim.fn.expand("$MYVIMRC") })
map({ "n", "v", "x" }, "<leader>O", "<Cmd>restart<CR>", { desc = "Restart vim." })
map({ "n", "v", "x" }, "<C-s>", [[:s/\V]], { desc = "Enter substitue mode in selection" })
map({ "v", "x", "n" }, "<C-y>", '"+y', { desc = "System clipboard yank." })
map({ "n", "v", "x" }, "<leader>lf", vim.lsp.buf.format, { desc = "Format current buffer" })

function git_files()
	builtin.find_files({ no_ignore = true })
end

map({ "n" }, "<leader>f", builtin.find_files, { desc = "Telescope live grep" }) -- 'live grep' no desc? Deveria ser 'find files'
map({ "n" }, "<leader>g", builtin.live_grep) -- Pesquisa texto (live grep)
map({ "n" }, "<leader>sg", git_files) -- Arquivos (incluindo ignorados pelo git)
map({ "n" }, "<leader>sb", builtin.buffers) -- Buffers abertos
map({ "n" }, "<leader>si", builtin.grep_string) -- Pesquisa palavra sob cursor
map({ "n" }, "<leader>so", builtin.oldfiles) -- Arquivos recentes
map({ "n" }, "<leader>sh", builtin.help_tags) -- Ajuda
map({ "n" }, "<leader>sm", builtin.man_pages) -- Man pages
map({ "n" }, "<leader>sr", builtin.lsp_references) -- Referências LSP
map({ "n" }, "<leader>sd", builtin.diagnostics) -- Diagnósticos LSP
map({ "n" }, "<leader>si", builtin.lsp_implementations) -- Implementações LSP
map({ "n" }, "<leader>sT", builtin.lsp_type_definitions) -- Definições de tipo LSP
map({ "n" }, "<leader>ss", builtin.current_buffer_fuzzy_find) -- Pesquisa no buffer atual
map({ "n" }, "<leader>st", builtin.builtin) -- Builtins do Telescope
map({ "n" }, "<leader>sc", builtin.git_bcommits) -- Commits do buffer
map({ "n" }, "<leader>sk", builtin.keymaps) -- Atalhos
map({ "n" }, "<leader>se", "<cmd>Telescope env<cr>") -- Variáveis de ambiente
map({ "n" }, "<leader>sa", require("actions-preview").code_actions) -- Code actions
map({ "n" }, "<M-n>", "<cmd>resize +2<CR>")
map({ "n" }, "<M-e>", "<cmd>resize -2<CR>")
map({ "n" }, "<M-i>", "<cmd>vertical resize +5<CR>")
map({ "n" }, "<M-m>", "<cmd>vertical resize -5<CR>")

vim.keymap.set("n", "<leader>d", function()
	vim.diagnostic.open_float()
end, { desc = "Open diagnostic float" })

-- map({ "n" }, "<leader>e", "<cmd>Oil<CR>") -- Abrir Oil (gerenciador de arquivos)
map({ "n" }, "<leader>e", "<cmd>Yazi<CR>")
-- map({ "n" }, "<leader>c", "1z=")          -- Sugestão de correção (LSP)
map({ "n" }, "<C-q>", ":copen<CR>", { silent = true })
map({ "n" }, "<leader>w", "<Cmd>update<CR>", { desc = "Write the current buffer." })
map({ "n" }, "<leader>q", "<Cmd>:quit<CR>", { desc = "Quit the current buffer." })
map({ "n" }, "<leader>Q", "<Cmd>:wqa<CR>", { desc = "Quit all buffers and write." })
map({ "n" }, "<C-f>", "<Cmd>Open .<CR>", { desc = "Open current directory in Finder." }) -- Abrir no Finder
map({ "n" }, "<leader>a", ":edit #<CR>", { desc = "Open current directory in Finder." }) -- Descrição errada? Isso edita o arquivo alternativo.
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("x", "<leader>r", [["_dP]], { desc = "Replace Selection with Buffer" })
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })
map("n", "o", "<cmd>:call append(line('.'), '')<CR>")
map("n", "O", "<cmd>:call append(line('.')-1, '')<CR>")
map("n", "Y", "_y$", { desc = "Yank to end of line" })
map("n", "D", "_d$", { desc = "Delete to end of line" })
map("v", "H", "^", { silent = true, desc = "Start of line" })
map("v", "L", "$", { silent = true, desc = "End of line" })

vim.keymap.set("i", "<Tab>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-y>"
	end
	return "<Tab>"
end, { expr = true, silent = true, desc = "Accept completion or Insert Tab" })

vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "*.jsx,*.tsx",
	group = vim.api.nvim_create_augroup("TS", { clear = true }),
	callback = function()
		vim.cmd([[set filetype=typescriptreact]])
	end,
})

vim.cmd("colorscheme " .. default_color)

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

local format_on_save_group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = format_on_save_group,
	pattern = "*", -- Executa em todos os arquivos
	desc = "Formatar usando LSP antes de salvar",
	callback = function(args)
		vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 1500 })
	end,
})

_G.get_status_mode = function()
	local modes = {
		["n"] = "NORMAL",
		["no"] = "NORMAL",
		["v"] = "VISUAL",
		["V"] = "V-LINE",
		["\22"] = "V-BLOCK", -- \22 is Control-V
		["s"] = "SELECT",
		["S"] = "S-LINE",
		["\19"] = "S-BLOCK",
		["i"] = "INSERT",
		["ic"] = "INSERT",
		["R"] = "REPLACE",
		["Rv"] = "V-REPLACE",
		["c"] = "COMMAND",
		["cv"] = "VIM EX",
		["ce"] = "EX",
		["r"] = "PROMPT",
		["rm"] = "MOAR",
		["r?"] = "CONFIRM",
		["!"] = "SHELL",
		["t"] = "TERMINAL",
	}
	local current_mode = vim.api.nvim_get_mode().mode
	-- Returns the mapped name or defaults to the raw code in uppercase
	return string.format("[%s]", modes[current_mode] or current_mode:upper())
end

local statusline = {
	" %{v:lua.get_status_mode()} ", -- <--- The new mode component
	"%t", -- Filename
	"%r", -- Readonly flag
	"%m", -- Modified flag
	"%=", -- Right align spacer
	"%{&filetype}", -- Filetype (e.g., lua, cpp)
	" %2p%%", -- Percentage through file
	" %3l:%-2c ", -- Line:Column
}

vim.o.showmode = false
vim.o.statusline = table.concat(statusline, "")
