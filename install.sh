#!/bin/bash

#Get current OS
os_name=$(uname)

install_local() {
  if ["$os_name" = "Linux" ]; then
    echo "this is a Linux system."
    source linux_functions.sh
    linux_installation
    source update_local_functions.sh
    update_local_functions.main
  else if ["$os_name" = "Darwin" ]; then #Mac os 
    echo "this is macOS system."
    source mac_functions.sh
    macos_installation
    source update_local_functions.sh
    update_local_functions.main
  else
    echo "unknown system."
  fi
}

install_local