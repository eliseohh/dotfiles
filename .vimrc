call plug#begin('~/.vim/plugged')

Plug 'kaicataldo/material.vim'
Plug 'dracula/vim'
Plug 'doums/darcula'
Plug 'junegunn/fzf.vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

call plug#end()

map <leader>q gqip

nnoremap <C-p> :Files<CR>

colorscheme material
filetype plugin on

" Custom includes
let s:eliseo_include_path = fnamemodify(resolve(expand('<sfile>:p')), ':h').'/.vim'
execute 'set rtp+='.s:eliseo_include_path
runtime! plugin/**/*.vim
