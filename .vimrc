syntax enable

set directory=~/.swapfiles//

set autoindent

set backspace=2
set smarttab
set tabstop=4
set shiftwidth=4
set noexpandtab

set ignorecase
set smartcase
set showmatch
set number

set mouse=a

set cursorline

set rtp+=/usr/lib/python3.3/site-packages/powerline/bindings/vim
set laststatus=2

set pastetoggle=<F2>

nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-Right> :tabnext<CR>

set linebreak

"don't scroll past end of file
set scrolloff=100

"better filename autocomplete
set wildmode=longest,list
