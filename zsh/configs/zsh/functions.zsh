# Functions
chpwd() ls --color=auto -AhF

function mkcd {
  command mkdir $1 && cd $1
}

function tlnix {
  command nix-shell --argstr shell library ~/nix-workspaces/typelevel-nix/shell.nix
}