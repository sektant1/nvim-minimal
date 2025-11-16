-- Desabilita completamente o mouse.
vim.cmd([[set mouse=]])
-- Nunca cria arquivos de swap (.swp).
vim.cmd([[set noswapfile]])

-- Define as bordas das janelas (splits, float) como arredondadas.
vim.opt.winborder = "rounded"
-- Tamanho da tabulação em 2 espaços.
vim.opt.tabstop = 2
-- Tamanho do "shift" (autoindent) em 2 espaços.
vim.opt.shiftwidth = 2
-- Sempre mostrar a barra de abas (tabline), mesmo com uma única aba.
vim.opt.showtabline = 2
-- Mostrar a coluna de "sinais" (git, lsp diagnostics).
vim.opt.signcolumn = "yes"
-- Desliga o "word wrap" (quebra de linha automática).
vim.opt.wrap = false
-- Não destaca a coluna onde o cursor está.
vim.opt.cursorcolumn = false
-- Ignora maiúsculas/minúsculas ao pesquisar.
vim.opt.ignorecase = true
-- Ativa a indentação inteligente.
vim.opt.smartindent = true
-- Permite cores "true color" no terminal.
vim.opt.termguicolors = true
-- Habilita o "undo" persistente (desfazer mesmo após fechar o arquivo).
vim.opt.undofile = true
-- Mostra o número das linhas.
vim.opt.number = true


vim.pack.add({
	-- Temas
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/elvessousa/sobrio" },
	{ src = "https://github.com/darkvoid-theme/darkvoid.nvim" },
	{ src = "https://github.com/nyoom-engineering/oxocarbon.nvim" },
	{ src = "https://github.com/michaeljsmith/vim-colours-dark-lord" },

	-- UI / Utilidades
	{ src = "https://github.com/chentoast/marks.nvim" },        -- Gerenciador de "marcas" (bookmarks)
	{ src = "https://github.com/stevearc/oil.nvim" },           -- Gerenciador de arquivos (substituto do netrw)
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" }, -- Ícones
	{ src = "https://github.com/aznhe21/actions-preview.nvim" }, -- Preview de code actions

	-- Core de Desenvolvimento
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter",        version = "main" }, -- Parser de sintaxe
	{ src = "https://github.com/neovim/nvim-lspconfig" },                                   -- Configuração base do LSP
	{ src = "https://github.com/mason-org/mason.nvim" },                                    -- Gerenciador de LSPs e formatters

	-- Telescope (Fuzzy Finder) e dependências
	{ src = "https://github.com/nvim-telescope/telescope.nvim",          version = "0.1.8" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },     -- Dependência comum (Telescope, etc)
	{ src = "https://github.com/LinArcX/telescope-env.nvim" }, -- Extensão para variáveis de ambiente

	-- Snippets
	{ src = "https://github.com/L3MON4D3/LuaSnip" },

	-- Específico
	{ src = "https://github.com/chomosuke/typst-preview.nvim" }, -- Preview para Typst
})

-- --- Config: marks.nvim ---
require "marks".setup {
	builtin_marks = { "<", ">", "^" },
	refresh_interval = 250,
	sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
	excluded_filetypes = {},
	excluded_buftypes = {},
	mappings = {}
}

-- --- Tema Padrão ---
local default_color = "darkvoid"
-- vim.o.background = "dark"

-- --- Config: mason.nvim ---
require "mason".setup()

-- --- Config: telescope.nvim ---
local telescope = require("telescope")
telescope.setup({
	defaults = {
		preview = { treesitter = false }, -- Desliga o preview do treesitter (pode ser lento)
		color_devicons = true,
		sorting_strategy = "ascending",
		-- Define bordas arredondadas para o Telescope
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
		}
	}
})
-- Carrega a extensão 'ui-select' (para substituir vim.ui.select)
telescope.load_extension("ui-select")

-- --- Config: actions-preview.nvim ---
require("actions-preview").setup {
	backend = { "telescope" },
	extensions = { "env" },
	telescope = vim.tbl_extend(
		"force",
		require("telescope.themes").get_dropdown(), {}
	)
}


-- --- Autocmd: LspAttach ---
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		-- Verifica se o servidor suporta "completion"
		if client:supports_method('textDocument/completion') then
			-- Opcional: Ativa autocompletion em CADA tecla. Pode ser lento.
			local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
			client.server_capabilities.completionProvider.triggerCharacters = chars
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
	end,
})

-- Opções do menu de autocompletar.
vim.cmd [[set completeopt+=menuone,noselect,popup]]

-- --- LSPs Ativados ---
-- Lista de servidores de linguagem que o lspconfig deve iniciar.
-- (O Mason deve tê-los instalado).
vim.lsp.enable({
	"lua_ls", "cssls",
	"rust_analyzer", "clangd", "ruff",
	"glsl_analyzer", "hlint",
	"intelephense", "biome", "tailwindcss",
	"ts_ls", "emmet_language_server", "emmet_ls", "solargraph"
})


-- --- Config: oil.nvim ---
-- Configuração do gerenciador de arquivos.
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

-- --- Config: vague.nvim ---
require "vague".setup({ transparent = true })

-- --- Config: luasnip ---
-- Setup do gerenciador de snippets.
require("luasnip").setup({ enable_autosnippets = true })
-- Carrega snippets customizados da pasta especificada.
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })

-- --- Função: pack_clean ---
-- Função para listar e remover plugins do 'vim.pack' que não estão ativos.
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

-- Keymap para rodar a função de limpeza
vim.keymap.set("n", "<leader>pc", pack_clean)


-- Cria um grupo de autocomandos limpo para temas.
local color_group = vim.api.nvim_create_augroup("colors", { clear = true })

-- Autocmd para forçar o tema ao carregar...
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

-- ... e ao entrar em uma nova aba (garante consistência).
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

-- (Este bloco parece redundante ou incompleto, mas mantido)
local colors = {}
vim.api.nvim_create_autocmd("ColorScheme", {
	group = color_group,
	callback = function(args)
		-- vim.cmd("hi statusline guibg=NONE")
		-- vim.cmd("hi TabLineFill guibg=NONE")
	end,
})


-- --- Aliases Locais para Keymaps ---
local ls = require("luasnip")
local builtin = require("telescope.builtin")
local map = vim.keymap.set
local current = 1

-- --- Leader key ---
vim.g.mapleader = " "

-- --- Keymaps: Utilidade Básica ---
map({ "n", "x" }, "<leader>y", '"+y')
map({ "n", "x" }, "<leader>d", '"+d')

-- --- Keymaps: LuaSnip (Snippets) ---
map({ "i", "s" }, "<C-e>", function() ls.expand_or_jump(1) end, { silent = true })
map({ "i", "s" }, "<C-J>", function() ls.jump(1) end, { silent = true })
map({ "i", "s" }, "<C-K>", function() ls.jump(-1) end, { silent = true })

-- --- Keymaps: Abas (Tabs) ---
map({ "n", "t" }, "<Leader>t", "<Cmd>tabnew<CR>")
map({ "n", "t" }, "<Leader>x", "<Cmd>tabclose<CR>")

-- --- Keymaps: Legado (Vimscript) ---
-- Mapeamentos definidos com o `vim.cmd` (formato antigo).
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

-- --- Keymaps: Navegação de Abas (Loop) ---
-- Cria atalhos <Leader>1, <Leader>2, ... <Leader>8
for i = 1, 8 do
	map({ "n", "t" }, "<Leader>" .. i, "<Cmd>tabnext " .. i .. "<CR>")
end

-- --- Keymaps: Conveniência ---
-- Troca ';' e ':' (para comandos)
map({ "n", "v", "x" }, ";", ":", { desc = "Self explanatory" })
map({ "n", "v", "x" }, ":", ";", { desc = "Self explanatory" })
-- Editar esta configuração
map({ "n", "v", "x" }, "<leader>v", "<Cmd>edit $MYVIMRC<CR>", { desc = "Edit " .. vim.fn.expand("$MYVIMRC") })
-- Editar .zshrc
map({ "n", "v", "x" }, "<leader>z", "<Cmd>e ~/.zshrc<CR>", { desc = "Edit .zshrc" })
-- Entrar comando em modo Normal (ex: <leader>n dd)
map({ "n", "v", "x" }, "<leader>n", ":norm ", { desc = "ENTER NORM COMMAND." })
-- Recarregar (source) esta configuração
map({ "n", "v", "x" }, "<leader>o", "<Cmd>source %<CR>", { desc = "Source " .. vim.fn.expand("$MYVIMRC") })
-- Reiniciar o Vim
map({ "n", "v", "x" }, "<leader>O", "<Cmd>restart<CR>", { desc = "Restart vim." })
-- Substituir em modo visual/normal
map({ "n", "v", "x" }, "<C-s>", [[:s/\V]], { desc = "Enter substitue mode in selection" })
-- Copiar para clipboard do sistema (redundante com <leader>y)
map({ "v", "x", "n" }, "<C-y>", '"+y', { desc = "System clipboard yank." })

-- --- Keymaps: LSP ---
-- Formatar buffer atual
map({ "n", "v", "x" }, "<leader>lf", vim.lsp.buf.format, { desc = "Format current buffer" })

-- --- Keymaps: Telescope (Fuzzy Finder) ---
-- Função helper para <leader>sg (encontrar arquivos git)
function git_files() builtin.find_files({ no_ignore = true }) end

map({ "n" }, "<leader>f", builtin.find_files, { desc = "Telescope live grep" }) -- 'live grep' no desc? Deveria ser 'find files'
map({ "n" }, "<leader>g", builtin.live_grep)                                    -- Pesquisa texto (live grep)
map({ "n" }, "<leader>sg", git_files)                                           -- Arquivos (incluindo ignorados pelo git)
map({ "n" }, "<leader>sb", builtin.buffers)                                     -- Buffers abertos
map({ "n" }, "<leader>si", builtin.grep_string)                                 -- Pesquisa palavra sob cursor
map({ "n" }, "<leader>so", builtin.oldfiles)                                    -- Arquivos recentes
map({ "n" }, "<leader>sh", builtin.help_tags)                                   -- Ajuda
map({ "n" }, "<leader>sm", builtin.man_pages)                                   -- Man pages
map({ "n" }, "<leader>sr", builtin.lsp_references)                              -- Referências LSP
map({ "n" }, "<leader>sd", builtin.diagnostics)                                 -- Diagnósticos LSP
map({ "n" }, "<leader>si", builtin.lsp_implementations)                         -- Implementações LSP
map({ "n" }, "<leader>sT", builtin.lsp_type_definitions)                        -- Definições de tipo LSP
map({ "n" }, "<leader>ss", builtin.current_buffer_fuzzy_find)                   -- Pesquisa no buffer atual
map({ "n" }, "<leader>st", builtin.builtin)                                     -- Builtins do Telescope
map({ "n" }, "<leader>sc", builtin.git_bcommits)                                -- Commits do buffer
map({ "n" }, "<leader>sk", builtin.keymaps)                                     -- Atalhos
map({ "n" }, "<leader>se", "<cmd>Telescope env<cr>")                            -- Variáveis de ambiente
map({ "n" }, "<leader>sa", require("actions-preview").code_actions)             -- Code actions

-- --- Keymaps: Redimensionar Janelas (Splits) ---
map({ "n" }, "<M-n>", "<cmd>resize +2<CR>")
map({ "n" }, "<M-e>", "<cmd>resize -2<CR>")
map({ "n" }, "<M-i>", "<cmd>vertical resize +5<CR>")
map({ "n" }, "<M-m>", "<cmd>vertical resize -5<CR>")

-- --- Keymaps: Plugins ---
map({ "n" }, "<leader>e", "<cmd>Oil<CR>") -- Abrir Oil (gerenciador de arquivos)
map({ "n" }, "<leader>c", "1z=")          -- Sugestão de correção (LSP)

-- --- Keymaps: Quickfix & Buffers ---
map({ "n" }, "<C-q>", ":copen<CR>", { silent = true })
map({ "n" }, "<leader>w", "<Cmd>update<CR>", { desc = "Write the current buffer." })
map({ "n" }, "<leader>q", "<Cmd>:quit<CR>", { desc = "Quit the current buffer." })
map({ "n" }, "<leader>Q", "<Cmd>:wqa<CR>", { desc = "Quit all buffers and write." })

-- --- Keymaps: Específicos do OS (Parece ser macOS) ---
map({ "n" }, "<C-f>", "<Cmd>Open .<CR>", { desc = "Open current directory in Finder." }) -- Abrir no Finder
map({ "n" }, "<leader>a", ":edit #<CR>", { desc = "Open current directory in Finder." }) -- Descrição errada? Isso edita o arquivo alternativo.

-- --- Keymaps: Navegação (Centralizar Tela) ---
-- Centraliza a tela após pular meia página (C-d, C-u) ou ir para próxima/anterior (n, N)
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

map("x", "<leader>r", [["_dP]], { desc = "Replace Selection with Buffer" })
-- Move Lines
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

-- --- Autocmd: Filetype JSX/TSX ---
-- Força o filetype de 'typescriptreact' para arquivos .jsx e .tsx.
vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "*.jsx,*.tsx",
	group = vim.api.nvim_create_augroup("TS", { clear = true }),
	callback = function()
		vim.cmd([[set filetype=typescriptreact]])
	end
})

-- --- Carregamento Inicial do Tema ---
-- Define o colorscheme padrão na inicialização.
vim.cmd('colorscheme ' .. default_color)

-- --- Autocmd: Sincronizar PHP (BufWritePost) ---
-- Roda o script 'gg-repo-sync' automaticamente após salvar um arquivo .php.
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
