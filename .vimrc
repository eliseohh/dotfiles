call plug#begin('~/.vim/plugged')

Plug 'morhetz/gruvbox'
Plug 'doums/darcula'
Plug 'junegunn/fzf.vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

call plug#end()

map <leader>q gqip

nnoremap <C-p> :Files<CR>

"colorscheme gruvbox
syntax on
set t_Co=256
set cursorline
colorscheme gruvbox
set bg=dark
filetype plugin on

" Custom includes
let s:eliseo_include_path = fnamemodify(resolve(expand('<sfile>:p')), ':h').'/.vim'
execute 'set rtp+='.s:eliseo_include_path
runtime! plugin/**/*.vim

