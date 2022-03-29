syntax on
filetype plugin indent on

" esc in insert mode
inoremap lk <esc>

" esc in command mode
cnoremap lk <C-C>

" global clipboard
if system('uname -s') == "Darwin\n"
  set clipboard=unnamed "OSX
else
  set clipboard=unnamedplus "Linux
endif

" do not wrap my fucking lines
:set nowrap

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

