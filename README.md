# dotfiles
### an attempt to sync my cfgs 

Run 'install.sh' to apply all the config

> 'install.sh' runs 'update_local_functions.update_configs()' at the end of installation.


## Troubleshooting
```
if zsh is not correctly instaled, follow the steps:
    - git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    - echo 'source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

-  add packer config 
        git clone --depth 1 https://github.com/wbthomason/packer.nvim\ ~/.local/share/nvim/site/pack/packer/start/packer.nvim

```

## Commands to link things
```
ln -sf ~/.dotfiles/vim/.vim ~/.dotfiles/nvim
ln -sf ~/.dotfiles/vim/.vimrc ~/.dotfiles/nvim/init.vim
ln -sf ~/.dotfiles/lua ~/.dotfiles/nvim/lua

ln -sf ~/.dotfiles/vim/.vimrc ~/.vimrc
ln -sf ~/.dotfiles/vim/.vimrc ~/.ideavimrc
ln -sf ~/.dotfiles/nvim ~/.config/nvim
```
