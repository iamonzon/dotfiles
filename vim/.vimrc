" <leader> means , 
let mapleader = ','

" vim-plug setup
filetype plugin indent on
call plug#begin()
  " Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
  Plug 'junegunn/vim-easy-align'
  " Nerdtree and icons
  Plug 'preservim/nerdtree'
  Plug 'ryanoasis/vim-devicons'
  " Fuzzy finder
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'  
  " Navigation plugins
  Plug 'terryma/vim-multiple-cursors'
call plug#end()

"NerdTreePlugin
let NERDTreeShowBookmarks=1


" Vim windows navigation
map <silent> <C-h> <C-w>h
map <silent> <C-j> <C-w>j
map <silent> <C-k> <C-w>k
map <silent> <C-l> <C-w>l

" NERDTree control-m toggle shortcut
map <silent> <C-m> :NERDTreeToggle<CR>

" NERDTree control-f find active vim window in NERDTree
map <silent> <C-f> :NERDTreeFind<CR>

" NERDTree open current location and automatically
autocmd BufEnter * lcd %:p:h
autocmd VimEnter * NERDTree

" Fuzzy Finder control-p search shortcut
map <silent> <C-p> :FZF --layout=reverse --inline-info<CR>

" Basic settings
syntax on
set encoding=utf-8
" global clipboard
set clipboard=unnamed
" tabulation set to 
set expandtab
" show existing tab with 2 spaces width
set tabstop=2
set softtabstop=2
" when indenting with '>', use 2 spaces width
set shiftwidth=2
" Hybrid relative and absolute numbers
:set number relativenumber
" do not wrap my fucking lines
:set nowrap

:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
:  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
:augroup END

" esc in insert mode
inoremap lk <esc>

" esc in command mode
cnoremap lk <C-C>

"This unsets the "last search pattern" register by hitting return
nnoremap <CR> :noh<CR><CR>

