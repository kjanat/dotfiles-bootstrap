#!/usr/bin/env bash

# Multi-shell bootstrap - configure ALL available shells
# This gives users the flexibility to use any shell they have installed

echo "🚀 Multi-Shell Dotfiles Bootstrap"
echo "Detecting and configuring all available shells..."
echo ""

# Clone dotfiles repository first (common for all shells)
REPO="git@github.com:kjanat/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup"

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "❌ Error: git is not installed. Please install git first."
    exit 1
fi

if [ -d "$DOTFILES_DIR" ]; then
    echo "✓ Dotfiles repo already cloned."
else
    echo "📦 Cloning dotfiles repository..."
    git clone --bare "$REPO" "$DOTFILES_DIR"
fi

# Common dotfiles function for all shells
function dotfiles {
   /usr/bin/git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

# Backup and checkout dotfiles
mkdir -p "$BACKUP_DIR"
echo "🔄 Checking out dotfiles..."
dotfiles checkout
if [ $? -ne 0 ]; then
    echo "💾 Backing up conflicting files..."
    dotfiles checkout 2>&1 | grep -E "\s+\." | awk '{print $1}' | while read -r file; do
        mkdir -p "$BACKUP_DIR/$(dirname "$file")" 2>/dev/null
        mv "$HOME/$file" "$BACKUP_DIR/$file" 2>/dev/null
    done
    dotfiles checkout
fi

dotfiles config --local status.showUntrackedFiles no
echo "✅ Dotfiles successfully installed!"
echo ""

# Now configure each available shell
CONFIGURED_SHELLS=()

# Configure Bash if available
if command -v bash &> /dev/null; then
    echo "🐚 Configuring Bash..."
    BASHRC="$HOME/.bashrc"
    
    # Add dotfiles function to bashrc
    if [ -f "$BASHRC" ] && ! grep -q 'function dotfiles' "$BASHRC"; then
        echo "" >> "$BASHRC"
        echo "# Dotfiles management function" >> "$BASHRC"
        echo 'function dotfiles { /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }' >> "$BASHRC"
        echo "✓ Added dotfiles function to $BASHRC"
    fi
    
    # Source bash-specific dotfiles if they exist
    if [ -f "$HOME/.bash_aliases" ]; then
        echo "✓ Bash aliases loaded"
    fi
    
    CONFIGURED_SHELLS+=("bash")
fi

# Configure Zsh if available  
if command -v zsh &> /dev/null; then
    echo "🦓 Configuring Zsh..."
    ZSHRC="$HOME/.zshrc"
    
    # Add dotfiles function to zshrc
    if [ -f "$ZSHRC" ] && ! grep -q 'function dotfiles' "$ZSHRC"; then
        echo "" >> "$ZSHRC"
        echo "# Dotfiles management function" >> "$ZSHRC"
        echo 'function dotfiles { /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }' >> "$ZSHRC"
        echo "✓ Added dotfiles function to $ZSHRC"
    fi
    
    # Source zsh-specific dotfiles if they exist
    if [ -f "$HOME/.zsh_aliases" ]; then
        echo "✓ Zsh aliases loaded"
    fi
    
    CONFIGURED_SHELLS+=("zsh")
fi

# Configure Fish if available
if command -v fish &> /dev/null; then
    echo "🐟 Configuring Fish..."
    FISH_CONFIG="$HOME/.config/fish/config.fish"
    mkdir -p "$(dirname "$FISH_CONFIG")"
    
    if [ -f "$FISH_CONFIG" ] && ! grep -q 'function dotfiles' "$FISH_CONFIG"; then
        echo "" >> "$FISH_CONFIG"
        echo "# Dotfiles management function" >> "$FISH_CONFIG"
        echo 'function dotfiles; /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" $argv; end' >> "$FISH_CONFIG"
        echo "✓ Added dotfiles function to $FISH_CONFIG"
    fi
    
    CONFIGURED_SHELLS+=("fish")
fi

# Post-bootstrap: symlink README and add dothelp to configured shells
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ln -sf "$SCRIPT_DIR/README.md" "$HOME/dotfiles-readme.md" 2>/dev/null

# Add dothelp alias to all configured shells
HELP_ALIAS="alias dothelp='(command -v bat &>/dev/null && bat ~/dotfiles-readme.md) || (command -v less &>/dev/null && less ~/dotfiles-readme.md) || cat ~/dotfiles-readme.md'"

# Add to bash if configured
if [[ " ${CONFIGURED_SHELLS[*]} " =~ " bash " ]]; then
    BASHRC="$HOME/.bashrc"
    if [ -f "$BASHRC" ] && ! grep -q 'alias dothelp=' "$BASHRC"; then
        echo "$HELP_ALIAS" >> "$BASHRC"
        echo "✓ Added dothelp alias to $BASHRC"
    fi
fi

# Add to zsh if configured
if [[ " ${CONFIGURED_SHELLS[*]} " =~ " zsh " ]]; then
    ZSHRC="$HOME/.zshrc"
    if [ -f "$ZSHRC" ] && ! grep -q 'alias dothelp=' "$ZSHRC"; then
        echo "$HELP_ALIAS" >> "$ZSHRC"
        echo "✓ Added dothelp alias to $ZSHRC"
    fi
fi

# Add to fish if configured (different syntax)
if [[ " ${CONFIGURED_SHELLS[*]} " =~ " fish " ]]; then
    FISH_CONFIG="$HOME/.config/fish/config.fish"
    FISH_HELP_ALIAS="alias dothelp='if command -v bat &>/dev/null; bat ~/dotfiles-readme.md; else if command -v less &>/dev/null; less ~/dotfiles-readme.md; else; cat ~/dotfiles-readme.md; end'"
    if [ -f "$FISH_CONFIG" ] && ! grep -q 'alias dothelp=' "$FISH_CONFIG"; then
        echo "$FISH_HELP_ALIAS" >> "$FISH_CONFIG"
        echo "✓ Added dothelp alias to $FISH_CONFIG"
    fi
fi

# Summary
echo ""
echo "🎉 Bootstrap Complete!"
echo "Configured shells: ${CONFIGURED_SHELLS[*]}"
echo ""
echo "You can now use 'dotfiles' command in any of these shells:"
for shell in "${CONFIGURED_SHELLS[@]}"; do
    echo "  • $shell"
done
echo ""
echo "💡 Pro tip: Run 'dotfiles status' to see your dotfiles status"
echo "📖 Use 'dothelp' to view documentation"
echo ""
echo "🔄 Restart your shell or run 'source ~/.bashrc' (or ~/.zshrc) to start using the commands"
