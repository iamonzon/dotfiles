#!/bin/bash

#Get current OS
os_name=$(uname)

if ["$os_name" = "Linux" ]; then
  echo "this is a Linux system."
  source linux_functions
  linux_installation
else if ["$os_name" = "Darwin" ]; then #Mac os 
  echo "this is macOS system."
  source mac_functions
  macos_installation
else
  echo "unknown system."
fi
