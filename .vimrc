" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" ================ General Config ====================
set mmp=5000

" set nonumber                      "Line numbers are good
set relativenumber
set number                      "Line numbers are good
set backspace=indent,eol,start  "Allow backspace in insert mode
set history=1000                "Store lots of :cmdline history
set showcmd                     "Show incomplete cmds down the bottom
set showmode                    "Show current mode down the bottom
set novisualbell                  "No sounds
set autoread                    "Reload files changed outside vim

" Try to make vim syntax highlight faster
" See: https://github.com/fatih/vim-go/issues/145
set nocursorcolumn
syntax sync minlines=256
set re=1


" This makes vim act like all other editors, buffers can
" exist in the background without being in a window.
" http://items.sjbach.com/319/configuring-vim-right
set hidden

"turn on syntax highlighting
syntax on

" The mapleader has to be set before vundle starts loading all
" the plugins.
let mapleader="\<Space>"

" =============== Vundle Initialization ===============
" This loads all the plugins
" Use Vundle plugin to manage all other plugins

filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'

Bundle 'Raimondi/delimitMate'
Plugin 'bling/vim-airline'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rhubarb'
Plugin 'w0rp/ale'
Plugin 'airblade/vim-gitgutter'
Plugin 'scrooloose/nerdcommenter'
Plugin 'altercation/vim-colors-solarized'
Plugin 'klen/python-mode'
Plugin 'tomasr/molokai'
Plugin 'mileszs/ack.vim'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'edkolev/tmuxline.vim'
Plugin 'benmills/vimux'
Plugin 'ryanoasis/vim-devicons'
Plugin 'machakann/vim-sandwich'
Plugin 'fatih/vim-go'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'tpope/vim-unimpaired'
Plugin 'kylef/apiblueprint.vim'
Plugin 'nelstrom/vim-markdown-folding'
call vundle#end()            " required

"Dash
nmap <Leader>da <Plug>DashSearch

"ALE
let g:ale_sign_warning = '⚠'
let g:ale_sign_error = '✗'
let g:ale_linters = {'python': ['flake8', 'pylint'],'go': ['golint', 'go vet', 'goimports']}
let g:ale_python_pylint_executable = 'python'
let g:airline#extensions#ale#enabled = 1

"ctrlp
nnoremap <C-@> :CtrlPBuffer<CR>
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

" let g:go_debug_address = 'dev.aborilov.ru:2345'

"vim-go
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <Leader>hd <Plug>(go-doc)
au FileType go nmap <Leader>re <Plug>(go-referrers)
au FileType go nmap <Leader>s <Plug>(go-implements)
au FileType go nmap <Leader>i <Plug>(go-info)
au FileType go nmap <Leader>e <Plug>(go-rename)
au FileType go nnoremap <leader>g :GoDef<CR>
au FileType go nmap <Leader>gt <Plug>(go-test-func)
au FileType go nmap <Leader>ge :GoIfErr<CR>
au FileType go nmap <Leader>gi <Plug>(go-install ./...)
" au FileType go nmap <Leader>rr :GoDecls<CR>
au FileType go nmap <Leader>dr :GoDeclsDir<CR>
au Filetype go nmap <leader>ga <Plug>(go-alternate-edit)
au Filetype go nmap <leader>gah <Plug>(go-alternate-split)
au Filetype go nmap <leader>gav <Plug>(go-alternate-vertical)
let g:go_fmt_command = "goimports"
let g:go_auto_type_info = 1
let g:go_doc_popup_window = 1
let g:go_rename_command = 'gopls'

set pyxversion=3
set encoding=utf-8
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

"xkbswitch
let g:XkbSwitchEnabled = 1

"vimux
" Run the current file with python
function! VimuxSlime()
    call VimuxSendText(@v)
    call VimuxSendKeys("Enter")
endfunction
map <Leader>rp :call VimuxRunCommand("clear; python " . bufname("%"))<CR>
map <Leader>dp :!./.deploy.sh<CR>
vmap <Leader>vs "vy :call VimuxSlime()<CR>
nmap <Leader>vs ggVG"vy :call VimuxSlime()<CR>
" nmap <Leader>vs vip<Leader>pp<CR>
" Run last command executed by VimuxRunCommand
map <Leader>vl :VimuxRunLastCommand<CR>

"airline
let g:airline_powerline_fonts = 1

"syntastic
" let g:syntastic_python_checkers = ['pyflakes', 'pep8']
" let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']
" let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }
" let g:go_list_type = "quickfix"

" Ack 
nnoremap <leader>a :Ack!<space>
let g:ackprg = 'ack --ignore-dir=vendor --smart-case --nogroup --nocolor --column'

"vim-indent-guides
let g:indent_guides_enable_on_vim_startup=1
let g:indent_guides_guide_size=1
let g:indent_guides_start_level=2

"pymode
let g:pymode = 0
let g:pymode_run = 1
let g:pymode_rope = 1
let g:pymode_rope_completion = 0
let g:pymode_rope_complete_on_dot = 0
let g:pymode_lint = 0
let g:pymode_lint_checkers = ["pylint"]
let g:pymode_lint_on_write = 1
let g:pymode_folding = 0
let g:pymode_syntax = 0
let g:pymode_syntax_all = 1
let g:pymode_syntax_indent_errors = g:pymode_syntax_all
let g:pymode_syntax_space_errors = g:pymode_syntax_all
let g:pymode_lint_ignore="C0111"
nnoremap <leader>lf :PymodeLintAuto<CR>
nnoremap <leader>lc :PymodeLint<CR>

"YouCompleteMe
set completeopt-=preview
" set completeopt+=preview
" set omnifunc=syntaxcomplete#Complete
" nnoremap <leader>g :YcmCompleter GoToDefinitionElseDeclaration<CR>
" let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"
" let g:ycm_server_python_interpreter = '/usr/local/bin/python3'

"NerdTree
let g:NERDTreeQuitOnOpen=1
map <C-k><C-b> :NERDTreeToggle<CR>

"TagList
let g:Tlist_Close_On_Select = 1
let g:Tlist_GainFocus_On_ToggleOpen = 1
let g:Tlist_File_Fold_Auto_Close = 1
nnoremap <leader>t :TlistToggle<CR>
set tags+=./tags;/

"NerdCommenter
let g:NERDSpaceDelims=1
let g:NERDDefaultAlign = 'left'
let g:NERDCommentEmptyLines = 1
let NERDTreeIgnore = ['__pycache__', '.vim$', '\~$', '.*\.pyc$', 'pip-log\.txt$', 'whoosh_index',
                    \ 'xapian_index', '.*.pid', 'monitor.py', '.*-fixtures-.*.json',
                    \ '.*\.o$', 'db.db', 'tags.bak', '.*\.pdf$', '.*\.mid$',
                    \ '.*\.midi$']

"DelimitMate
imap <C-K> <Plug>delimitMateS-Tab

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
set listchars=tab:▸\ ,eol:¬,extends:❯,precedes:❮
set showbreak=↪

" From Steve Losh
" ===========================================
" Save when losing focus
au FocusLost * :silent! wall

" Resize splits when the window is resized
au VimResized * :wincmd =

" Only show cursorline in the current window and in normal mode.

augroup cline
    au!
    au WinLeave,InsertEnter * set nocursorline
    au WinEnter,InsertLeave * set cursorline
augroup END

" Trailing whitespace {{{
" Only shown when not in insert mode so I don't go insane.

augroup trailing
    au!
    au InsertEnter * :set listchars-=trail:⌴
    au InsertLeave * :set listchars+=trail:⌴
augroup END

" Make sure Vim returns to the same line when you reopen a file.
" Thanks, Amit
augroup line_return
    au!
    au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \     execute 'normal! g`"zvzz' |
        \ endif
augroup END

" Wrap
nnoremap <leader>W :set wrap!<cr>

" Toggle line numbers
nnoremap <leader>n :setlocal number!<cr>

" Clean trailing whitespace
nnoremap <leader>ww mz:%s/\s\+$//<cr>:let @/=''<cr>`z

" Diffoff
nnoremap <leader>D :diffoff!<cr>

" Keep the cursor in place while joining lines
nnoremap J mzJ`z

" Split line (sister to [J]oin lines)
" The normal use of S is covered by cc, so don't worry about shadowing it.
nnoremap S i<cr><esc>^mwgk:silent! s/\v +$//<cr>:noh<cr>`w

" Sudo to write
cnoremap w!! w !sudo tee % >/dev/null

" Unfuck my screen
nnoremap U :syntax sync fromstart<cr>:redraw!<cr>

" Use sane regexes.
nnoremap / /\v
vnoremap / /\v

" Don't move on *
nnoremap * *<c-o>

" Keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv

" Same when jumping around
nnoremap g; g;zz
nnoremap g, g,zz
nnoremap <c-o> <c-o>zz

noremap <leader>v <C-w>v


set nowrap       "Don't wrap lines
set linebreak    "Wrap lines at convenient points

" ================ Folds ============================

set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default


" ================ Completion =======================

set wildmode=list:longest
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore+=.hg,.git,.svn                    " Version control
set wildignore+=*.aux,*.out,*.toc                " LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg   " binary images
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest " compiled object files
set wildignore+=*.spl                            " compiled spelling word lists
set wildignore+=*.sw?                            " Vim swap files

set wildignore+=migrations                       " Django migrations
set wildignore+=*.pyc                            " Python byte code

set wildignore+=*.orig                           " Merge resolution files
set wildignore+=log/**
set wildignore+=tmp/**

" ================ Scrolling ========================

set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1

set incsearch                     " Find as you type search
set hlsearch                      " Highlight search terms
set ignorecase                    " Case-insensitive searching.
set smartcase                     " But case-sensitive if expression contains a capital letter.

" ================ Others ========================

" set colorcolumn=79
let loaded_matchparen = 0
set showtabline=0
set ruler
set title
" set matchpairs+=<:>
set laststatus=2
set showmatch
set matchtime=2
set esckeys
set magic
set cursorline
set guifont=Inconsolata\ LGC\ for\ Powerline\ Plus\ Nerd\ File\ Types\ Mono:h14
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar

" set t_Co=256
" let g:solarized_termcolors=256
set background=dark
try
    colorscheme solarized
catch
    colorscheme default
endtry

hi Cursor guibg=Green

vnoremap < <gv
vnoremap > >gv
" Press Space to turn off highlighting and clear any message already displayed.
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>
map <C-q> :bd<CR>

nnoremap <leader>st :Gstatus<CR>
nnoremap <leader>ev <C-w><C-v><C-l>:e $MYVIMRC<cr>
nnoremap <leader>w  :w<CR>
nnoremap Q <nop>

" Acts in command line line in bash
:cnoremap <C-a>  <Home>
:cnoremap <C-b>  <Left>
:cnoremap <C-f>  <Right>
:cnoremap <C-d>  <Delete>

set timeoutlen=250

" Only show linenumber in the current window

augroup nline
    au!
    au WinLeave * set nonumber | set norelativenumber
    au WinEnter * set number | set relativenumber
augroup END
au FileType yaml setlocal tabstop=2 expandtab shiftwidth=2 softtabstop=2
au FileType yml setlocal tabstop=2 expandtab shiftwidth=2 softtabstop=2


" autocmd FileType * 
      " \if &omnifunc != '' |
      " \call SuperTabChain(&omnifunc, "<c-p>") |
      " \call SuperTabSetDefaultCompletionType("<c-x><c-u>") |
      " \endif
