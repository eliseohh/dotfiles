set number 
set visualbell
set encoding=utf-8
set formatoptions=tcqrn

set expandtab
set shiftwidth=2
set tabstop=2

autocmd Syntax * syntax match NBSP "[\xa0]" containedin=ALL | highlight link NBSP Error
set backspace=indent,eol,start
set matchpairs+=<:> " use % to jump between pairs

set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣
set list

nnoremap j gj
nnoremap k gk

set hidden
set ttyfast
set laststatus=2
set showmode
set showcmd

set hlsearch
set incsearch
set ignorecase
set smartcase
set showmatch
set omnifunc=syntaxcomplete#Complete

set complete-=i
