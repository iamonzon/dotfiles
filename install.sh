#!/bin/bash

#Get current OS
os_name=$(uname)

install_local() {
  if [ "$os_name" = "Linux" ]; then
    echo "This is a Linux system."
    if [ -f "linux_functions.sh" ]; then
      source linux_functions.sh
      linux_installation || {
        echo "Error: Linux installation failed"
        return 1
      }
      source update_local_functions.sh
      update_local_functions.main || {
        echo "Error: Update local functions failed"
        return 1
      }
    else
      echo "Error: linux_functions.sh not found"
      return 1
    fi
  elif [ "$os_name" = "Darwin" ]; then #Mac os 
    echo "This is macOS system."
    source mac_functions.sh
    macos_installation
    source update_local_functions.sh
    update_local_functions.main
  else
    echo "Unknown system: $os_name"
    return 1
  fi
}

# Execute main function
install_local