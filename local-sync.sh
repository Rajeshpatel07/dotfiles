#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Helper function to print colorful, visible step headers
print_step() {
    echo -e "\n\033[1;35m========================================\033[0m"
    echo -e "\033[1;36m[*] $1...\033[0m"
    echo -e "\033[1;35m========================================\033[0m"
}

print_step "Syncing Config Directories from ~/.config to ./"
# Loop through the directories to copy back to the local repository
for dir in hypr waybar kitty rofi mako; do
    if [ -d "$HOME/.config/$dir" ]; then
        # Remove the local folder so deleted files don't stick around
        rm -rf "./$dir"
        # Copy the live folder to the current directory
        cp -r "$HOME/.config/$dir" "./"
        echo "--> Successfully updated local $dir/"
    else
        echo -e "\033[1;33m[Warning]\033[0m Directory '$HOME/.config/$dir' not found on system. Skipping."
    fi
done

print_step "Syncing Tmux Configuration"
if [ -f "$HOME/.tmux.conf" ]; then
    # Ensure the local tmux directory exists just in case
    mkdir -p ./tmux
    # Copy the live tmux file into the local tmux folder
    cp "$HOME/.tmux.conf" "./tmux/.tmux.conf"
    echo "--> Successfully updated local tmux/.tmux.conf"
else
    echo -e "\033[1;33m[Warning]\033[0m File '$HOME/.tmux.conf' not found on system. Skipping."
fi

echo -e "\n\033[1;32m========================================\033[0m"
echo -e "\033[1;32m[✓] Local Dotfiles Successfully Synced!\033[0m"
echo -e "\033[1;32m========================================\033[0m\n"

