call plug#begin('~/.vim/plugged')

Plug 'kaicataldo/material.vim'
Plug 'dracula/vim'
Plug 'doums/darcula'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/vim-github-dashboard'
Plug 'sheerun/vim-polyglot'
Plug 'dense-analysis/ale'
Plug 'junegunn/fzf.vim'
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'airblade/vim-gitgutter'
Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'nsf/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh' }

call plug#end()

map <leader>q gqip

nnoremap <C-p> :Files<CR>

colorscheme dracula
filetype plugin on

" Custom includes
let s:eliseo_include_path = fnamemodify(resolve(expand('<sfile>:p')), ':h').'/.vim'
execute 'set rtp+='.s:eliseo_include_path
runtime! plugin/**/*.vim
