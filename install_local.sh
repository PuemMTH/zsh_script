#!/bin/bash

# MyCLI Local Installer Script
# This script installs the local MyCLI binary with automatic completion setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BINARY_NAME="mycli"
INSTALL_DIR="$HOME/.local/bin"
SOURCE_BINARY="./dist/mycli"

# Completion will be installed using install_completion.sh

# Functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect shell
detect_shell() {
    # Check current shell more reliably
    local current_shell=$(basename "$SHELL")
    
    case "$current_shell" in
        "zsh")
            echo "zsh"
            ;;
        "bash")
            echo "bash"
            ;;
        *)
            # Fallback to environment variables
            if [[ -n "$ZSH_VERSION" ]]; then
                echo "zsh"
            elif [[ -n "$BASH_VERSION" ]]; then
                echo "bash"
            else
                echo "unknown"
            fi
            ;;
    esac
}

# Check if source binary exists
check_source_binary() {
    if [[ ! -f "$SOURCE_BINARY" ]]; then
        print_error "Source binary not found: $SOURCE_BINARY"
        print_info "Please run 'pyinstaller --onefile --name mycli mycli/cli.py' first"
        exit 1
    fi
    
    if [[ ! -x "$SOURCE_BINARY" ]]; then
        print_error "Source binary is not executable: $SOURCE_BINARY"
        exit 1
    fi
    
    print_success "Source binary found: $SOURCE_BINARY"
}

# Create installation directory
create_install_dir() {
    if [[ ! -d "$INSTALL_DIR" ]]; then
        print_info "Creating installation directory: $INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
    fi
}

# Install binary
install_binary() {
    print_info "Installing MyCLI binary..."
    
    # Copy binary to install directory
    cp "$SOURCE_BINARY" "$INSTALL_DIR/$BINARY_NAME"
    chmod +x "$INSTALL_DIR/$BINARY_NAME"
    print_success "Binary installed to: $INSTALL_DIR/$BINARY_NAME"
}

# Install completion using separate script
install_completion() {
    print_info "Installing completion using install_completion.sh..."
    ./install_completion.sh
}

# Add to PATH if not already there
add_to_path() {
    local shell=$(detect_shell)
    local rc_file=""
    
    case $shell in
        "zsh")
            rc_file="$HOME/.zshrc"
            ;;
        "bash")
            rc_file="$HOME/.bashrc"
            ;;
        *)
            print_warning "Unknown shell: $shell. Please add $INSTALL_DIR to your PATH manually."
            return 1
            ;;
    esac
    
    # Check if PATH already contains the install directory
    if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
        print_info "PATH already contains $INSTALL_DIR"
        return 0
    fi
    
    # Add to PATH
    print_info "Adding $INSTALL_DIR to PATH..."
    echo "" >> "$rc_file"
    echo "# Add local bin to PATH" >> "$rc_file"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc_file"
    print_success "Added $INSTALL_DIR to PATH"
}

# Test installation
test_installation() {
    print_info "Testing installation..."
    
    # Test if binary is executable
    if [[ -x "$INSTALL_DIR/$BINARY_NAME" ]]; then
        print_success "Binary is executable"
    else
        print_error "Binary is not executable"
        return 1
    fi
    
    # Test help command
    if "$INSTALL_DIR/$BINARY_NAME" --help >/dev/null 2>&1; then
        print_success "Binary works correctly"
    else
        print_error "Binary failed to run"
        return 1
    fi
}

# Show usage information
show_usage() {
    local shell=$(detect_shell)
    echo ""
    print_success "MyCLI installation completed successfully!"
    echo ""
    echo "To start using MyCLI:"
    echo "1. Restart your terminal or run: source ~/.${shell}rc"
    echo "2. Test the installation: mycli --help"
    echo "3. Try the commands:"
    echo "   mycli hello"
    echo "   mycli hello --name 'Your Name'"
    echo "   mycli goodbye"
    echo ""
    echo "Installation details:"
    echo "  Binary: $INSTALL_DIR/$BINARY_NAME"
    echo "  Shell config: ~/.${shell}rc"
    echo "  Completion: Auto-installed"
    echo ""
    echo "Features:"
    echo "  ✓ Standalone binary (no Python required)"
    echo "  ✓ Tab completion support"
    echo "  ✓ Cross-platform compatibility"
    echo "  ✓ Easy installation"
}

# Main installation function
main() {
    echo "🚀 MyCLI Local Installer"
    echo "========================"
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        exit 1
    fi
    
    # Check source binary
    check_source_binary
    
    # Create installation directory
    create_install_dir
    
    # Install binary
    install_binary
    
    # Add to PATH
    add_to_path
    
    # Install completion
    install_completion
    
    # Test installation
    test_installation
    
    # Show usage information
    show_usage
}

# Run main function
main "$@" 