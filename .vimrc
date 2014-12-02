" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" ================ General Config ====================

set number                      "Line numbers are good
set backspace=indent,eol,start  "Allow backspace in insert mode
set history=1000                "Store lots of :cmdline history
set showcmd                     "Show incomplete cmds down the bottom
set showmode                    "Show current mode down the bottom
set novisualbell                  "No sounds
set autoread                    "Reload files changed outside vim


" This makes vim act like all other editors, buffers can
" exist in the background without being in a window.
" http://items.sjbach.com/319/configuring-vim-right
set hidden

"turn on syntax highlighting
syntax on

" The mapleader has to be set before vundle starts loading all 
" the plugins.
let mapleader="\\"

" =============== Vundle Initialization ===============
" This loads all the plugins
" Use Vundle plugin to manage all other plugins

filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'

Bundle 'Raimondi/delimitMate'
Plugin 'kien/ctrlp.vim'
Plugin 'bling/vim-airline'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/syntastic'
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

"pymode
let g:pymode = 1
let g:pymode_run = 0
let g:pymode_rope = 0
let g:pymode_rope_completion = 0
let g:pymode_rope_complete_on_dot = 0
let g:pymode_lint = 0
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
let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"

"ConqueTerm
let g:ConqueTerm_StartMessages = 0
nnoremap <leader>r :exe "ConqueTermSplit ipython -i " . expand("%")<CR>

"NerdTree
let g:NERDTreeQuitOnOpen=1
map <C-k><C-b> :NERDTreeToggle<CR>

"CtrlP
let g:ctrlp_match_window = 'bottom,order:ttb,min:10,max:30'
let g:ctrlp_show_hidden = 1
imap <C-K> <Plug>delimitMateS-Tab

"CtrlSpace
let g:ctrlspace_load_last_workspace_on_start = 1
let g:ctrlspace_save_workspace_on_exit = 1

"TagList
let g:Tlist_Close_On_Select = 1
let g:Tlist_GainFocus_On_ToggleOpen = 1
let g:Tlist_File_Fold_Auto_Close = 1
nnoremap <leader>t :TlistToggle<CR>
set tags+=./tags;/

"NerdCommenter
let g:NERDSpaceDelims=1

" ================ Turn Off Swap Files ==============

set noswapfile
set nobackup
set nowb

" ================ Persistent Undo ==================
" Keep undo history across sessions, by storing in file.
" Only works all the time.
if has('persistent_undo')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

" ================ Indentation ======================

set autoindent
set smartindent
set smarttab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

filetype plugin on
filetype indent on

" Display tabs and trailing spaces visually
set list listchars=tab:\ \ ,trail:·

set nowrap       "Don't wrap lines
set linebreak    "Wrap lines at convenient points

" ================ Folds ============================

set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default


" ================ Completion =======================

set wildmode=list:longest
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing
set wildignore+=*vim/backups*
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif

" ================ Scrolling ========================

set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1

set incsearch                     " Find as you type search
set hlsearch                      " Highlight search terms
set ignorecase                    " Case-insensitive searching.
set smartcase                     " But case-sensitive if expression contains a capital letter.

" ================ Others ========================

let loaded_matchparen = 0
set showtabline=0
set ruler
set title
set matchpairs+=<:>
set laststatus=2
set showmatch
set matchtime=2
set esckeys
set magic
set guifont=Inconsolata\ 14
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar

colorscheme molokai

vnoremap < <gv
vnoremap > >gv
" Press Space to turn off highlighting and clear any message already displayed.
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>
map <C-q> :bd<CR>

