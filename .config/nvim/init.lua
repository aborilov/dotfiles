local g = vim.g
local cmd = vim.cmd
--
-- Leader/local leader
g.mapleader = [[ ]]

-- Commands
local create_cmd = vim.api.nvim_create_user_command
create_cmd('PackerInstall', function()
  cmd [[packadd packer.nvim]]
  require('plugins').install()
end, {})
create_cmd('PackerUpdate', function()
  cmd [[packadd packer.nvim]]
  require('plugins').update()
end, {})
create_cmd('PackerSync', function()
  cmd [[packadd packer.nvim]]
  require('plugins').sync()
end, {})
create_cmd('PackerClean', function()
  cmd [[packadd packer.nvim]]
  require('plugins').clean()
end, {})
create_cmd('PackerCompile', function()
  cmd [[packadd packer.nvim]]
  require('plugins').compile()
end, {})

require 'impatient'
require("nvim-tree").setup()
require 'lspconfig'.gopls.setup{}
require('Comment').setup({
    toggler = {
        ---Line-comment toggle keymap
        line = '<leader>ci',
    },
    ---LHS of operator-pending mappings in NORMAL and VISUAL mode
    opleader = {
        ---Line-comment keymap
        line = '<leader>ci',
    },
    ---Enable keybindings
    ---NOTE: If given `false` then the plugin won't create any mappings
    mappings = {
        ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
        basic = true,
        ---Extra mapping; `gco`, `gcO`, `gcA`
        extra = true,
    },
})



local async = require "plenary.async"
local null_ls = require("null-ls")
null_ls.setup({
     on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ bufnr = bufnr })
                end,
            })
        end
    end,
    debug = true,
    sources = {
        null_ls.builtins.formatting.goimports,
        null_ls.builtins.diagnostics.golangci_lint,
        null_ls.builtins.formatting.gofmt,
        null_ls.builtins.completion.spell,
--        null_ls.builtins.formatting.golines,
        null_ls.builtins.formatting.goimports_reviser
    },
})

require('telescope').setup{
  pickers = {
    find_files = {
      theme = "dropdown",
    },
    live_grep = {
      theme = "dropdown",
    },
    buffers = {
      theme = "ivy",
    },
    lsp_references = {
      theme = "cursor",
    },
    lsp_implementations = {
      theme = "cursor",
    }
  },
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>a', builtin.live_grep, {})
vim.keymap.set('n', '<C-Space>', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>re', builtin.lsp_references, {})
vim.keymap.set('n', '<leader>s', builtin.lsp_implementations, {})
local bufopts = { noremap=true, silent=true, buffer=bufnr }
vim.keymap.set('n', '<leader>g', vim.lsp.buf.definition, bufopts)
vim.keymap.set('n', '<leader>e', vim.lsp.buf.rename, bufopts)
-- vim.keymap.set('n', '<leader>s', vim.lsp.buf.implementation, bufopts)
-- vim.keymap.set('n', '<leader>re', vim.lsp.buf.references, opts)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)



-- Skip some remote provider loading
g.loaded_python3_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- Disable some built-in plugins we don't want
local disabled_built_ins = {
  'gzip',
  'man',
  'matchit',
  'matchparen',
  'shada_plugin',
  'tarPlugin',
  'tar',
  'zipPlugin',
  'zip',
  'netrwPlugin',
}

for i = 1, 10 do
  g['loaded_' .. disabled_built_ins[i]] = 1
end

-- Split line (sister to [J]oin lines)
-- The normal use of S is covered by cc, so don't worry about shadowing it.
vim.api.nvim_set_keymap('n', 'S', 'i<cr><esc>^mwgk:silent! s/\v +$//<cr>:noh<cr>`w', { noremap = true })

vim.api.nvim_set_keymap('n', '<leader>w', ':w<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>ev', '<C-w><C-v><C-l>:e $MYVIMRC<cr>', { noremap = true })

-- Keep the cursor in place while joining lines
vim.api.nvim_set_keymap('n', 'J', 'mzJ`z', { noremap = true })

vim.api.nvim_set_keymap('n', '<leader>v', '<C-w>v', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-k><C-b>', ':NvimTreeToggle<CR>', { noremap = false })
vim.api.nvim_set_keymap('n', '<leader>st', ':Git<CR>', { noremap = true })


cmd([[
au FileType yaml setlocal tabstop=2 expandtab shiftwidth=2 softtabstop=2
au FileType yml setlocal tabstop=2 expandtab shiftwidth=2 softtabstop=2
]])

cmd([[
augroup cline
    au!
    au WinLeave,InsertEnter * set nocursorline
    au WinEnter,InsertLeave * set cursorline
augroup END
]])
 
-- Press Space to turn off highlighting and clear any message already displayed.
vim.api.nvim_set_keymap('n', '<Space>', ':nohlsearch<Bar>:echo<CR>', { noremap = true, silent = true })
 
-- Settings
local opt = vim.opt
opt.scrolloff = 8
opt.wildignore = {
  '*~', '.hg', '.git', '.svn', '*.aux', '*.out','*.toc', '*.jpg', '*.bmp',
  '*.gif', '*.png', '*.jpeg', '*.o', '*.obj', '*.exe', '*.dll', '*.manifest',
  '*.spl', '*.sw?', '*.pyc', '*.orig', 'log/**', 'tmp/**'}
opt.wildmode = 'list:longest'
opt.showmatch = true
opt.ignorecase = true
opt.smartcase = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.number = true
opt.relativenumber = true
opt.smartindent = true
opt.laststatus = 2
opt.showmode = true
opt.hidden = true
opt.undofile = true
opt.cursorline = true
opt.modeline = false
opt.cmdheight = 0
opt.timeoutlen = 250
opt.termguicolors = true
opt.background = 'dark'
opt.wrap = false
opt.linebreak = true
opt.completeopt = 'menu' 
opt.listchars='tab:▸ ,eol:¬,extends:❯,precedes:❮'

cmd([[colorscheme solarized ]])
cmd([[hi Normal guibg=None ]])
