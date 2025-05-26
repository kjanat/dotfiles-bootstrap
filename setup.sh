#!/usr/bin/env bash

# Multi-shell advanced setup - configure ALL available shells with advanced features
# This gives users the flexibility to use any shell they have installed with full functionality

# --- Configuration ---
DOTFILES_DIR="$HOME/.dotfiles"
ZSHRC_SOURCE="$DOTFILES_DIR/.zshrc" # Location of the .zshrc in your dotfiles repo
ZSHRC_DEST="$HOME/.zshrc"           # Destination for the .zshrc in the home directory

# --- Helper Functions ---
print_info() {
    echo -e "\\033[1;34m[INFO]\\033[0m $1"
}

print_success() {
    echo -e "\\033[1;32m[SUCCESS]\\033[0m $1"
}

print_warning() {
    echo -e "\\033[1;33m[WARNING]\\033[0m $1"
}

print_error() {
    echo -e "\\033[1;31m[ERROR]\\033[0m $1"
}

# Optimized dotfiles function
dotfiles() {
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

# --- Performance Optimizations ---
apply_git_performance_optimizations() {
    print_info "⚡ Applying Git performance optimizations..."
    
    if [ -d "$DOTFILES_DIR" ]; then
        dotfiles config core.untrackedCache true
        dotfiles config core.preloadindex true
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            dotfiles config core.fsmonitor true
        fi
        dotfiles config pack.threads 0
        print_success "Git performance optimizations applied"
    else
        print_warning "Dotfiles directory not found, skipping Git optimizations"
    fi
}

# --- Parallel Package Management ---
# Function to install packages in parallel when safe
install_packages_parallel() {
    local packages=("$@")
    
    if [ ${#packages[@]} -eq 0 ]; then
        return 0
    fi
    
    print_info "📦 Installing packages: ${packages[*]}"
    
    # Check if we can parallelize based on package manager
    case "$PACKAGE_MANAGER" in
        apt-get | apt)
            # APT can handle multiple packages in one command efficiently
            if $IS_SUDO_NEEDED; then
                sudo "$PACKAGE_MANAGER" install -y "${packages[@]}"
            else
                "$PACKAGE_MANAGER" install -y "${packages[@]}"
            fi
            ;;
        brew)
            # Homebrew can install multiple packages in parallel
            "$PACKAGE_MANAGER" install "${packages[@]}"
            ;;
        pacman)
            # Pacman can handle multiple packages efficiently
            if $IS_SUDO_NEEDED; then
                sudo "$PACKAGE_MANAGER" -S --noconfirm "${packages[@]}"
            else
                "$PACKAGE_MANAGER" -S --noconfirm "${packages[@]}"
            fi
            ;;
        *)
            # For other package managers, install sequentially but with background jobs if possible
            if command -v parallel &>/dev/null; then
                export -f install_single_package
                export PACKAGE_MANAGER IS_SUDO_NEEDED
                printf '%s\n' "${packages[@]}" | parallel install_single_package {}
            else
                # Fallback to background jobs
                for package in "${packages[@]}"; do
                    install_single_package "$package" &
                done
                wait
            fi
            ;;
    esac
}

# Helper function for single package installation
install_single_package() {
    local package="$1"
    case "$PACKAGE_MANAGER" in
        yum)
            if $IS_SUDO_NEEDED; then
                sudo "$PACKAGE_MANAGER" install -y "$package"
            else
                "$PACKAGE_MANAGER" install -y "$package"
            fi
            ;;
        dnf)
            if $IS_SUDO_NEEDED; then
                sudo "$PACKAGE_MANAGER" install -y "$package"
            else
                "$PACKAGE_MANAGER" install -y "$package"
            fi
            ;;
        zypper)
            if $IS_SUDO_NEEDED; then
                sudo "$PACKAGE_MANAGER" install -y "$package"
            else
                "$PACKAGE_MANAGER" install -y "$package"
            fi
            ;;
        pkg)
            if $IS_SUDO_NEEDED; then
                sudo "$PACKAGE_MANAGER" install -y "$package"
            else
                "$PACKAGE_MANAGER" install -y "$package"
            fi
            ;;
    esac
}

# --- Main Setup Logic ---
print_info "🛠️  Starting multi-shell advanced dotfiles setup for Unix-like systems..."

# Track configured shells
CONFIGURED_SHELLS=()

# Multi-shell configuration setup
print_info "🐚 Configuring advanced features for all available shells..."

# Configure Bash if available
if command -v bash &>/dev/null; then
    print_info "Setting up Bash advanced features..."
    BASHRC="$HOME/.bashrc"

    # Add dotfiles function to bashrc if not present
    if [ -f "$BASHRC" ] && ! grep -q 'function dotfiles {' "$BASHRC" 2>/dev/null; then
        echo -e "\\n# Dotfiles alias managed by kjanat/dotfiles" >>"$BASHRC"
        echo "function dotfiles {" >>"$BASHRC"
        echo "   git --git-dir=\\"$DOTFILES_DIR\\" --work-tree=\\"$HOME\\" \\"\$@\\"" >>"$BASHRC"
        echo "}" >>"$BASHRC"
        print_success "Dotfiles function added to $BASHRC"
    elif [ -f "$BASHRC" ]; then
        print_success "Dotfiles function already exists in $BASHRC"
    fi

    CONFIGURED_SHELLS+=("bash")
fi

# Configure Fish if available
if command -v fish &>/dev/null; then
    print_info "Setting up Fish advanced features..."
    FISH_CONFIG="$HOME/.config/fish/config.fish"
    mkdir -p "$(dirname "$FISH_CONFIG")"

    # Add dotfiles function to fish config if not present
    if [ -f "$FISH_CONFIG" ] && ! grep -q 'function dotfiles' "$FISH_CONFIG" 2>/dev/null; then
        echo -e "\\n# Dotfiles function managed by kjanat/dotfiles" >>"$FISH_CONFIG"
        echo 'function dotfiles; /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" $argv; end' >>"$FISH_CONFIG"
        print_success "Dotfiles function added to $FISH_CONFIG"
    elif [ -f "$FISH_CONFIG" ]; then
        print_success "Dotfiles function already exists in $FISH_CONFIG"
    fi

    CONFIGURED_SHELLS+=("fish")
fi

# --- Package Installation ---
print_info "Checking for and installing essential packages (git, zsh, vim, curl)..."
PACKAGE_MANAGER=""
if command -v apt-get &>/dev/null; then
    PACKAGE_MANAGER="apt-get"
elif command -v apt &>/dev/null; then
    PACKAGE_MANAGER="apt"
elif command -v yum &>/dev/null; then
    PACKAGE_MANAGER="yum"
elif command -v dnf &>/dev/null; then
    PACKAGE_MANAGER="dnf"
elif command -v pacman &>/dev/null; then
    PACKAGE_MANAGER="pacman"
elif command -v zypper &>/dev/null; then
    PACKAGE_MANAGER="zypper"
elif command -v pkg &>/dev/null; then
    PACKAGE_MANAGER="pkg"
elif command -v brew &>/dev/null; then
    PACKAGE_MANAGER="brew"
fi

HAS_UPDATE_FUNCTION=false
HAS_INSTALL_FUNCTION=false
# shellcheck disable=SC2034 # IS_SUDO_NEEDED is used by UPDATE_PKGS_IMPL/INSTALL_PKGS_IMPL
IS_SUDO_NEEDED=true # Default to using sudo

# Define placeholder functions that will be called if no specific manager logic is found
UPDATE_PKGS_IMPL() { :; } # No-op by default
INSTALL_PKGS_IMPL() { print_warning "No supported package manager found. Cannot install packages."; }

case "$PACKAGE_MANAGER" in
apt-get | apt)
    HAS_UPDATE_FUNCTION=true
    UPDATE_PKGS_IMPL() { if $IS_SUDO_NEEDED; then sudo "$PACKAGE_MANAGER" update; else "$PACKAGE_MANAGER" update; fi; }
    HAS_INSTALL_FUNCTION=true
    INSTALL_PKGS_IMPL() { install_packages_parallel git zsh vim curl; }
    ;;
yum)
    # yum update can be verbose/interactive; often skipped in scripts.
    # HAS_UPDATE_FUNCTION remains false.
    HAS_INSTALL_FUNCTION=true
    INSTALL_PKGS_IMPL() { install_packages_parallel git zsh vim curl; }
    ;;
dnf)
    HAS_UPDATE_FUNCTION=true # dnf check-update is generally non-intrusive
    UPDATE_PKGS_IMPL() { if $IS_SUDO_NEEDED; then sudo "$PACKAGE_MANAGER" check-update >/dev/null || true; else "$PACKAGE_MANAGER" check-update >/dev/null || true; fi; }
    HAS_INSTALL_FUNCTION=true
    INSTALL_PKGS_IMPL() { install_packages_parallel git zsh vim curl; }
    ;;
pacman)
    HAS_UPDATE_FUNCTION=true
    UPDATE_PKGS_IMPL() { if $IS_SUDO_NEEDED; then sudo "$PACKAGE_MANAGER" -Syu --noconfirm; else "$PACKAGE_MANAGER" -Syu --noconfirm; fi; }
    HAS_INSTALL_FUNCTION=true
    INSTALL_PKGS_IMPL() { install_packages_parallel git zsh vim curl; }
    ;;
zypper)
    HAS_UPDATE_FUNCTION=true
    UPDATE_PKGS_IMPL() { if $IS_SUDO_NEEDED; then sudo "$PACKAGE_MANAGER" refresh; else "$PACKAGE_MANAGER" refresh; fi; }
    HAS_INSTALL_FUNCTION=true
    INSTALL_PKGS_IMPL() { install_packages_parallel git zsh vim curl; }
    ;;
pkg) # FreeBSD
    HAS_UPDATE_FUNCTION=true
    UPDATE_PKGS_IMPL() { if $IS_SUDO_NEEDED; then sudo "$PACKAGE_MANAGER" update -q; else "$PACKAGE_MANAGER" update -q; fi; }
    HAS_INSTALL_FUNCTION=true
    INSTALL_PKGS_IMPL() { install_packages_parallel git zsh vim curl; }
    ;;
brew) # macOS
    IS_SUDO_NEEDED=false
    HAS_UPDATE_FUNCTION=true
    UPDATE_PKGS_IMPL() { "$PACKAGE_MANAGER" update; }
    HAS_INSTALL_FUNCTION=true
    INSTALL_PKGS_IMPL() { install_packages_parallel git zsh vim curl; }
    ;;
*)
    # HAS_UPDATE_FUNCTION and HAS_INSTALL_FUNCTION remain false.
    # INSTALL_PKGS_IMPL will print the warning via the else block below.
    ;;
esac

if $HAS_UPDATE_FUNCTION; then
    print_info "Updating package lists..."
    UPDATE_PKGS_IMPL
fi

if $HAS_INSTALL_FUNCTION; then
    print_info "Installing packages (git, zsh, vim, curl)..."
    INSTALL_PKGS_IMPL
    if [ -n "$PACKAGE_MANAGER" ]; then # Check if a package manager was actually found
        print_success "Essential packages checked/installed."
    fi
else
    # This case is hit if PACKAGE_MANAGER was not found (HAS_INSTALL_FUNCTION is false)
    INSTALL_PKGS_IMPL # This will print the "No supported package manager" warning
fi

# Apply Git performance optimizations
apply_git_performance_optimizations

# Configure Zsh if available (with advanced features)
if command -v zsh &>/dev/null; then
    print_info "🦓 Setting up Zsh advanced configuration..."
    zsh_path=$(which zsh)

    # Symlink .zshrc from dotfiles repository
    if [ -f "$ZSHRC_SOURCE" ]; then
        if [ -L "$ZSHRC_DEST" ] && [ "$(readlink "$ZSHRC_DEST")" = "$ZSHRC_SOURCE" ]; then
            print_success ".zshrc is already correctly symlinked to your dotfiles."
        elif [ -f "$ZSHRC_DEST" ] && [ ! -L "$ZSHRC_DEST" ]; then # Exists and is a regular file
            print_warning ".zshrc already exists and is not a symlink. Backing it up to $ZSHRC_DEST.bak"
            mv "$ZSHRC_DEST" "$ZSHRC_DEST.bak"
            ln -s "$ZSHRC_SOURCE" "$ZSHRC_DEST"
            print_success ".zshrc backed up and symlinked to your dotfiles version."
        elif [ -L "$ZSHRC_DEST" ] && [ ! -e "$ZSHRC_DEST" ]; then # Is a broken symlink
            print_warning "Removing broken symlink at $ZSHRC_DEST"
            rm "$ZSHRC_DEST"
            ln -s "$ZSHRC_SOURCE" "$ZSHRC_DEST"
            print_success ".zshrc symlinked from your dotfiles."
        elif [ ! -e "$ZSHRC_DEST" ]; then # Does not exist at all
            ln -s "$ZSHRC_SOURCE" "$ZSHRC_DEST"
            print_success ".zshrc symlinked from your dotfiles."
        else
            # This case might be reached if $ZSHRC_DEST exists but isn't a regular file or a symlink we handled
            print_warning "Could not automatically symlink $ZSHRC_DEST. Current status is unclear. Manual check may be needed."
        fi
    else
        print_warning "$ZSHRC_SOURCE not found in your dotfiles. Cannot symlink .zshrc."
        print_warning "A basic $ZSHRC_DEST will be created if one doesn't exist, or your existing one will be used."
        if [ ! -e "$ZSHRC_DEST" ]; then # Use -e to check for any existence (file, dir, symlink)
            print_info "Creating a minimal $ZSHRC_DEST..."
            echo "# Minimal .zshrc created by setup.sh" >"$ZSHRC_DEST"
            echo "HISTFILE=~/.zsh_history" >>"$ZSHRC_DEST"
            echo "HISTSIZE=10000" >>"$ZSHRC_DEST"
            echo "SAVEHIST=10000" >>"$ZSHRC_DEST"
            echo "setopt appendhistory notify" >>"$ZSHRC_DEST"
            echo "PROMPT='%F{blue}%n@%m%f:%F{green}%~%f %# '" >>"$ZSHRC_DEST"
            # Add dotfiles alias here too for the minimal .zshrc case
            echo -e "\\n# Dotfiles alias managed by kjanat/dotfiles" >>"$ZSHRC_DEST"
            echo "function dotfiles {" >>"$ZSHRC_DEST"
            echo "   git --git-dir=\\"$DOTFILES_DIR\\" --work-tree=\\"$HOME\\" \\"\$@\\"" >>"$ZSHRC_DEST"
            echo "}" >>"$ZSHRC_DEST"
            print_success "Minimal .zshrc created with dotfiles alias."
        fi
    fi

    # Set Zsh as default shell if not already
    current_user_shell=$(getent passwd "$USER" | cut -d: -f7)

    if [ "$current_user_shell" != "$zsh_path" ]; then
        print_info "Current shell is $current_user_shell. Attempting to change to Zsh ($zsh_path)..."
        # Check if zsh_path is in /etc/shells
        if ! grep -Fxq "$zsh_path" /etc/shells; then
            print_warning "Zsh path ($zsh_path) not found in /etc/shells."
            print_info "Attempting to add $zsh_path to /etc/shells. This may require sudo."
            if command -v sudo &>/dev/null; then
                echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
                if grep -Fxq "$zsh_path" /etc/shells; then
                    print_success "$zsh_path added to /etc/shells."
                else
                    print_error "Failed to add $zsh_path to /etc/shells. chsh might fail."
                fi
            else
                print_warning "sudo not available. Cannot add $zsh_path to /etc/shells automatically."
                print_warning "Please add it manually (e.g., echo '$zsh_path' | sudo tee -a /etc/shells) and then run 'chsh -s $zsh_path'."
            fi
        fi

        # Attempt to change shell
        if [ "$(id -u)" -eq 0 ]; then # If running as root
            chsh -s "$zsh_path" "$USER"
        elif command -v sudo &>/dev/null; then
            sudo chsh -s "$zsh_path" "$USER"
        else
            print_warning "sudo is not available. Cannot change shell automatically."
            print_warning "Please change your shell to Zsh manually by running: chsh -s $zsh_path"
        fi

        # Verify change (best effort, as it might require re-login)
        new_user_shell=$(getent passwd "$USER" | cut -d: -f7)
        if [ "$new_user_shell" = "$zsh_path" ]; then
            print_success "Default shell changed to Zsh for user $USER. Please log out and log back in for the change to take effect."
        else
            # Check if chsh command itself failed or if it's just a matter of re-login
            # Try to run chsh non-interactively with sudo to see if it would ask for a password
            if command -v sudo &>/dev/null && ! sudo -n chsh -s "$zsh_path" "$USER" &>/dev/null && [ "$(id -u)" -ne 0 ]; then
                print_warning "Failed to change default shell. This might be due to password prompt for 'sudo chsh'."
                print_warning "Try running 'sudo chsh -s $zsh_path $USER' manually."
            elif [ "$(id -u)" -ne 0 ] && ! chsh -s "$zsh_path" "$USER" &>/dev/null && ! command -v sudo &>/dev/null; then
                # This case means user is not root, chsh without sudo failed, and sudo is not available.
                print_warning "Failed to change default shell. 'chsh' command may have failed without sudo, and sudo is not available."
                print_warning "Try running 'chsh -s $zsh_path $USER' manually. Ensure $zsh_path is in /etc/shells."
            else
                # If chsh didn't obviously fail due to sudo password or lack of sudo, it might just need re-login.
                print_warning "Default shell change to Zsh may require a log out and log back in to reflect."
                print_warning "Current default reported as: $new_user_shell. Expected: $zsh_path."
            fi
            print_warning "Ensure Zsh ($zsh_path) is listed in /etc/shells. If not, add it and try 'chsh -s $(which zsh)' again."
        fi
    else
        print_success "Zsh is already the default shell."
    fi

    CONFIGURED_SHELLS+=("zsh")
else
    print_warning "Zsh is not installed. Skipping Zsh-specific configuration."
    print_warning "Please install Zsh manually if you wish to use it."
fi

# Summary
echo ""
print_success "🎉 Multi-shell advanced setup complete!"
print_info "Configured shells: ${CONFIGURED_SHELLS[*]}"
echo ""
print_info "Available features for configured shells:"
for shell in "${CONFIGURED_SHELLS[@]}"; do
    echo "  • $shell: dotfiles function, shell-specific configurations"
done
echo ""
print_info "📖 Please restart your shell or source your configuration files:"
if [[ " ${CONFIGURED_SHELLS[*]} " =~ " bash " ]]; then
    print_info "  • Bash: source ~/.bashrc"
fi
if [[ " ${CONFIGURED_SHELLS[*]} " =~ " zsh " ]]; then
    print_info "  • Zsh: source ~/.zshrc (or log out/in if set as default)"
fi
if [[ " ${CONFIGURED_SHELLS[*]} " =~ " fish " ]]; then
    print_info "  • Fish: restart fish shell"
fi
print_info ""
print_info "💡 Use 'dotfiles status' to check your dotfiles repository status"
