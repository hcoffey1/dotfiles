"if !exists('g:vscode')
" vim-plug plugin section
call plug#begin('~/.local/share/nvim/plugged')

" Colorschemes
Plug 'rafi/awesome-vim-colorschemes'
"Plug 'flazz/vim-colorschemes'

" Nerdtree
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

" Typescript Syntax Highlighting
Plug 'leafgarland/typescript-vim'

" Vim airline, status bar
Plug 'vim-airline/vim-airline'

" Themes for vim airline
Plug 'vim-airline/vim-airline-themes'

" You complete me auto completion, must be compiled in installed directory
" Plug 'Valloric/YouCompleteMe'

" Vim-Fugitive a git wrapper for vim, git commands
Plug 'tpope/vim-fugitive'

" Gitgutter, show git diff on side of file
Plug 'airblade/vim-gitgutter'

" Tab management for vim
Plug 'mkitt/tabline.vim'

" Multiline cursors
Plug 'terryma/vim-multiple-cursors'

"C# Autocomplete
"Plug 'OmniSharp/omnisharp-vim'

" Latex Support
Plug 'lervag/vimtex'

Plug 'neovimhaskell/haskell-vim'

call plug#end()

let g:ycm_autoclose_preview_window_after_completion = 1

let g:text_flavor = 'latex'
"let g:Tex_ViewRule_pdf='mupdf'
"let g:vimtex_view_method = 'mupdf'
let g:Tex_CompileRule_pdf='latexmk'
if has('nvim')
    let g:vimtex_compiler_progname = 'nvr'
endif

" Leader Key Remapping
let mapleader="\<SPACE>"

" Default Colorscheme(s)
colorscheme challenger_deep
let g:airline_theme='abstract'

" Quality of Life
set showmatch           " Show matching brackets.
" set nu rnu              " Set dynamic line number on side
set nu                  " Set line number on side
set formatoptions+=o    " Continue comment marker in new lines.
set expandtab           " Insert spaces when TAB is pressed.
set tabstop=4           " Render TABs using this many spaces.
set shiftwidth=4        " Indentation amount for < and > commands.
set hidden              " Allow buffers to be hidden

" Add indenting for file detection
filetype indent on

" Nerd Tree Toggle Hotkey
map <Leader>n :NERDTreeToggle<CR>

" Remap ESC to jj
inoremap jj <Esc>
set ttimeoutlen=10
set timeoutlen=300

" Gitgutter tracks changes faster
set updatetime=100

" Window switching hotkeys
" nnoremap <silent> <Leader>h <c-w>h
" nnoremap <silent> <Leader>j <c-w>j
" nnoremap <silent> <Leader>k <c-w>k
" nnoremap <silent> <Leader>l <c-w>l

"map <Leader>j <C-W>j
"map <Leader>k <C-W>k
"map <Leader>h <C-W>h
"map <Leader>l <C-W>l

" Use ; for commands
nnoremap ; : 

" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

map <leader>h :wincmd h<CR>
map <leader>j :wincmd j<CR>
map <leader>k :wincmd k<CR>
map <leader>l :wincmd l<CR>

:autocmd BufNewFile *.c 0r ~/.config/nvim/templates/template.c
:autocmd BufNewFile makefile 0r ~/.config/nvim/templates/makefile

syntax on
filetype plugin indent on

let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
let g:haskell_backpack = 1                " to enable highlighting of backpack keywords

"endif	
