#!/bin/zsh
# usage: it loads all configs for given applications (specified in bootstrap)

BKUP=~/.dotfiles-bak
mkdir $BKUP

mv ~/.zshrc $BKUP/
mv ~/.zsh_custom_cfg $BKUP/
mv ~/.p10k.zsh $BKUP/
mv ~/.aliases $BKUP/
mv ~/.vimrc $BKUP/

DOTFILES_PATH=~/.dotfiles
ZSH_SRC_PATH=$DOTFILES_PATH/zsh

ln "$ZSH_SRC_PATH"/.zshrc ~/.zshrc
ln "$ZSH_SRC_PATH"/.zsh_custom_cfg ~/.zsh_custom_cfg 
ln "$ZSH_SRC_PATH"/.p10k.zsh ~/.p10k.zsh
ln "$ZSH_SRC_PATH"/.aliases ~/.aliases
ln "$DOTFILES_PATH"/tilix/.tilix ~/.tilix
ln "$DOTFILES_PATH"/vim/.vimrc ~/.vimrc

dconf load /com/gexperts/Tilix/ < $DOTFILES_PATH/tilix/tilix.dconf

ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh
