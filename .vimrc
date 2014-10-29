set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'

"Bundle 'Raimondi/delimitMate'
Plugin 'kien/ctrlp.vim'
Plugin 'bling/vim-airline'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-fugitive'
"Plugin 'scrooloose/syntastic'
Plugin 'airblade/vim-gitgutter'
Plugin 'scrooloose/nerdcommenter'
Plugin 'Valloric/YouCompleteMe'
Plugin 'altercation/vim-colors-solarized'
Plugin 'klen/python-mode'
Plugin 'tomasr/molokai'
Plugin 'rosenfeld/conque-term'
Plugin 'vim-scripts/taglist.vim'
Plugin 'szw/vim-ctrlspace' 
Plugin 'mileszs/ack.vim'
call vundle#end()            " required
filetype plugin indent on    " required
syntax on
"set colorcolumn=79

"pymode
let g:pymode = 1
let g:pymode_run = 0
let g:pymode_rope = 0
let g:pymode_rope_completion = 0
let g:pymode_rope_complete_on_dot = 0
let g:pymode_lint = 1
let g:pymode_lint_checker = "pyflakes,pep8"
let g:pymode_lint_write = 1
let g:pymode_folding = 0
let g:pymode_syntax = 1
let g:pymode_syntax_all = 1
let g:pymode_syntax_indent_errors = g:pymode_syntax_all
let g:pymode_syntax_space_errors = g:pymode_syntax_all

"YouCompleteMy
set completeopt-=preview
nnoremap <leader>g :YcmCompleter GoToDefinitionElseDeclaration<CR>

"ConqueTerm
let g:ConqueTerm_StartMessages = 0
nnoremap <leader>r :exe "ConqueTermSplit ipython -i " . expand("%")<CR>

"NerdTree
map <C-k><C-b> :NERDTreeToggle<CR>

"CtrlP
let g:ctrlp_match_window = 'bottom,order:ttb,min:10,max:30'
let g:ctrlp_show_hidden = 1

"CtrlSpace
let g:ctrlspace_load_last_workspace_on_start = 1
let g:ctrlspace_save_workspace_on_exit = 1

"TagList
let g:Tlist_Close_On_Select = 1
let g:Tlist_GainFocus_On_ToggleOpen = 1
let g:Tlist_File_Fold_Auto_Close = 1
nnoremap <leader>t :TlistToggle<CR>

set incsearch                     " Find as you type search
set hlsearch                      " Highlight search terms
set ignorecase                    " Case-insensitive searching.
set smartcase                     " But case-sensitive if expression contains a capital letter.
set autoindent                    " match indentation of previous line

vnoremap < <gv
vnoremap > >gv
" Press Space to turn off highlighting and clear any message already displayed.
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

colorscheme molokai

map <C-q> :bd<CR>
let loaded_matchparen = 0
set showtabline=0
set list listchars=tab:\ \ ,trail:·
set nowrap
set bs=indent,eol,start
set tabstop=4
set shiftwidth=4
set expandtab
set scrolloff=2
set number
set showcmd
set ruler
set title
set wildmenu
set matchpairs+=<:>
set hidden
set history=1000
set laststatus=2
set showmatch
set matchtime=2
set esckeys
set smartindent
set smarttab
set magic
set noswapfile
set guifont=Inconsolata\ 14
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar
