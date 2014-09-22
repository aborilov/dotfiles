set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'

Bundle 'Raimondi/delimitMate'
Plugin 'kien/ctrlp.vim'
Plugin 'bling/vim-airline'
Plugin 'scrooloose/nerdtree'
Bundle 'mileszs/ack.vim'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/syntastic'
Plugin 'airblade/vim-gitgutter'
Plugin 'scrooloose/nerdcommenter'

call vundle#end()            " required
filetype plugin indent on    " required
syntax on
set colorcolumn=79

set incsearch                     " Find as you type search
set hlsearch                      " Highlight search terms
set ignorecase                    " Case-insensitive searching.
set smartcase                     " But case-sensitive if expression contains a capital letter.
set autoindent                    " match indentation of previous line

vnoremap < <gv
vnoremap > >gv
" Press Space to turn off highlighting and clear any message already displayed.
:nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

colorscheme monokai
let g:airline#extensions#tabline#enabled = 1
set list listchars=tab:\ \ ,trail:·
set noshowmode

set nowrap
set bs=indent,eol,start
set tabstop=4
set shiftwidth=4
set expandtab

set scrolloff=2
set number

set showmatch
set showmode
set showcmd

set ruler
set title
set wildmenu
set matchpairs+=<:>
set hidden
set history=100
set laststatus=2
set matchtime=2
set esckeys
set smartindent
set smarttab
set magic
set noswapfile
set guifont=Inconsolata\ Medium\ 14
