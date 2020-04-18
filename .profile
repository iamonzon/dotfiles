#!/bin/zsh
# usage: it loads all configs for given applications (specified in bootstrap)

BKUP=~/.dotfiles-bak
mkdir -p $BKUP

mv -f ~/.profile $BKUP/ 2>/dev/null
mv -f ~/.zshrc $BKUP/ 2>/dev/null
mv -f ~/.zsh_custom_cfg $BKUP/ 2>/dev/null
mv -f ~/.p10k.zsh $BKUP/ 2>/dev/null
mv -f ~/.aliases $BKUP/ 2>/dev/null
mv -f ~/.vimrc $BKUP/ 2>/dev/null
mv -f ~/.tilix $BKUP/ 2>/dev/null

DOTFILES_PATH=~/.dotfiles
ZSH_SRC_PATH=$DOTFILES_PATH/zsh

cp "$DOTFILES_PATH"/.profile ~/.profile 2>/dev/null
cp "$ZSH_SRC_PATH"/.zshrc ~/.zshrc 2>/dev/null
cp "$ZSH_SRC_PATH"/.zsh_custom_cfg ~/.zsh_custom_cfg 2>/dev/null
cp "$ZSH_SRC_PATH"/.p10k.zsh ~/.p10k.zsh 2>/dev/null
cp "$ZSH_SRC_PATH"/.aliases ~/.aliases 2>/dev/null
cp "$DOTFILES_PATH"/tilix/.tilix ~/.tilix 2>/dev/null
cp "$DOTFILES_PATH"/vim/.vimrc ~/.vimrc 2>/dev/null

#sudo ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh 2>/dev/null

dconf load /com/gexperts/Tilix/ < $DOTFILES_PATH/tilix/tilix.dconf

echo profile reloaded.
