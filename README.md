# z Command Tool

A powerful command storage and execution tool with rainbow-colored output and programmer-style interface.

## 🌈 Features

- **Persistent Command Storage**: Store and recall commands across sessions
- **Rainbow-Colored Output**: Beautiful, colorful interface for better UX
- **Programmer-Style Interface**: Clean, efficient command-line experience
- **Shell Completion**: Full tab completion support for zsh and bash
- **Cross-Platform**: Works on macOS, Linux, and other Unix-like systems
- **Smart Directory Navigation**: Special handling for `cd` commands
- **Search & Statistics**: Find commands and view usage statistics

## 🚀 Quick Installation

```bash
# Clone or download the files to your system
# Then run the installer
./install.sh
```

The installer will:
- ✅ Detect your shell (zsh/bash)
- ✅ Install to `~/.local/bin`
- ✅ Configure PATH and completion
- ✅ Test the installation
- ✅ Provide usage instructions

## 📋 Requirements

- Bash or Zsh shell
- Unix-like operating system (macOS, Linux, etc.)
- Write permissions to `~/.local/bin` and shell configuration files

## 🛠️ Manual Installation

If you prefer manual installation:

### 1. Copy Files
```bash
# Create installation directory
mkdir -p ~/.local/bin

# Copy the main script
cp z.sh ~/.local/bin/z
chmod +x ~/.local/bin/z

# Copy completion files
cp _z_completion ~/.local/bin/_z  # for zsh
cp z_bash_completion.sh ~/.local/bin/z_bash_completion.sh  # for bash
```

### 2. Configure Shell

#### For Zsh:
Add to `~/.zshrc`:
```bash
export PATH="$PATH:~/.local/bin"
fpath=($fpath ~/.local/bin)
autoload -Uz compinit
compinit
```

#### For Bash:
Add to `~/.bashrc`:
```bash
export PATH="$PATH:~/.local/bin"
source ~/.local/bin/z_bash_completion.sh
```

### 3. Reload Shell
```bash
source ~/.zshrc  # or ~/.bashrc
```

## 📖 Usage

### Basic Commands

```bash
z add "ls -la"              # Store a command
z list                       # List all stored commands
z 1                          # Execute command #1
z delete 1                   # Delete command #1
z search "grep"              # Search commands
z stats                      # Show statistics
z help                       # Show help
```

### Advanced Usage

```bash
# Store commands with descriptions
z add "cd ~/projects && ls"

# Silent storage (no confirmation)
z attach "git status"

# Search for specific patterns
z search "docker"

# View usage statistics
z stats

# Clear all commands
z clear
```

### Directory Navigation

The tool has special handling for `cd` commands:

```bash
z add "cd ~/Documents"
z 1  # Will change directory and show current path
```

## 📁 File Structure

```
zsh_script/
├── z.sh                    # Main command tool
├── _z_completion          # Zsh completion
├── z_bash_completion.sh   # Bash completion
├── install.sh             # Installer script
└── README.md             # This file
```

## 🔧 Configuration

### Commands File
- **Location**: `~/.z_commands`
- **Format**: One command per line
- **Permissions**: User read/write

### Installation Directory
- **Default**: `~/.local/bin`
- **Customizable**: Edit `install.sh` to change

## 🐛 Troubleshooting

### Command Not Found
```bash
# Check if z is in PATH
which z

# Reload shell configuration
source ~/.zshrc  # or ~/.bashrc
```

### Completion Not Working
```bash
# For zsh: Check fpath
echo $fpath

# For bash: Check completion file
ls -la ~/.local/bin/z_bash_completion.sh
```

### Permission Issues
```bash
# Make sure install directory is writable
ls -la ~/.local/bin/

# Fix permissions if needed
chmod +x ~/.local/bin/z
```

## 🔄 Uninstallation

To remove the tool:

```bash
# Remove files
rm ~/.local/bin/z
rm ~/.local/bin/_z  # zsh
rm ~/.local/bin/z_bash_completion.sh  # bash

# Remove from shell configuration
# Edit ~/.zshrc or ~/.bashrc and remove z-related lines

# Remove commands file (optional)
rm ~/.z_commands
```