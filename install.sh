#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Helper function to print colorful, visible step headers
print_step() {
    echo -e "\n\033[1;34m========================================\033[0m"
    echo -e "\033[1;36m[*] $1...\033[0m"
    echo -e "\033[1;34m========================================\033[0m"
}

print_step "Enabling Hyprland COPR Repository"
sudo dnf copr enable -y lionheartp/Hyprland

print_step "Installing Core Packages"
# Added -y to automate the installation without asking for confirmation
sudo dnf install -y hyprland hyprlock waybar kitty mako rofi

print_step "Copying Dotfiles to ~/.config"
mkdir -p ~/.config
# Loop through the directories to copy
for dir in hypr waybar kitty rofi mako; do
    if [ -d "$dir" ]; then
        echo "--> Replacing existing config for $dir..."
        rm -rf ~/.config/"$dir"
        cp -r "$dir" ~/.config/
        echo "--> Successfully copied $dir/"
    else
        echo -e "\033[1;33m[Warning]\033[0m Directory '$dir/' not found in current folder. Skipping."
    fi
done

print_step "Setting up Tmux Configuration"
if [ -f "tmux/.tmux.conf" ]; then
    cp "tmux/.tmux.conf" ~/
    echo "--> Copied .tmux.conf to home directory"
else
    echo -e "\033[1;33m[Warning]\033[0m File 'tmux/.tmux.conf' not found. Skipping."
fi

print_step "Installing Tmux Plugin Manager (TPM)"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "--> TPM is already installed."
fi

print_step "Backing up and Setting up Neovim"
NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
NVIM_BAK="$HOME/.config/nvim.bak"

# Create a backup of the existing Neovim configuration
if [ -d "$NVIM_DIR" ]; then
    echo "--> Found existing Neovim config. Backing it up to ~/nvim.bak"
    rm -rf "$NVIM_BAK"
    mv "$NVIM_DIR" "$NVIM_BAK"
else
    echo "--> No existing Neovim config found. Skipping backup."
fi

echo "--> Cloning kickstart.nvim repository..."
rm -rf "$NVIM_DIR" # Failsafe clean
git clone https://github.com/Rajeshpatel07/kickstart.nvim.git "$NVIM_DIR"

echo -e "\n\033[1;32m========================================\033[0m"
echo -e "\033[1;32m[✓] Workspace Setup Successfully Completed!\033[0m"
echo -e "\033[1;32m========================================\033[0m\n"

# Final Reboot Message
echo -e "\033[1;31m=================================================================\033[0m"
echo -e "\033[1;31m  ATTENTION: PLEASE REBOOT YOUR SYSTEM NOW\033[0m"
echo -e "\033[1;31m=================================================================\033[0m"

echo -e "You can reboot by typing: \033[1;37msudo reboot\033[0m\n"
