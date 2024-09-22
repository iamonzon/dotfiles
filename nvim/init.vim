" <leader> means , 
let mapleader = ','

let g:python3_host_prog = '/opt/homebrew/Caskroom/miniconda/base/bin/python3.10'
" smoother sidescroll 
set sidescroll=1

" vim-plug setup
filetype plugin indent on
call plug#begin()
  " Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
  Plug 'junegunn/vim-easy-align'
  " Nerdtree and icons
  Plug 'preservim/nerdtree'
  Plug 'rafi/awesome-vim-colorschemes'
  Plug 'glepnir/oceanic-material'
  Plug 'ryanoasis/vim-devicons'
  " Fuzzy finder
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'  
  " Navigation plugins
  Plug 'terryma/vim-multiple-cursors'
  " extra libs for dependencies
  Plug 'nvim-lua/plenary.nvim'
  " autosave
  Plug '907th/vim-auto-save'
  " development time coding
  "Plug 'wakatime/vim-wakatime'
" vim-makrdown + tabular
  Plug 'godlygeek/tabular' | Plug 'plasticboy/vim-markdown'
  Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install' }
  " control-shift-f
  Plug 'dyng/ctrlsf.vim'
  "vim zoom
  Plug 'Pocco81/TrueZen.nvim'
  "language tool
  Plug 'dpelle/vim-LanguageTool', {'for': 'text'}
  "python
  Plug 'davidhalter/jedi-vim'

call plug#end()

" NERDTREE write permission
set modifiable

" control-shift-f-mapping
map <silent> <C-7> :CtrlSFToggle<CR>

" maximize current window
map <silent> <C-x> :TZFocus<CR>
map <C-w><CR> :TZMinimalist<CR>
"NerdTreePlugin
let NERDTreeShowBookmarks=1
let NERDTreeSortOrder=['\/$', '*', '\.swp$',  '\.bak$', '\~$', '[[-timestamp]]']

lua require('plugins')
"
" NERDTree control-b toggle shortcut
map <silent> <C-b> :NERDTreeToggle<CR>

" NERDTree control-f find active vim window in NERDTree
map <silent> <C-p> :NERDTreeFind<CR>

" NERDTree open current location and automatically
autocmd BufEnter * lcd %:p:h

" Fuzzy Finder control-p search shortcut
map <silent> <C-f> :FZF --layout=reverse --inline-info<CR>

" Basic settings
syntax on
set shortmess-=F
set encoding=utf-8
" Some servers has issues with backup files 
set nobackup
set nowritebackup

" set guifont=GohuFont\ Nerd\ Font\ Complete:h11
set background=dark
colorscheme oceanic_material
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

" Vim windows navigation
map <silent> <C-h> <C-w>h
map <silent> <C-j> <C-w>j
map <silent> <C-k> <C-w>k
map <silent> <C-l> <C-w>l

"This unsets the "last search pattern" register by hitting return
nnoremap <CR> :noh<CR><CR>

" For local replace
nnoremap gr gd[{V%::s/<C-R>///gc<left><left><left>

" For global replace
nnoremap gR gD:%s/<C-R>///gc<left><left><left>

"Python cfg

" Show function signatures in the preview window
"let g:jedi#show_call_signatures = 'preview'

" Show documentation in the preview window
"let g:jedi#show_docstring = 'preview'
let g:mkdp_refresh_slow=1
let g:mkdp_markdown_css='~/.config/vim-markdown/github-markdown-dark.css'
function! OpenInBrave(url) abort
    echom "OpenInBrave function called with URL: " . a:url
    let l:script_path = expand("~/.config/vim-markdown/open_brave.sh")
    let l:cmd = l:script_path . " " . a:url . " &"
    echom "Executing command: " . l:cmd
    call system(l:cmd)
endfunction
"let g:mkdp_browserfunc = 'OpenInBrave'

" Resize window to the right
nnoremap <C-S-L> <C-w>5<>

" Resize window to the left
nnoremap <C-S-H> <C-w>5<>

" Resize window down
nnoremap <C-S-J> <C-w>5+

" Resize window up
nnoremap <C-S-K> <C-w>5-
