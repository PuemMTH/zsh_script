#!/bin/bash

# MyCLI Uninstaller Script
# This script removes MyCLI binary and completion

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
    local current_shell=$(basename "$SHELL")
    
    case "$current_shell" in
        "zsh")
            echo "zsh"
            ;;
        "bash")
            echo "bash"
            ;;
        *)
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

# Remove binary
remove_binary() {
    local binary_path="$INSTALL_DIR/$BINARY_NAME"
    
    if [[ -f "$binary_path" ]]; then
        print_info "Removing binary: $binary_path"
        rm -f "$binary_path"
        print_success "Binary removed"
    else
        print_warning "Binary not found: $binary_path"
    fi
}

# Remove completion
remove_completion() {
    local shell=$(detect_shell)
    local rc_file=""
    local completion_file=""
    
    case $shell in
        "zsh")
            rc_file="$HOME/.zshrc"
            completion_file="$HOME/.mycli_completion.zsh"
            ;;
        "bash")
            rc_file="$HOME/.bashrc"
            completion_file="$HOME/.mycli_completion.bash"
            ;;
        *)
            print_warning "Unknown shell: $shell"
            return 1
            ;;
    esac
    
    # Remove completion file
    if [[ -f "$completion_file" ]]; then
        print_info "Removing completion file: $completion_file"
        rm -f "$completion_file"
        print_success "Completion file removed"
    fi
    
    # Remove completion from rc file
    if [[ -f "$rc_file" ]]; then
        print_info "Removing completion from: $rc_file"
        
        # Remove MyCLI completion lines
        sed -i '' '/# MyCLI completion/,/source ~\/.mycli_completion/d' "$rc_file" 2>/dev/null || true
        sed -i '' '/eval "$(_MYCLI_COMPLETE=source_zsh mycli)"/d' "$rc_file" 2>/dev/null || true
        sed -i '' '/eval "$(_MYCLI_COMPLETE=source_bash mycli)"/d' "$rc_file" 2>/dev/null || true
        
        print_success "Completion removed from $rc_file"
    fi
}

# Check if install directory is empty
check_install_dir() {
    if [[ -d "$INSTALL_DIR" ]] && [[ -z "$(ls -A "$INSTALL_DIR" 2>/dev/null)" ]]; then
        print_info "Install directory is empty: $INSTALL_DIR"
        read -p "Remove empty install directory? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rmdir "$INSTALL_DIR"
            print_success "Install directory removed"
        fi
    fi
}

# Show uninstall summary
show_summary() {
    echo ""
    print_success "MyCLI uninstallation completed!"
    echo ""
    echo "Removed:"
    echo "  ✓ Binary: $INSTALL_DIR/$BINARY_NAME"
    echo "  ✓ Completion files"
    echo "  ✓ Completion from shell config"
    echo ""
    echo "To complete the uninstallation:"
    echo "1. Restart your terminal or run: source ~/.${shell}rc"
    echo "2. The 'mycli' command will no longer be available"
}

# Main uninstall function
main() {
    echo "🗑️  MyCLI Uninstaller"
    echo "====================="
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        exit 1
    fi
    
    # Remove binary
    remove_binary
    
    # Remove completion
    remove_completion
    
    # Check install directory
    check_install_dir
    
    # Show summary
    show_summary
}

# Run main function
main "$@" 