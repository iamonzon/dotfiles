{
  home.file.".ideavimrc".text = ''
    " Leader key
    let mapleader=" "

    " --- Extensions ---
    set surround
    set which-key
    set argtextobj
    set textobj-entire
    set highlightedyank
    set NERDTree
    set commentary
    set matchit
    set exchange
    set easymotion

    " --- Vim options ---
    set scrolloff=8
    set incsearch
    set ignorecase
    set smartcase
    set relativenumber
    set number

    " --- Keymaps ---
    " Disable macro recording
    nmap q <Nop>

    " Quick save
    nmap WW :w<CR>

    " Close tab
    nmap QQ :action CloseContent<CR>

    " Swap ; and :
    nmap ; :
    nmap : ;

    " Navigate back/forward
    nmap <leader>h :action Back<CR>
    nmap <leader>l :action Forward<CR>

    " Rename symbol
    nmap <leader>r :action RenameElement<CR>

    " Go to definition / implementation / references
    nmap <leader>nd :action GotoDeclaration<CR>
    nmap <leader>ni :action GotoImplementation<CR>
    nmap <leader>nu :action FindUsages<CR>

    " Diagnostics
    nmap <leader>dl :action ActivateProblemsViewToolWindow<CR>
    nmap <leader>gl :action ShowErrorDescription<CR>

    " Format document
    nmap <leader>lf :action ReformatCode<CR>

    " Toggle terminal
    nmap <leader>tt :action ActivateTerminalToolWindow<CR>

    " Toggle project view
    nmap <C-b> :action ActivateProjectToolWindow<CR>

    " Fold / unfold recursively
    nmap <leader>- zC
    nmap <leader>= zO

    " Toggle inlay hints
    nmap <leader>i :action ToggleInlayHintsGloballyAction<CR>

    " Definition in split
    nmap <leader>pl :action SplitVertically<CR>:action GotoDeclaration<CR>
    nmap <leader>pj :action SplitHorizontally<CR>:action GotoDeclaration<CR>

    " Toggle maximize
    nmap <leader>px :action HideAllWindows<CR>

    " Clear search highlight
    nmap <Esc> :noh<CR><Esc>

    " View git change
    nmap <leader>gv :action VcsShowCurrentChangeMarker<CR>
  '';
}
