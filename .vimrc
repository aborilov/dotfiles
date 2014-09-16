autocmd! bufwritepost .vimrc source %
set nu
syntax on
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set hlsearch
vnoremap < <gv
vnoremap > >gv
" Press Space to turn off highlighting and clear any message already displayed.
:nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>
set nocompatible
