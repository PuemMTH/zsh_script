#!/bin/bash

# z Command Tool Installer
# This script installs the z command tool for your shell

# Colors for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Rainbow colors
RAINBOW_RED='\033[38;5;196m'
RAINBOW_ORANGE='\033[38;5;208m'
RAINBOW_YELLOW='\033[38;5;226m'
RAINBOW_GREEN='\033[38;5;46m'
RAINBOW_BLUE='\033[38;5;27m'
RAINBOW_INDIGO='\033[38;5;99m'
RAINBOW_VIOLET='\033[38;5;201m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_rainbow_header() {
    local title="$1"
    local colors=("$RAINBOW_RED" "$RAINBOW_ORANGE" "$RAINBOW_YELLOW" "$RAINBOW_GREEN" "$RAINBOW_BLUE" "$RAINBOW_INDIGO" "$RAINBOW_VIOLET")
    local color_index=0
    
    echo -en "${WHITE}"
    
    for ((i=0; i<${#title}; i++)); do
        local char="${title:$i:1}"
        if [[ "$char" == " " ]]; then
            echo -en " "
        else
            echo -en "${colors[$color_index]}$char${NC}"
            color_index=$(( (color_index + 1) % ${#colors[@]} ))
        fi
    done
    
    echo ""
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_rainbow_header "z Command Tool Installer"
echo ""

# Check if required files exist
if [ ! -f "$SCRIPT_DIR/z" ] || [ ! -f "$SCRIPT_DIR/z.sh" ] || [ ! -f "$SCRIPT_DIR/_z_completion" ]; then
    print_error "Required files not found in $SCRIPT_DIR"
    print_info "Make sure you're running this script from the zsh_script directory"
    exit 1
fi

# Make scripts executable
chmod +x "$SCRIPT_DIR/z" "$SCRIPT_DIR/z.sh"

print_success "Scripts made executable"

# Detect shell
CURRENT_SHELL=$(basename "$SHELL")

print_info "Detected shell: $CURRENT_SHELL"

# Ask user which shell to install for
echo ""
echo -e "${WHITE}Which shell would you like to install for?${NC}"
echo "1) zsh (recommended)"
echo "2) bash"
echo "3) fish"
echo "4) All shells"
echo "5) Manual installation"
echo ""

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        SHELL_TYPE="zsh"
        ;;
    2)
        SHELL_TYPE="bash"
        ;;
    3)
        SHELL_TYPE="fish"
        ;;
    4)
        SHELL_TYPE="all"
        ;;
    5)
        SHELL_TYPE="manual"
        ;;
    *)
        print_error "Invalid choice. Using detected shell: $CURRENT_SHELL"
        SHELL_TYPE="$CURRENT_SHELL"
        ;;
esac

# Install function
install_for_shell() {
    local shell_type="$1"
    
    case "$shell_type" in
        "zsh")
            local config_file="$HOME/.zshrc"
            if [ ! -f "$config_file" ]; then
                print_warning "Creating $config_file"
                touch "$config_file"
            fi
            
            # Add to PATH if not already added
            if ! grep -q "$SCRIPT_DIR" "$config_file"; then
                echo "" >> "$config_file"
                echo "# z command - Command Storage Tool" >> "$config_file"
                echo "export PATH=\"$SCRIPT_DIR:\$PATH\"" >> "$config_file"
                print_success "Added to $config_file"
            else
                print_info "Already in PATH"
            fi
            
            # Add completion
            if ! grep -q "source.*_z_completion" "$config_file"; then
                echo "source \"$SCRIPT_DIR/_z_completion\"" >> "$config_file"
                print_success "Added completion to $config_file"
            else
                print_info "Completion already configured"
            fi
            ;;
            
        "bash")
            local config_file="$HOME/.bashrc"
            if [ ! -f "$config_file" ]; then
                config_file="$HOME/.bash_profile"
            fi
            
            if [ ! -f "$config_file" ]; then
                print_warning "Creating $config_file"
                touch "$config_file"
            fi
            
            # Add to PATH if not already added
            if ! grep -q "$SCRIPT_DIR" "$config_file"; then
                echo "" >> "$config_file"
                echo "# z command - Command Storage Tool" >> "$config_file"
                echo "export PATH=\"$SCRIPT_DIR:\$PATH\"" >> "$config_file"
                print_success "Added to $config_file"
            else
                print_info "Already in PATH"
            fi
            
            # Add completion
            if ! grep -q "source.*_z_completion" "$config_file"; then
                echo "source \"$SCRIPT_DIR/_z_completion\"" >> "$config_file"
                print_success "Added completion to $config_file"
            else
                print_info "Completion already configured"
            fi
            ;;
            
        "fish")
            local fish_config="$HOME/.config/fish/config.fish"
            local fish_functions="$HOME/.config/fish/functions"
            
            # Create fish config directory if it doesn't exist
            mkdir -p "$HOME/.config/fish"
            
            if [ ! -f "$fish_config" ]; then
                print_warning "Creating $fish_config"
                echo "# Fish shell configuration" > "$fish_config"
            fi
            
            # Add to PATH if not already added
            if ! grep -q "$SCRIPT_DIR" "$fish_config"; then
                echo "" >> "$fish_config"
                echo "# z command - Command Storage Tool" >> "$fish_config"
                echo "set -gx PATH \"$SCRIPT_DIR\" \$PATH" >> "$fish_config"
                print_success "Added to $fish_config"
            else
                print_info "Already in PATH"
            fi
            
            # Create fish completion
            mkdir -p "$fish_functions"
            local completion_file="$fish_functions/z.fish"
            cat > "$completion_file" << 'EOF'
# Fish completion for z command
function __z_complete
    set -l commands add attach list ls delete clear search stats exec help
    set -l cur (commandline -t)
    
    if test (count $argv) -eq 1
        # First argument
        if string match -q "add attach" $argv[1]
            complete -C "ls ps df du find grep cat echo wget curl git docker"
        else if string match -q "delete exec" $argv[1]
            if test -f "$HOME/.z_commands"
                set -l numbers (seq 1 (wc -l < "$HOME/.z_commands" 2>/dev/null || echo 0))
                complete -C "$numbers"
            end
        else if string match -q "search" $argv[1]
            complete -C "ls ps grep find cat echo"
        end
    else
        # Show all commands
        complete -C "$commands"
    end
end

complete -c z -f -a "(__z_complete)"
EOF
            print_success "Created fish completion at $completion_file"
            ;;
    esac
}

# Perform installation
case "$SHELL_TYPE" in
    "zsh"|"bash"|"fish")
        print_info "Installing for $SHELL_TYPE..."
        install_for_shell "$SHELL_TYPE"
        ;;
    "all")
        print_info "Installing for all supported shells..."
        install_for_shell "zsh"
        install_for_shell "bash"
        install_for_shell "fish"
        ;;
    "manual")
        print_info "Manual installation instructions:"
        echo ""
        echo -e "${WHITE}1. Add to PATH:${NC}"
        echo -e "   ${CYAN}export PATH=\"$SCRIPT_DIR:\$PATH\"${NC}"
        echo ""
        echo -e "${WHITE}2. Add completion:${NC}"
        echo -e "   ${CYAN}source \"$SCRIPT_DIR/_z_completion\"${NC}"
        echo ""
        echo -e "${WHITE}3. Add to your shell config file (.zshrc, .bashrc, etc.)${NC}"
        echo ""
        print_info "You can also use: ./z install <shell>"
        exit 0
        ;;
esac

echo ""
print_success "Installation completed!"
echo ""
print_info "Next steps:"
echo -e "  1. ${YELLOW}Restart your terminal${NC} or run:"
echo -e "     ${CYAN}source ~/.${SHELL_TYPE}rc${NC}"
echo ""
echo -e "  2. ${YELLOW}Test the installation:${NC}"
echo -e "     ${CYAN}z help${NC}"
echo ""
echo -e "  3. ${YELLOW}Try storing a command:${NC}"
echo -e "     ${CYAN}z add \"ls -la\"${NC}"
echo ""
print_rainbow_header "Enjoy your new z command tool! 🌈" 