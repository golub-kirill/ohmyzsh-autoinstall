#!/bin/bash

# ==============================================================================
# Improved installer for Oh My Zsh, Powerlevel10k, and plugins.
#
# Features:
# - Idempotent: Won't reinstall existing components
# - Safe: Creates backup of .zshrc before modifying
# - Readable: Color-coded output for better clarity
# - Flexible: Easy to add new plugins
# ==============================================================================

# Exit immediately if any command fails
set -e

# --- Color variables ---
COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m' # No Color

# --- Check if command exists ---
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- Install Zsh plugins ---
# Arguments: $1 = plugin name, $2 = Git repository URL
install_plugin() {
    local plugin_name=$1
    local plugin_url=$2
    local plugin_path="${ZSH_CUSTOM}/plugins/${plugin_name}"

    if [ -d "$plugin_path" ]; then
        echo -e "${COLOR_GREEN}--> Plugin '${plugin_name}' already installed.${COLOR_NC}"
    else
        echo -e "${COLOR_BLUE}--> Installing plugin '${plugin_name}'...${COLOR_NC}"
        git clone "$plugin_url" "$plugin_path"
    fi
}

# --- Step 1: Check and install system dependencies ---
echo -e "${COLOR_BLUE}### Step 1: Checking required system packages...${COLOR_NC}"

packages_to_install=()
if ! command_exists zsh; then
    packages_to_install+=("zsh")
fi
if ! command_exists git; then
    packages_to_install+=("git")
fi
if ! command_exists wget; then
    packages_to_install+=("wget")
fi

if [ ${#packages_to_install[@]} -eq 0 ]; then
    echo -e "${COLOR_GREEN}--> All required packages are already installed.${COLOR_NC}"
else
    echo -e "${COLOR_YELLOW}--> Missing packages detected: ${packages_to_install[*]}${COLOR_NC}"
    read -p "--> Do you want to install them? (y/N): " choice
    case "$choice" in
      y|Y )
        sudo dnf install -y "${packages_to_install[@]}"
        ;;
      * )
        echo -e "${COLOR_RED}--> Installation canceled by user. Exiting.${COLOR_NC}"
        exit 1
        ;;
    esac
fi

# --- Step 2: Install Oh My Zsh ---
echo -e "\n${COLOR_BLUE}### Step 2: Verifying Oh My Zsh installation...${COLOR_NC}"

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${COLOR_GREEN}--> Oh My Zsh is already installed. Skipping.${COLOR_NC}"
else
    echo -e "${COLOR_BLUE}--> Installing Oh My Zsh...${COLOR_NC}"
    # Run installer in non-interactive mode (shell change will be done manually)
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo -e "${COLOR_GREEN}--> Oh My Zsh successfully installed.${COLOR_NC}"
fi

# Set ZSH_CUSTOM path (Oh My Zsh defines this variable)
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# --- Step 3: Install Powerlevel10k theme and plugins ---
echo -e "\n${COLOR_BLUE}### Step 3: Installing theme and plugins...${COLOR_NC}"

# Powerlevel10k theme
if [ -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
    echo -e "${COLOR_GREEN}--> Powerlevel10k theme already installed.${COLOR_NC}"
else
    echo -e "${COLOR_BLUE}--> Installing Powerlevel10k theme...${COLOR_NC}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"
fi

# Install plugins using our function
install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"


# --- Step 4: Configure ~/.zshrc ---
echo -e "\n${COLOR_BLUE}### Step 4: Configuring ~/.zshrc...${COLOR_NC}"

ZSHRC_FILE="$HOME/.zshrc"
ZSHRC_BACKUP_FILE="$HOME/.zshrc.bak"

# Create backup before making changes
echo -e "${COLOR_YELLOW}--> Creating .zshrc backup at ${ZSHRC_BACKUP_FILE}...${COLOR_NC}"
cp "$ZSHRC_FILE" "$ZSHRC_BACKUP_FILE"

# Set Powerlevel10k theme
echo -e "${COLOR_BLUE}--> Setting Powerlevel10k theme in .zshrc...${COLOR_NC}"
sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC_FILE"

# Configure plugins
PLUGINS_LINE='plugins=(git zsh-autosuggestions zsh-syntax-highlighting)'
echo -e "${COLOR_BLUE}--> Configuring plugins in .zshrc...${COLOR_NC}"
if grep -q "^plugins=" "$ZSHRC_FILE"; then
    # Replace existing plugins line
    sed -i "s/^plugins=(.*)/${PLUGINS_LINE}/" "$ZSHRC_FILE"
else
    # Append if plugins line doesn't exist
    echo "${PLUGINS_LINE}" >> "$ZSHRC_FILE"
fi

echo -e "${COLOR_GREEN}--> .zshrc successfully configured.${COLOR_NC}"

# --- Step 5: Set Zsh as default shell ---
echo -e "\n${COLOR_BLUE}### Step 5: Setting Zsh as default shell...${COLOR_NC}"

if [[ "$SHELL" != *"zsh"* ]]; then
    echo -e "${COLOR_YELLOW}--> Your current shell is: $SHELL.${COLOR_NC}"
    read -p "--> Do you want to set zsh as default shell? (y/N): " choice
    case "$choice" in
      y|Y )
        if chsh -s "$(which zsh)"; then
          echo -e "${COLOR_GREEN}--> Default shell changed to zsh.${COLOR_NC}"
          echo -e "${COLOR_YELLOW}--> IMPORTANT: You must log out and back in for changes to take effect.${COLOR_NC}"
        else
          echo -e "${COLOR_RED}--> ERROR: Failed to change shell. Please do it manually.${COLOR_NC}"
        fi
        ;;
      * )
        echo -e "${COLOR_YELLOW}--> Shell change skipped. You can do it later with: chsh -s \$(which zsh)${COLOR_NC}"
        ;;
    esac
else
    echo -e "${COLOR_GREEN}--> Zsh is already your default shell.${COLOR_NC}"
fi

# --- Final instructions ---
echo -e "\n\n${COLOR_GREEN}#=====================================================#"
echo "#                                                    #"
echo "#          Installation completed successfully!      #"
echo "#                                                    #"
echo "#      github.com/golub-kirill/ohmyzsh-autoinstall   #"
echo "#                                                    #"
echo "#                                                    #"
echo "#=====================================================#${COLOR_NC}"
echo
echo "--> Please close and reopen your terminal to start using Zsh."
echo "--> On first launch, Powerlevel10k configuration should start automatically."
echo "    If not, you can run it manually with:"
echo -e "    ${COLOR_YELLOW}p10k configure${COLOR_NC}"
echo
