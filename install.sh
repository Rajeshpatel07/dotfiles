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
sudo dnf install -y hyprland hyprlock waybar kitty mako rofi nemo

# ==============================================================================
# NEW CONFIGURATION: GO & RUST BINARY INSTALLATIONS
# ==============================================================================
print_step "Checking for Go & Installing bluetuith"
if command -v go >/dev/null 2>&1; then
    if [ -f "$HOME/go/bin/bluetuith" ]; then
        echo "--> bluetuith is already installed in ~/go/bin. Skipping."
    else
        echo "--> Go compiler found. Installing bluetuith globally..."
        go install github.com/darkhz/bluetuith@latest
        echo "--> bluetuith successfully installed!"
    fi
else
    echo -e "\033[1;33m[Warning]\033[0m Go compiler not found on system. Skipping bluetuith installation.\033[0m"
fi

print_step "Checking for Cargo & Installing wiremix"
if command -v cargo >/dev/null 2>&1; then
    if [ -f "$HOME/.cargo/bin/wiremix" ]; then
        echo "--> wiremix is already installed in ~/.cargo/bin. Skipping."
    else
        echo "--> Cargo found. Installing wiremix..."
        cargo install wiremix
        echo "--> wiremix successfully installed!"
    fi
else
    echo -e "\033[1;33m[Warning]\033[0m Cargo (Rust) not found on system. Skipping wiremix installation.\033[0m"
fi
# ==============================================================================

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

print_step "Custom Wallpaper Setup"
echo -ne "\033[1;35mDo you want to use a custom wallpaper as your background? (y/n): \033[0m"
read -r use_wallpaper

if [[ "$use_wallpaper" =~ ^[Yy]$ ]]; then
    echo -e "\n\033[1;36mEnter the file path to your image:\033[0m"
    echo -ne "Placeholder/Example: [ \033[1;37m~/Downloads/bg.jpg\033[0m ]\n--> "
    read -r wallpaper_path

    # Expand tilde (~) manually if the user uses it in their input path
    wallpaper_path="${wallpaper_path/#\~/$HOME}"

    # Check if the file exists
    if [ -f "$wallpaper_path" ]; then
        echo "--> Copying wallpaper to system directory..."
        sudo mkdir -p /usr/share/hypr
        sudo cp "$wallpaper_path" /usr/share/hypr/wall0.png
        echo "--> Wallpaper successfully applied!"
        echo -e "\033[1;33m[Warning] This wallpaper change is only temporary and will be removed if you upgrade hyprland.\033[0m"
    else
        echo -e "\033[1;31m[Error] Target file '$wallpaper_path' does not exist. Skipping wallpaper configuration.\033[0m"
    fi
else
    echo "--> Skipping custom wallpaper setup."
fi

print_step "System Memory Optimization"
echo -ne "\033[1;35mWant to optimize memory usage on the system? (y/n): \033[0m"
read -r optimize_mem

if [[ "$optimize_mem" =~ ^[Yy]$ ]]; then
    # Look for the optimization script in the current folder
    if [ -f "./optimize_services.sh" ]; then
        echo "--> Found memory optimization script. Launching..."
        chmod +x ./optimize_services.sh
        ./optimize_services.sh
    else
        echo -e "\033[1;31m[Error] 'optimize_services.sh' not found in the current folder. Skipping.\033[0m"
    fi
else
    echo "--> Skipping memory optimization."
fi

echo -e "\n\033[1;32m========================================\033[0m"
echo -e "\033[1;32m[✓] Workspace Setup Successfully Completed!\033[0m"
echo -e "\033[1;32m========================================\033[0m\n"

# Final Reboot Message
echo -e "\033[1;31m=================================================================\033[0m"
echo -e "\033[1;31m  ATTENTION: PLEASE REBOOT YOUR SYSTEM NOW\033[0m"
echo -e "\033[1;31m=================================================================\033[0m"

echo -e "You can reboot by typing: \033[1;37msudo reboot\033[0m\n"
