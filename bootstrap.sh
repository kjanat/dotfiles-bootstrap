#!/usr/bin/env bash

REPO="git@github.com:kjanat/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup"

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Please install git first."
    exit 1
fi

if [ -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles repo already cloned."
else
    echo "Cloning dotfiles repository..."
    git clone --bare "$REPO" "$DOTFILES_DIR"
fi

function dotfiles {
   /usr/bin/git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

mkdir -p "$BACKUP_DIR"
echo "Checking out dotfiles..."
dotfiles checkout
if [ $? -ne 0 ]; then
    echo "Backing up conflicting files..."
    dotfiles checkout 2>&1 | grep -E "\s+\." | awk '{print $1}' | while read -r file; do
        mkdir -p "$BACKUP_DIR/$(dirname "$file")" 2>/dev/null
        mv "$HOME/$file" "$BACKUP_DIR/$file" 2>/dev/null
    done
    dotfiles checkout
fi

dotfiles config --local status.showUntrackedFiles no

echo "Dotfiles successfully installed!"

# Determine shell configuration file
SHELL_RC=""
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "$(which zsh 2>/dev/null)" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ] || [ "$SHELL" = "$(which bash 2>/dev/null)" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    # Fallback detection
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_RC="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_RC="$HOME/.bashrc"
    else
        SHELL_RC="$HOME/.bashrc"  # Default
    fi
fi

# Post-bootstrap: symlink README and set help alias
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ln -sf "$SCRIPT_DIR/README.md" "$HOME/dotfiles-readme.md" 2>/dev/null

# Add dothelp alias to shell config
HELP_ALIAS="alias dothelp='(command -v bat &>/dev/null && bat ~/dotfiles-readme.md) || (command -v less &>/dev/null && less ~/dotfiles-readme.md) || cat ~/dotfiles-readme.md'"

if [ -f "$SHELL_RC" ]; then
    if ! grep -q 'alias dothelp=' "$SHELL_RC"; then
        echo "$HELP_ALIAS" >> "$SHELL_RC"
        echo "Dothelp alias added to $SHELL_RC"
    else
        echo "Dothelp alias already exists in $SHELL_RC"
    fi
else
    echo "$HELP_ALIAS" >> "$SHELL_RC"
    echo "Created $SHELL_RC with dothelp alias"
fi

echo ""
echo "Bootstrap complete! Run 'source $SHELL_RC' or restart your shell."
echo "Use 'dothelp' to view documentation."
