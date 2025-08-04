# MyCLI

A simple CLI application built with Python and Click library.

## Features

- Main command: `mycli`
- Subcommands: `hello`, `goodbye`
- Tab completion support
- Shell completion installation
- Standalone binary (no Python required)

## Installation

### Option 1: Install from Source (Development)

1. Install dependencies:
```bash
uv sync
```

2. Install the CLI in development mode:
```bash
uv pip install -e .
```

3. Activate the virtual environment:
```bash
source .venv/bin/activate
```

### Option 2: Install Binary (Production)

1. Build the binary:
```bash
uv add pyinstaller
source .venv/bin/activate
pyinstaller --onefile --name mycli mycli/cli.py
```

2. Install using the installer script:
```bash
chmod +x install_local.sh
./install_local.sh
```

3. Install completion:
```bash
./install_completion.sh
```

The installer will:
- Copy the binary to `~/.local/bin`
- Add the directory to your PATH
- Test the installation

## Usage

### Basic Commands

```bash
# Say hello with default name
mycli hello

# Say hello to a specific person
mycli hello --name "Alice"

# Say goodbye
mycli goodbye

# Show help
mycli --help
mycli hello --help
mycli goodbye --help
```

### Tab Completion

To enable tab completion for the CLI:

```bash
# Install completion for your shell
mycli --install-completion
```

After installation, restart your terminal or run:
- For zsh: `source ~/.zshrc`
- For bash: `source ~/.bashrc`

Then you can use tab completion:
```bash
mycli <TAB>  # Shows available commands
mycli hello --<TAB>  # Shows available options
```

## Development

### Running in Development

```bash
# Activate virtual environment
source .venv/bin/activate

# Run directly with Python
python mycli/cli.py hello --name "World"

# Run with uv
uv run mycli/cli.py hello --name "World"

# Run the installed CLI
mycli hello --name "World"
```

### Building Binary

```bash
# Install PyInstaller
uv add pyinstaller

# Build binary
source .venv/bin/activate
pyinstaller --onefile --name mycli mycli/cli.py

# Install completion
./install_completion.sh
```

### Testing the CLI

```bash
# Activate virtual environment first
source .venv/bin/activate

# Test hello command
mycli hello
# Output: Hello, World!

mycli hello --name "Alice"
# Output: Hello, Alice!

# Test goodbye command
mycli goodbye
# Output: Goodbye!

# Test help
mycli --help
mycli hello --help
mycli goodbye --help

# Test completion installation
mycli --install-completion
```

### Project Structure

```
mycli/
├── mycli/
│   ├── __init__.py    # Package initialization
│   └── cli.py         # Main CLI application
├── dist/
│   └── mycli          # Built binary
├── install_local.sh    # Local installer script
├── install_completion.sh # Completion installer
├── pyproject.toml     # Project configuration
├── README.md          # This file
└── .venv/             # Virtual environment (created by uv)
```

## Requirements

- Python 3.10+
- Click library
- uv (for dependency management)
- PyInstaller (for binary builds)

## Shell Support

Currently supports:
- zsh
- bash

The completion installation automatically detects your shell and installs the appropriate completion script.

## Binary Installation

The binary installation provides several advantages:

- **No Python Required**: The binary is self-contained
- **Easy Distribution**: Single file that can be shared
- **Cross-Platform**: Works on different systems
- **Automatic Setup**: Installer handles PATH and completion

### Installer Scripts

1. **install_local.sh**: Installs from local binary
   ```bash
   ./install_local.sh
   ```

2. **install_completion.sh**: Installs tab completion
   ```bash
   ./install_completion.sh
   ```

## Example Output

```bash
$ mycli hello
Hello, World!

$ mycli hello --name "Alice"
Hello, Alice!

$ mycli goodbye
Goodbye!

$ mycli --help
Usage: mycli [OPTIONS] COMMAND [ARGS]...

  MyCLI - A simple CLI application with hello and goodbye commands.

Options:
  --install-completion  Install shell completion
  --help                Show this message and exit.

Commands:
  goodbye  Say goodbye.
  hello    Say hello to someone.
```

## Binary Features

- **Standalone**: No Python installation required
- **Fast Startup**: Optimized binary execution
- **Small Size**: ~9MB for macOS ARM64
- **Cross-Platform**: Can be built for different OS/architectures
