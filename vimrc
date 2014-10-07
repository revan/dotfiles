"Vundle packages
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Bundle 'gmarik/vundle'
"Bundle 'tpope/vim-fugitive'
Bundle 'airblade/vim-gitgutter'
"Bundle 'altercation/vim-colors-solarized'
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/syntastic'
Bundle 'bling/vim-airline'
"Bundle 'bling/vim-bufferline'
"Bundle 'majutsushi/tagbar'
"Bundle 'ervandew/supertab'
Bundle 'kien/ctrlp.vim'
Bundle 'lepture/vim-jinja'
Bundle 'tpope/vim-markdown'
Bundle 'tpope/vim-surround'
Bundle 'suan/vim-instant-markdown'
Bundle 'editorconfig/editorconfig-vim'
"Bundle 'Valloric/YouCompleteMe'
call vundle#end()
filetype plugin indent on


"Misc settings
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
set relativenumber

set mouse=a

"set cursorline

set rtp+=/usr/lib/python3.3/site-packages/powerline/bindings/vim

"Display statusline always
set laststatus=2

set linebreak

"better filename autocomplete
set wildmode=longest,list,full

"change cursor between normal/insert
"let &t_ti.="\e[1 q"
"let &t_SI.="\e[5 q"
"let &t_EI.="\e[1 q"
"let &t_te.="\e[0 q"
"let &t_ti.="\e[?7727h"
"let &t_te.="\e[?7727l"
"noremap <Esc>O[ <Esc>
"noremap! <Esc>O[ <C-c>

"Ctrl + n to launch NERDTree
nnoremap <C-n> :NERDTreeToggle<CR>
"Close Vim if only NERDTree left
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

"Split switching
nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>

"Buffers
nnoremap <tab> :bn<CR>
nnoremap <S-tab> :bp<CR>

"Shift J and Shift K to jump more
nnoremap <S-J> }
nnoremap <S-K> {

"Don't list buffers on airline
let g:airline#extensions#bufferline#enabled = 0
"let g:airline_powerline_fonts = 1

"Completion
let g:SuperTabDefaultCompletionType = "context"

"TagBar
let g:tagbar_usearrows = 1
nnoremap <leader>l :TagbarToggle<CR>

"solarized colorscheme
"colorscheme solarized
"let g:solarized_contrast = "normal"
"set background=dark

"hide buffers instead of closing
set hidden

"Ctrl+backspace in insert to delete word
inoremap <C-BS> <C-W>

"Ctrl+S in insert to save
inoremap <C-S> <Esc>:w<CR>a

let g:gitgutter_realtime = 0" Disable gitgutter interval-based auto-update.
let g:gitgutter_eager = 0 	" Disable gitgutter update on focus/enter/tab.

if has("gui_running")
	set guioptions-=T "Hide toolbar
endif

"Highlight active line and column
set cursorline
"set cursorcolumn

"Arduino
autocmd! BufNewFile,BufRead *.pde setlocal ft=arduino

"Copy to clipboard
set clipboard=unnamedplus
