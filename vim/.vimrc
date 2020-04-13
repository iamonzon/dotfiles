execute pathogen#infect()
syntax on
filetype plugin indent on

" esc in insert mode
inoremap lk <esc>

" esc in command mode
cnoremap lk <C-C>

" global clipboard
set clipboard=unnamedplus

" --- tabulation set to 
set expandtab
" show existing tab with 2 spaces width
set tabstop=2
set softtabstop=2
" when indenting with '>', use 2 spaces width
set shiftwidth=2

" --- Hybrid relative and absolute numbers -- 
:set number relativenumber

:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
:  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
:augroup END

" NERDTree on bundle folder https://github.com/preservim/nerdtree.git
" (pathogen)
nmap <F2> :NERDTree<CR>
nmap <F4> :vertical resize -5<CR>
nmap <F5> :vertical resize +5<CR>
nmap <F6> :resize -5<CR>
nmap <F7> :resize +5<CR>

