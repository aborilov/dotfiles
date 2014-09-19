filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'

Plugin 'kien/ctrlp.vim'
Plugin 'bling/vim-airline'
Plugin 'scrooloose/nerdtree'

call vundle#end()            " required
filetype plugin indent on    " required
autocmd! bufwritepost .vimrc source %
syntax on
set colorcolumn=79
set hlsearch
vnoremap < <gv
vnoremap > >gv
" Press Space to turn off highlighting and clear any message already displayed.
:nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

colorscheme monokai
let g:airline#extensions#tabline#enabled = 1
set nocompatible
set list listchars=tab:\ \ ,trail:·
set noshowmode
set nowrap
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
set ignorecase
set smartcase
set smartindent
set smarttab
set magic
set bs=indent,eol,start
set tabstop=4
set shiftwidth=4
set expandtab
set noswapfile
set guifont=Inconsolata\ Medium\ 14
