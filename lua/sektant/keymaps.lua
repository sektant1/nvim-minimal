vim.g.mapleader = " "

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- General
map("n", "<esc>", ":noh<cr>", opts)
map({ "n", "x" }, "<leader>y", '"+y')
map({ "n", "x" }, "<leader>D", '"+d')
map({ "v", "x", "n" }, "<C-y>", '"+y', { desc = "System clipboard yank." })

map("n", "<leader>w", "<Cmd>update<CR>", { desc = "Write buffer" })
map("n", "<leader>q", "<Cmd>quit<CR>", { desc = "Quit buffer" })
map("n", "<leader>Q", "<Cmd>wqa<CR>", { desc = "Quit all and write" })
map("n", "<leader>O", "<Cmd>restart<CR>", { desc = "Restart vim" })
map("n", "<leader>o", "<Cmd>source %<CR>", { desc = "Source current file" })

map({ "n", "v", "x" }, "<leader>v", "<Cmd>edit $MYVIMRC<CR>", { desc = "Edit init.lua" })
map({ "n", "v", "x" }, "<leader>z", "<Cmd>e ~/.bashrc<CR>", { desc = "Edit .bashrc" })

-- Move lines/blocks
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move line up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down (insert)" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up (insert)" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move block down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move block up" })

-- editing conveniences
map("n", "o", "<cmd>:call append(line('.'), '')<CR>")
map("n", "O", "<cmd>:call append(line('.')-1, '')<CR>")
map("n", "Y", "_y$", { desc = "Yank to end of line" })
map("n", "D", "_d$", { desc = "Delete to end of line" })
map("v", "H", "^", { desc = "Start of line" })
map("v", "L", "$", { desc = "End of line" })
map("x", "<leader>r", [["_dP]], { desc = "Replace selection with buffer" })
map("v", "p", '"_dP', opts)

map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

map({ "n", "v", "x" }, ";", ":", { desc = "Command mode" })
map({ "n", "v", "x" }, ":", ";", { desc = "Repeat last f/t" })
map({ "n", "v", "x" }, "<C-s>", [[:s/\V]], { desc = "Substitute in selection" })
map({ "n", "v", "x" }, "<leader>n", ":norm ", { desc = "Run normal command" })

-- tmux passthrough
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

vim.keymap.set("i", "<Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-y>" or "<Tab>"
end, { expr = true, silent = true, desc = "Accept completion or insert Tab" })

-- tabs
map({ "n", "t" }, "<leader>tn", "<Cmd>tabnew<CR>", { desc = "Tab new" })
map({ "n", "t" }, "<leader>tx", "<Cmd>tabclose<CR>", { desc = "Tab close" })
map({ "n", "t" }, "<leader><S-Tab>", "<Cmd>tabprevious<CR>", { desc = "Tab previous" })
map({ "n", "t" }, "<leader><Tab>", "<Cmd>tabnext<CR>", { desc = "Tab next" })
for i = 1, 8 do
	map({ "n", "t" }, "<leader>t" .. i, "<Cmd>tabnext " .. i .. "<CR>", { desc = "Tab " .. i })
end

map("n", "<leader>pr", "<CMD>Telescope projects<CR>", opts)
map("n", "<leader>cs", "<CMD>Telescope colorscheme<CR>", opts)

-- file managers / OS
map("n", "<leader>e", "<cmd>Yazi<CR>")
map("n", "<leader>sp", "<CMD>Telescope projects<CR>", opts)
map("n", "<C-f>", "<Cmd>Open .<CR>", { desc = "Open in OS Finder" })
map("n", "<leader>a", ":edit #<CR>", { desc = "Edit alternate file" })

-- LSP / diagnostics / quickfix
map({ "n", "v", "x" }, "<leader>lf", vim.lsp.buf.format, { desc = "Format buffer" })
map("n", "<C-q>", ":copen<CR>", { silent = true })
map("n", "<leader>d", function()
	vim.diagnostic.open_float()
end, { desc = "Diagnostic float" })

-- legacy vimscript mappings
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

-- resize
map("n", "<M-n>", "<cmd>resize +2<CR>")
map("n", "<M-e>", "<cmd>resize -2<CR>")
map("n", "<M-i>", "<cmd>vertical resize +5<CR>")
map("n", "<M-m>", "<cmd>vertical resize -5<CR>")
