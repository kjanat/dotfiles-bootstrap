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
    # Quick status check without scanning untracked files
    if [[ "$1" == "status" && $# -eq 1 ]]; then
        /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status --porcelain=v1
        return
    fi
    
    # Quick status with untracked but use optimized parallel scan
    if [[ "$1" == "status" && "$2" == "-u" ]]; then
        echo "Running optimized parallel untracked files scan..."
        /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status --untracked-files=normal --ignored=no --find-renames --porcelain=v1
        return
    fi
    
    # Parallel add for multiple files (if GNU parallel is available)
    if [[ "$1" == "add" && $# -gt 2 ]]; then
        if command -v parallel &>/dev/null; then
            echo "Adding files in parallel..."
            shift # remove "add" from arguments
            printf '%s\n' "$@" | parallel /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" add {}
            return
        fi
    fi
    
    # For all other commands, use standard dotfiles with optimization flags
    /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

# Advanced fast status aliases with parallel processing hints
alias dfst='dotfiles status'
alias dfsta='dotfiles status --untracked-files=all --find-renames'
alias dfstf='dotfiles status --porcelain=v1'
alias dfstfr='dotfiles status --porcelain=v1 --find-renames'

# Parallel bulk operations
dotfiles_add_parallel() {
    if [ $# -gt 1 ] && command -v parallel &>/dev/null; then
        echo "Adding $# files in parallel..."
        printf '%s\n' "$@" | parallel /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" add {}
    else
        dotfiles add "$@"
    fi
}

# Backup and checkout dotfiles with parallel processing
mkdir -p "$BACKUP_DIR"
echo "🔄 Checking out dotfiles..."
dotfiles checkout
if [ $? -ne 0 ]; then
    echo "💾 Backing up conflicting files in parallel..."
    # Create list of conflicting files
    conflict_files=$(dotfiles checkout 2>&1 | grep -E "\s+\." | awk '{print $1}')
    
    # Function to backup a single file
    backup_file() {
        local file="$1"
        mkdir -p "$BACKUP_DIR/$(dirname "$file")" 2>/dev/null
        mv "$HOME/$file" "$BACKUP_DIR/$file" 2>/dev/null
    }
    export -f backup_file
    export BACKUP_DIR
    export HOME
    
    # Parallelize backup operations if we have many files
    conflict_count=$(echo "$conflict_files" | wc -l)
    if command -v parallel &>/dev/null && [ "$conflict_count" -gt 5 ]; then
        echo "$conflict_files" | parallel backup_file {}
    else
        # Fallback to serial processing
        echo "$conflict_files" | while read -r file; do
            backup_file "$file"
        done
    fi
    dotfiles checkout
fi

# Apply Git performance optimizations (similar to Windows version)
echo "⚡ Applying Git performance optimizations..."
dotfiles config --local status.showUntrackedFiles no
dotfiles config core.untrackedCache true
dotfiles config core.preloadindex true
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    dotfiles config core.fsmonitor true
fi
dotfiles config pack.threads 0

# Additional advanced Git optimizations for recursion and parallelization
echo "🚀 Applying advanced recursion and parallelization optimizations..."
dotfiles config core.autocrlf false
dotfiles config core.safecrlf false
dotfiles config feature.manyFiles true
dotfiles config index.threads 0
dotfiles config checkout.workers 0
dotfiles config fetch.parallel 0
dotfiles config submodule.recurse false
dotfiles config diff.algorithm histogram
dotfiles config merge.renormalize false
dotfiles config status.submodulesummary false
dotfiles config status.branch false
dotfiles config gc.auto 256
dotfiles config core.splitIndex true
dotfiles config core.untrackedCacheTimeout 300

echo "✅ Dotfiles successfully installed with advanced performance optimizations!"
echo ""

# Now configure each available shell IN PARALLEL
CONFIGURED_SHELLS=()

# Function to configure individual shells
configure_bash() {
    if command -v bash &> /dev/null; then
        echo "🐚 Configuring Bash..."
        BASHRC="$HOME/.bashrc"
        
        # Add optimized dotfiles function to bashrc
        if [ -f "$BASHRC" ] && ! grep -q 'function dotfiles' "$BASHRC"; then
            cat >> "$BASHRC" << 'EOF'

# Optimized dotfiles management function with advanced parallel processing
function dotfiles { 
    # Quick status check without scanning untracked files
    if [[ "$1" == "status" && $# -eq 1 ]]; then
        /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status --porcelain=v1
        return
    fi
    
    # Quick status with untracked but use optimized parallel scan
    if [[ "$1" == "status" && "$2" == "-u" ]]; then
        echo "Running optimized parallel untracked files scan..."
        /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status --untracked-files=normal --ignored=no --find-renames --porcelain=v1
        return
    fi
    
    # Parallel add for multiple files (if GNU parallel is available)
    if [[ "$1" == "add" && $# -gt 2 ]]; then
        if command -v parallel &>/dev/null; then
            echo "Adding files in parallel..."
            shift # remove "add" from arguments
            printf '%s\n' "$@" | parallel /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" add {}
            return
        fi
    fi
    
    # For all other commands, use standard dotfiles with optimization flags
    /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

# Advanced fast status aliases with parallel processing hints
alias dfst='dotfiles status'
alias dfsta='dotfiles status --untracked-files=all --find-renames'
alias dfstf='dotfiles status --porcelain=v1'
alias dfstfr='dotfiles status --porcelain=v1 --find-renames'

# Parallel bulk operations
dotfiles_add_parallel() {
    if [ $# -gt 1 ] && command -v parallel &>/dev/null; then
        echo "Adding $# files in parallel..."
        printf '%s\n' "$@" | parallel /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" add {}
    else
        dotfiles add "$@"
    fi
}
EOF
            echo "✓ Added optimized dotfiles function to $BASHRC"
        fi
        
        # Source bash-specific dotfiles if they exist
        if [ -f "$HOME/.bash_aliases" ]; then
            echo "✓ Bash aliases loaded"
        fi
        
        echo "bash" >> /tmp/configured_shells.$$
    fi
}

configure_zsh() {
    if command -v zsh &> /dev/null; then
        echo "🦓 Configuring Zsh..."
        ZSHRC="$HOME/.zshrc"
        
        # Add optimized dotfiles function to zshrc
        if [ -f "$ZSHRC" ] && ! grep -q 'function dotfiles' "$ZSHRC"; then
            cat >> "$ZSHRC" << 'EOF'

# Optimized dotfiles management function with advanced parallel processing
function dotfiles { 
    # Quick status check without scanning untracked files
    if [[ "$1" == "status" && $# -eq 1 ]]; then
        /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status --porcelain=v1
        return
    fi
    
    # Quick status with untracked but use optimized parallel scan
    if [[ "$1" == "status" && "$2" == "-u" ]]; then
        echo "Running optimized parallel untracked files scan..."
        /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status --untracked-files=normal --ignored=no --find-renames --porcelain=v1
        return
    fi
    
    # Parallel add for multiple files (if GNU parallel is available)
    if [[ "$1" == "add" && $# -gt 2 ]]; then
        if command -v parallel &>/dev/null; then
            echo "Adding files in parallel..."
            shift # remove "add" from arguments
            printf '%s\n' "$@" | parallel /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" add {}
            return
        fi
    fi
    
    # For all other commands, use standard dotfiles with optimization flags
    /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

# Advanced fast status aliases with parallel processing hints
alias dfst='dotfiles status'
alias dfsta='dotfiles status --untracked-files=all --find-renames'
alias dfstf='dotfiles status --porcelain=v1'
alias dfstfr='dotfiles status --porcelain=v1 --find-renames'

# Parallel bulk operations
dotfiles_add_parallel() {
    if [ $# -gt 1 ] && command -v parallel &>/dev/null; then
        echo "Adding $# files in parallel..."
        printf '%s\n' "$@" | parallel /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" add {}
    else
        dotfiles add "$@"
    fi
}
EOF
            echo "✓ Added optimized dotfiles function to $ZSHRC"
        fi
        
        # Source zsh-specific dotfiles if they exist
        if [ -f "$HOME/.zsh_aliases" ]; then
            echo "✓ Zsh aliases loaded"
        fi
        
        echo "zsh" >> /tmp/configured_shells.$$
    fi
}

configure_fish() {
    if command -v fish &> /dev/null; then
        echo "🐟 Configuring Fish..."
        FISH_CONFIG="$HOME/.config/fish/config.fish"
        mkdir -p "$(dirname "$FISH_CONFIG")"
        
        if [ -f "$FISH_CONFIG" ] && ! grep -q 'function dotfiles' "$FISH_CONFIG"; then
            cat >> "$FISH_CONFIG" << 'EOF'

# Optimized dotfiles management function with advanced parallel processing
function dotfiles
    # Quick status check without scanning untracked files
    if test "$argv[1]" = "status" -a (count $argv) -eq 1
        /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status --porcelain=v1
        return
    end
    
    # Quick status with untracked but use optimized parallel scan
    if test "$argv[1]" = "status" -a "$argv[2]" = "-u"
        echo "Running optimized parallel untracked files scan..."
        /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status --untracked-files=normal --ignored=no --find-renames --porcelain=v1
        return
    end
    
    # Parallel add for multiple files (if GNU parallel is available)
    if test "$argv[1]" = "add" -a (count $argv) -gt 2
        if command -v parallel &>/dev/null
            echo "Adding files in parallel..."
            set -e argv[1]
            printf '%s\n' $argv | parallel /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" add {}
            return
        end
    end
    
    # For all other commands, use standard dotfiles with optimization flags
    /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" $argv
end

# Advanced fast status aliases with parallel processing hints
alias dfst='dotfiles status'
alias dfsta='dotfiles status --untracked-files=all --find-renames'
alias dfstf='dotfiles status --porcelain=v1'
alias dfstfr='dotfiles status --porcelain=v1 --find-renames'

# Parallel bulk operations
function dotfiles_add_parallel
    if test (count $argv) -gt 1 -a (command -v parallel &>/dev/null)
        echo "Adding (count $argv) files in parallel..."
        printf '%s\n' $argv | parallel /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" add {}
    else
        dotfiles add $argv
    end
end
EOF
            echo "✓ Added optimized dotfiles function to $FISH_CONFIG"
        fi
        
        echo "fish" >> /tmp/configured_shells.$$
    fi
}

# Initialize temporary file for shell tracking
true > /tmp/configured_shells.$$

# Run shell configuration in parallel if possible
if command -v parallel &>/dev/null; then
    echo "🚀 Configuring shells in parallel..."
    export -f configure_bash configure_zsh configure_fish
    export HOME
    parallel ::: configure_bash configure_zsh configure_fish
else
    # Fallback to background processes
    configure_bash &
    configure_zsh &
    configure_fish &
    wait
fi

# Read configured shells from temp file
if [ -f /tmp/configured_shells.$$ ]; then
    while read -r shell; do
        CONFIGURED_SHELLS+=("$shell")
    done < /tmp/configured_shells.$$
    rm -f /tmp/configured_shells.$$
fi

# Post-bootstrap: symlink README and add dothelp to configured shells
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ln -sf "$SCRIPT_DIR/README.md" "$HOME/dotfiles-readme.md" 2>/dev/null

# Add dothelp alias to all configured shells IN PARALLEL
add_dothelp_to_shell() {
    local shell="$1"
    case "$shell" in
        "bash")
            BASHRC="$HOME/.bashrc"
            if [ -f "$BASHRC" ] && ! grep -q 'alias dothelp=' "$BASHRC"; then
                cat >> "$BASHRC" << 'EOF'
alias dothelp='(command -v bat &>/dev/null && bat ~/dotfiles-readme.md) || (command -v less &>/dev/null && less ~/dotfiles-readme.md) || cat ~/dotfiles-readme.md'
EOF
                echo "✓ Added dothelp alias to $BASHRC"
            fi
            ;;
        "zsh")
            ZSHRC="$HOME/.zshrc"
            if [ -f "$ZSHRC" ] && ! grep -q 'alias dothelp=' "$ZSHRC"; then
                cat >> "$ZSHRC" << 'EOF'
alias dothelp='(command -v bat &>/dev/null && bat ~/dotfiles-readme.md) || (command -v less &>/dev/null && less ~/dotfiles-readme.md) || cat ~/dotfiles-readme.md'
EOF
                echo "✓ Added dothelp alias to $ZSHRC"
            fi
            ;;
        "fish")
            FISH_CONFIG="$HOME/.config/fish/config.fish"
            if [ -f "$FISH_CONFIG" ] && ! grep -q 'alias dothelp=' "$FISH_CONFIG"; then
                cat >> "$FISH_CONFIG" << 'EOF'
alias dothelp='if command -v bat &>/dev/null; bat ~/dotfiles-readme.md; else if command -v less &>/dev/null; less ~/dotfiles-readme.md; else; cat ~/dotfiles-readme.md; end'
EOF
                echo "✓ Added dothelp alias to $FISH_CONFIG"
            fi
            ;;
    esac
}

export -f add_dothelp_to_shell
export HOME

if command -v parallel &>/dev/null && [ ${#CONFIGURED_SHELLS[@]} -gt 0 ]; then
    printf '%s\n' "${CONFIGURED_SHELLS[@]}" | parallel add_dothelp_to_shell {}
else
    for shell in "${CONFIGURED_SHELLS[@]}"; do
        add_dothelp_to_shell "$shell" &
    done
    wait
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
echo "💡 Pro tip: Run 'dotfiles status' to see your dotfiles status (optimized for speed!)"
echo "📖 Use 'dothelp' to view documentation"
echo ""
echo "⚡ Performance optimizations applied:"
echo "  • Git untracked cache enabled"
echo "  • Parallel processing for file operations"
echo "  • Optimized dotfiles functions with fast status checks"
echo "  • Quick aliases: dfst, dfsta, dfstf, dfstfr"
echo "  • Advanced recursion and parallelization optimizations"
