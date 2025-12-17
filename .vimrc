set nocompatible

call plug#begin('~/.vim/plugged')

Plug 'morhetz/gruvbox'
Plug 'doums/darcula'
Plug 'rhysd/vim-color-spring-night'
Plug 'sainnhe/everforest'
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'joerdav/templ.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'mason-org/mason.nvim'
Plug 'mason-org/mason-lspconfig.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.*', 'do': 'make install_jsregexp'} 

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'saadparwaiz1/cmp_luasnip'


call plug#end()

let s:eliseo_include_path = fnamemodify(resolve(expand('<sfile>:p')),':h').'/.vim'
execute 'set rtp+='.s:eliseo_include_path
runtime! plugin/**/*.vim
runtime! plugin/**/*.lua

set termguicolors
set background=dark
syntax on
colorscheme spring-night
set cursorline

