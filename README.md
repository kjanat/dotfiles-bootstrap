# Dotfiles Bootstrap

Bootstrap and setup scripts for managing dotfiles configuration across multiple platforms.

## Quick Start

Choose your platform and run the appropriate bootstrap command:

### Linux/macOS/Unix

```bash
curl -fsSL https://raw.githubusercontent.com/kjanat/dotfiles-bootstrap/master/bootstrap.sh | bash
```

### Windows (PowerShell)

```powershell
iex (iwr 'https://raw.githubusercontent.com/kjanat/dotfiles-bootstrap/master/bootstrap.ps1').Content
```

### Universal Script (Automatic Detection)

```bash
# This automatically detects your OS and runs the appropriate script
./bootstrap
```

## What This Does

This bootstrap system will:

1.  **Clone your dotfiles repository** as a bare Git repository to `~/.dotfiles`
2.  **Backup existing dotfiles** to `~/.dotfiles-backup` if conflicts exist
3.  **Setup Git bare repository tracking** for direct dotfiles management in your home directory
4.  **Configure ALL available shells** (Bash, Zsh, Fish, PowerShell) with dotfiles functions
5.  **Provide cross-platform compatibility** with automatic OS and shell detection

### Multi-Shell Support

The bootstrap system automatically detects and configures all available shells on your system:

-   **Bash**: Adds dotfiles function to `~/.bashrc`
-   **Zsh**: Adds dotfiles function to `~/.zshrc`
-   **Fish**: Adds dotfiles function to `~/.config/fish/config.fish`
-   **PowerShell**: Configures PowerShell profile on Windows

This means you can switch between shells seamlessly while maintaining access to your dotfiles management commands.
4. **Configure Git settings** to hide untracked files in your home directory

## Repository Structure

```
dotfiles-bootstrap/                 ← This repository (setup scripts)
├── bootstrap*                     ← Universal bootstrap scripts
├── setup*                         ← Universal setup scripts  
├── themes/                        ← Oh My Posh and shell themes
├── templates/                     ← Configuration file templates
├── scripts/                       ← Utility scripts
├── documentation/                 ← Technical documentation
├── wiki/                          ← User-friendly guides
├── DotfilesUtility.psm1          ← PowerShell utilities
└── README.md                      ← This file

dotfiles/                          ← Main dotfiles repository (configurations)
├── .zshrc                         ← ZSH configuration
├── .bashrc                        ← Bash configuration
├── .tmux.conf                     ← Tmux configuration
├── truenas.zshrc                  ← TrueNAS-specific ZSH config
├── zsh-modular/                   ← Modular ZSH system
├── themes/                        ← Shell and terminal themes
├── servstat.sh                    ← Server status script
└── README.md                      ← Dotfiles documentation
```

## Features

-   **Cross-platform support**: Linux, macOS, Windows, FreeBSD/TrueNAS
-   **Conflict resolution**: Automatic backup of existing configurations
-   **Git bare repository**: Manage dotfiles directly in your home directory
-   **Modular design**: Easy to customize and extend
-   **Comprehensive themes**: Oh My Posh themes for multiple shells
-   **Utility scripts**: Server status monitoring and system utilities

## Advanced Usage

### Manual Installation

1.  Clone this repository:

   ```bash
   git clone https://github.com/kjanat/dotfiles-bootstrap.git
   cd dotfiles-bootstrap
   ```

2.  Run the setup script for your platform:

   ```bash
   ./setup.sh        # Linux/macOS
   ./setup.ps1       # Windows PowerShell
   ./setup.bat       # Windows Command Prompt
   ./setup.csh       # C Shell
   ```

### Managing Your Dotfiles

After installation, use the `dotfiles` command to manage your configurations:

```bash
dotfiles status                    # Check status
dotfiles add .vimrc               # Add new dotfile
dotfiles commit -m "Add vimrc"    # Commit changes
dotfiles push                     # Push to remote
```

### Customization

1.  **Fork the repositories**: Fork both `dotfiles-bootstrap` and `dotfiles` repositories
2.  **Update URLs**: Modify the repository URLs in the bootstrap scripts
3.  **Add your configurations**: Add your personal dotfiles to the dotfiles repository
4.  **Customize themes**: Modify or add new themes in the `themes/` directory

## Documentation

-   [Installation Guide](wiki/Installation-Guide.md)
-   [Configuration Guide](wiki/Configuration-Guide.md)
-   [Troubleshooting](documentation/Troubleshooting.md)
-   [FAQ](wiki/FAQ.md)
-   [Platform-Specific Notes](wiki/Platform-Specific-Notes.md)

## Contributing

1.  Fork the repository
2.  Create a feature branch
3.  Make your changes
4.  Test on multiple platforms
5.  Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Repositories

-   [dotfiles](https://github.com/kjanat/dotfiles) - The actual dotfiles configurations
-   [dotfiles-bootstrap](https://github.com/kjanat/dotfiles-bootstrap) - This repository (bootstrap scripts)
