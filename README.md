# Oh My Zsh and Powerlevel10k Installer for Fedora

This script automates the installation and setup of Oh My Zsh, the Powerlevel10k theme, and popular plugins (zsh-autosuggestions, zsh-syntax-highlighting) on Fedora-based systems.

It is designed to be safe, user-friendly, and idempotent (it can be run multiple times without side effects).

## ✨ Features

- **Automatic dependency installation**: Checks and installs zsh, git, and wget if missing
- **Oh My Zsh installation**: Sets up the popular framework for managing Zsh configuration
- **Powerlevel10k integration**: Installs and activates a fast, flexible terminal theme
- **Essential plugins included**:
  - `zsh-autosuggestions`: Suggests commands as you type
  - `zsh-syntax-highlighting`: Provides syntax highlighting
- **Safety first**: Automatically backs up your `.zshrc` before modifications
- **User confirmation**: Prompts before installing packages or changing shells
- **Idempotent operation**: Won't reinstall existing components
- **Color-coded output**: Easy-to-follow installation process

## 📋 Requirements
- Fedora-based system (tested on Fedora 40+)
- `sudo` privileges for package installation

## 🚀 Installation
Run this single command in your terminal:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/golub-kirill/ohmyzsh-autoinstall/refs/heads/main/install.sh)"
```

🛠️ Manual Installation
Clone the repository:

```bash
git clone https://github.com/golub-kirill/ohmyzsh-autoinstall.git
cd ohmyzsh-autoinstall
```

Make script executable:

```bash
chmod +x install.sh
```

Run installer:

```bash
./install.sh
```

⚙️ Post-Installation
Restart your terminal

Configure Powerlevel10k:

First launch will start the configuration wizard

If not triggered automatically, run:

```bash
p10k configure
```

Restore previous config (if needed):

```bash
mv ~/.zshrc.bak ~/.zshrc
```


🤝 Contributing
Contributions are welcome!

Fork the repository

Create your feature branch

Commit your changes

Push to the branch

Open a pull request

📄 License
This project is licensed under the MIT License - see LICENSE for details.
