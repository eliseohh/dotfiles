set nocompatible

call plug#begin('~/.vim/plugged')

Plug 'morhetz/gruvbox'
Plug 'doums/darcula'
Plug 'rhysd/vim-color-spring-night'
Plug 'sainnhe/everforest'
Plug 'junegunn/fzf.vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

call plug#end()

let s:eliseo_include_path = fnamemodify(resolve(expand('<sfile>:p')),':h').'/.vim'
execute 'set rtp+='.s:eliseo_include_path
runtime! plugin/**/*.vim

set termguicolors
set background=dark
syntax on
colorscheme spring-night
set cursorline
