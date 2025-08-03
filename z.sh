#! /bin/bash

# Colors for beautiful output with rainbow theme
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Rainbow colors for programmer style
RAINBOW_RED='\033[38;5;196m'
RAINBOW_ORANGE='\033[38;5;208m'
RAINBOW_YELLOW='\033[38;5;226m'
RAINBOW_GREEN='\033[38;5;46m'
RAINBOW_BLUE='\033[38;5;27m'
RAINBOW_INDIGO='\033[38;5;99m'
RAINBOW_VIOLET='\033[38;5;201m'

# Programmer style colors
CODE_GRAY='\033[38;5;240m'
CODE_LIGHT_GRAY='\033[38;5;250m'
CODE_WHITE='\033[38;5;255m'
CODE_BLUE='\033[38;5;33m'
CODE_GREEN='\033[38;5;82m'
CODE_YELLOW='\033[38;5;220m'
CODE_ORANGE='\033[38;5;208m'
CODE_RED='\033[38;5;196m'

# File to store commands
COMMANDS_FILE="$HOME/.z_commands"

# Create commands file if it doesn't exist
if [ ! -f "$COMMANDS_FILE" ]; then
    touch "$COMMANDS_FILE"
fi

# Function to print colored output with programmer style
print_success() {
    echo -e "${CODE_GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${CODE_RED}✗ $1${NC}"
}

print_info() {
    echo -e "${CODE_BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${CODE_ORANGE}⚠ $1${NC}"
}

print_header() {
    echo -e "${CODE_WHITE}$1${NC}"
}

print_rainbow_header() {
    local title="$1"
    local colors=("$RAINBOW_RED" "$RAINBOW_ORANGE" "$RAINBOW_YELLOW" "$RAINBOW_GREEN" "$RAINBOW_BLUE" "$RAINBOW_INDIGO" "$RAINBOW_VIOLET")
    local color_index=0
    
    echo -en "${CODE_WHITE}"
    
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

# Function to add a command
add_command() {
    local command="$1"
    if [ -z "$command" ]; then
        print_error "Usage: z add \"command\""
        return 1
    fi
    
    echo "$command" >> "$COMMANDS_FILE"
    local line_number=$(wc -l < "$COMMANDS_FILE")
    print_success "Command stored as #$line_number: $command"
}

# Function to list all commands with simple formatting
list_commands() {
    if [ ! -s "$COMMANDS_FILE" ]; then
        print_warning "No commands stored yet."
        print_info "Try: z add \"ls -la\""
        return 0
    fi
    
    print_rainbow_header "Stored Commands"
    
    local line_number=1
    while IFS= read -r command; do
        if [ -n "$command" ]; then
            printf "${CODE_YELLOW}%2d${NC}  ${CODE_WHITE}%s${NC}\n" "$line_number" "$command"
            ((line_number++))
        fi
    done < "$COMMANDS_FILE"
    
    echo ""
    print_info "Total: $((line_number-1)) commands"
}

# Function to execute a command by number
execute_command() {
    local line_number="$1"
    
    if [ -z "$line_number" ]; then
        print_error "Usage: z <number>"
        return 1
    fi
    
    if ! [[ "$line_number" =~ ^[0-9]+$ ]]; then
        print_error "Please provide a valid number"
        return 1
    fi
    
    local command=$(sed -n "${line_number}p" "$COMMANDS_FILE" 2>/dev/null)
    
    if [ -z "$command" ]; then
        print_error "No command found at line $line_number"
        return 1
    fi
    
    print_info "Executing: $command"
    eval "$command"
}

# Function to delete a command
delete_command() {
    local line_number="$1"
    
    if [ -z "$line_number" ]; then
        print_error "Usage: z delete <number>"
        return 1
    fi
    
    if ! [[ "$line_number" =~ ^[0-9]+$ ]]; then
        print_error "Please provide a valid number"
        return 1
    fi
    
    local command=$(sed -n "${line_number}p" "$COMMANDS_FILE" 2>/dev/null)
    
    if [ -z "$command" ]; then
        print_error "No command found at line $line_number"
        return 1
    fi
    
    # Create temporary file without the specified line
    sed "${line_number}d" "$COMMANDS_FILE" > "${COMMANDS_FILE}.tmp"
    mv "${COMMANDS_FILE}.tmp" "$COMMANDS_FILE"
    
    print_success "Deleted command #$line_number: $command"
}

# Function to clear all commands
clear_commands() {
    if [ ! -s "$COMMANDS_FILE" ]; then
        print_warning "No commands to clear."
        return 0
    fi
    
    print_warning "Are you sure you want to clear all commands? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        > "$COMMANDS_FILE"
        print_success "All commands cleared!"
    else
        print_info "Operation cancelled."
    fi
}

# Function to search commands
search_commands() {
    local search_term="$1"
    
    if [ -z "$search_term" ]; then
        print_error "Usage: z search \"term\""
        return 1
    fi
    
    if [ ! -s "$COMMANDS_FILE" ]; then
        print_warning "No commands to search."
        return 0
    fi
    
    print_rainbow_header "Search Results for: '$search_term'"
    
    # Calculate the maximum width for line numbers
    local total_lines=$(wc -l < "$COMMANDS_FILE")
    local max_width=${#total_lines}
    
    local line_number=1
    local found=false
    
    while IFS= read -r command; do
        if [ -n "$command" ] && [[ "$command" =~ $search_term ]]; then
            printf "${CODE_YELLOW}%2d${NC}  ${CODE_WHITE}%s${NC}\n" "$line_number" "$command"
            found=true
        fi
        ((line_number++))
    done < "$COMMANDS_FILE"
    
    if [ "$found" = false ]; then
        print_warning "No commands found matching '$search_term'"
    fi
}

# Function to show statistics
show_stats() {
    if [ ! -s "$COMMANDS_FILE" ]; then
        print_warning "No commands stored yet."
        return 0
    fi
    
    local total_commands=$(wc -l < "$COMMANDS_FILE")
    local unique_commands=$(sort "$COMMANDS_FILE" | uniq | wc -l)
    local most_used=$(sort "$COMMANDS_FILE" | uniq -c | sort -nr | head -1)
    
    print_rainbow_header "Statistics"
    
    echo -e "${CODE_WHITE}Total commands:${NC} ${CODE_YELLOW}$total_commands${NC}"
    echo -e "${CODE_WHITE}Unique commands:${NC} ${CODE_YELLOW}$unique_commands${NC}"
    
    if [ -n "$most_used" ]; then
        local count=$(echo "$most_used" | awk '{print $1}')
        local cmd=$(echo "$most_used" | awk '{for(i=2;i<=NF;i++) printf "%s ", $i; print ""}' | sed 's/ $//')
        echo -e "${CODE_WHITE}Most used:${NC} ${CODE_YELLOW}$cmd${NC} (${CODE_BLUE}$count${NC} times)"
    fi
    
    echo ""
}

# Function to show help with descriptions like sed
show_help() {
    print_rainbow_header "z - Command Storage and Execution Tool"
    echo ""
    echo -e "${CODE_WHITE}Usage:${NC}"
    echo -e "  ${CODE_YELLOW}z add \"command\"${NC}     -- Store a new command"
    echo -e "  ${CODE_YELLOW}z attach \"command\"${NC}  -- Store a command (silent)"
    echo -e "  ${CODE_YELLOW}z <number>${NC}          -- Execute command by number"
    echo -e "  ${CODE_YELLOW}z exec${NC}              -- Show simple command list"
    echo -e "  ${CODE_YELLOW}z exec <number>${NC}     -- Execute command by number"
    echo -e "  ${CODE_YELLOW}z list${NC}              -- List all stored commands"
    echo -e "  ${CODE_YELLOW}z ls${NC}                -- List all stored commands"
    echo -e "  ${CODE_YELLOW}z delete <number>${NC}   -- Delete command by number"
    echo -e "  ${CODE_YELLOW}z clear${NC}             -- Clear all commands"
    echo -e "  ${CODE_YELLOW}z search \"term\"${NC}    -- Search commands"
    echo -e "  ${CODE_YELLOW}z stats${NC}             -- Show statistics"
    echo -e "  ${CODE_YELLOW}z install <shell>${NC}   -- Install for bash/zsh/fish"
    echo -e "  ${CODE_YELLOW}z install-help${NC}      -- Show installation guide"
    echo -e "  ${CODE_YELLOW}z help${NC}              -- Show this help message"
    echo ""
    echo -e "${CODE_WHITE}Examples:${NC}"
    echo -e "  ${CODE_CYAN}z add \"ls -la\"${NC}"
    echo -e "  ${CODE_CYAN}z attach \"ps aux\"${NC}"
    echo -e "  ${CODE_CYAN}z 1${NC}"
    echo -e "  ${CODE_CYAN}z exec${NC}"
    echo -e "  ${CODE_CYAN}z exec 2${NC}"
    echo -e "  ${CODE_CYAN}z list${NC}"
    echo -e "  ${CODE_CYAN}z search \"grep\"${NC}"
    echo -e "  ${CODE_CYAN}z install zsh${NC}"
    echo ""
    echo -e "${CODE_WHITE}Features:${NC}"
    echo -e "  ${CODE_GREEN}✓${NC} Persistent storage"
    echo -e "  ${CODE_GREEN}✓${NC} Auto-completion"
    echo -e "  ${CODE_GREEN}✓${NC} Command search"
    echo -e "  ${CODE_GREEN}✓${NC} Statistics"
    echo -e "  ${CODE_GREEN}✓${NC} Cross-shell support"
}

z_attach() {
    local command="$1"
    if [ -z "$command" ]; then
        print_error "Usage: z attach \"command\""
        return 1
    fi

    echo "$command" >> "$COMMANDS_FILE"
}

# Function to show simple command list for execution
show_exec_list() {
    if [ ! -s "$COMMANDS_FILE" ]; then
        print_warning "No commands stored yet."
        print_info "Try: z add \"ls -la\""
        return 0
    fi
    
    print_rainbow_header "Available Commands"
    
    local line_number=1
    while IFS= read -r command; do
        if [ -n "$command" ]; then
            printf "${CODE_YELLOW}%2d${NC}  ${CODE_WHITE}%s${NC}\n" "$line_number" "$command"
            ((line_number++))
        fi
    done < "$COMMANDS_FILE"
    
    echo ""
    print_info "Usage: z exec <number> or z <number>"
    print_info "Tip: Use TAB to see available numbers"
}

# Function to execute with simple interface
exec_simple() {
    local line_number="$1"
    
    if [ -z "$line_number" ]; then
        show_exec_list
        return 0
    fi
    
    if ! [[ "$line_number" =~ ^[0-9]+$ ]]; then
        print_error "Please provide a valid number"
        return 1
    fi
    
    local command=$(sed -n "${line_number}p" "$COMMANDS_FILE" 2>/dev/null)
    
    if [ -z "$command" ]; then
        print_error "No command found at line $line_number"
        return 1
    fi
    
    print_info "Executing: $command"
    eval "$command"
}

# Function to install the script
install_script() {
    local shell_type="$1"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local script_name="z"
    
    print_rainbow_header "Installing z command"
    
    case "$shell_type" in
        "bash")
            local bashrc="$HOME/.bashrc"
            if [ ! -f "$bashrc" ]; then
                bashrc="$HOME/.bash_profile"
            fi
            
            if [ -f "$bashrc" ]; then
                # Add to PATH if not already added
                if ! grep -q "$script_dir" "$bashrc"; then
                    echo "" >> "$bashrc"
                    echo "# z command - Command Storage Tool" >> "$bashrc"
                    echo "export PATH=\"$script_dir:\$PATH\"" >> "$bashrc"
                    print_success "Added to $bashrc"
                else
                    print_info "Already in PATH"
                fi
                
                # Add completion
                if ! grep -q "source.*_z_completion" "$bashrc"; then
                    echo "source \"$script_dir/_z_completion\"" >> "$bashrc"
                    print_success "Added completion to $bashrc"
                else
                    print_info "Completion already configured"
                fi
            else
                print_error "Could not find .bashrc or .bash_profile"
                return 1
            fi
            ;;
            
        "zsh")
            local zshrc="$HOME/.zshrc"
            
            if [ -f "$zshrc" ]; then
                # Add to PATH if not already added
                if ! grep -q "$script_dir" "$zshrc"; then
                    echo "" >> "$zshrc"
                    echo "# z command - Command Storage Tool" >> "$zshrc"
                    echo "export PATH=\"$script_dir:\$PATH\"" >> "$zshrc"
                    print_success "Added to $zshrc"
                else
                    print_info "Already in PATH"
                fi
                
                # Add completion
                if ! grep -q "source.*_z_completion" "$zshrc"; then
                    echo "source \"$script_dir/_z_completion\"" >> "$zshrc"
                    print_success "Added completion to $zshrc"
                else
                    print_info "Completion already configured"
                fi
            else
                print_error "Could not find .zshrc"
                return 1
            fi
            ;;
            
        "fish")
            local fish_config="$HOME/.config/fish/config.fish"
            local fish_functions="$HOME/.config/fish/functions"
            
            # Create fish config directory if it doesn't exist
            mkdir -p "$HOME/.config/fish"
            
            if [ -f "$fish_config" ]; then
                # Add to PATH if not already added
                if ! grep -q "$script_dir" "$fish_config"; then
                    echo "" >> "$fish_config"
                    echo "# z command - Command Storage Tool" >> "$fish_config"
                    echo "set -gx PATH \"$script_dir\" \$PATH" >> "$fish_config"
                    print_success "Added to $fish_config"
                else
                    print_info "Already in PATH"
                fi
            else
                # Create fish config file
                echo "# Fish shell configuration" > "$fish_config"
                echo "" >> "$fish_config"
                echo "# z command - Command Storage Tool" >> "$fish_config"
                echo "set -gx PATH \"$script_dir\" \$PATH" >> "$fish_config"
                print_success "Created $fish_config"
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
            
        *)
            print_error "Usage: z install <shell>"
            print_info "Supported shells: bash, zsh, fish"
            return 1
            ;;
    esac
    
    echo ""
    print_success "Installation completed for $shell_type!"
    print_info "Please restart your terminal or run:"
    echo -e "  ${CODE_YELLOW}source ~/.${shell_type}rc${NC}"
    echo ""
    print_info "Then you can use:"
    echo -e "  ${CODE_YELLOW}z help${NC}"
}

# Function to show install help
show_install_help() {
    print_rainbow_header "Installation Guide"
    echo ""
    echo -e "${CODE_WHITE}Install for specific shell:${NC}"
    echo -e "  ${CODE_YELLOW}z install bash${NC}  -- Install for bash shell"
    echo -e "  ${CODE_YELLOW}z install zsh${NC}   -- Install for zsh shell"
    echo -e "  ${CODE_YELLOW}z install fish${NC}  -- Install for fish shell"
    echo ""
    echo -e "${CODE_WHITE}Manual installation:${NC}"
    echo -e "  1. Add to PATH: ${CODE_CYAN}export PATH=\"$(pwd):\$PATH\"${NC}"
    echo -e "  2. Add completion: ${CODE_CYAN}source \"$(pwd)/_z_completion\"${NC}"
    echo -e "  3. Add to your shell config file (.bashrc, .zshrc, etc.)"
    echo ""
    echo -e "${CODE_WHITE}Features:${NC}"
    echo -e "  ${CODE_GREEN}✓${NC} Auto-completion"
    echo -e "  ${CODE_GREEN}✓${NC} Persistent storage"
    echo -e "  ${CODE_GREEN}✓${NC} Cross-shell support"
}

# Load completion if available
if [ -f "$(dirname "$0")/_z_completion" ]; then
    source "$(dirname "$0")/_z_completion"
fi

# Main script logic
case "$1" in
    "add")
        add_command "$2"
        ;;
    "attach")
        z_attach "$2"
        ;;
    "list"|"ls")
        list_commands
        ;;
    "delete")
        delete_command "$2"
        ;;
    "clear")
        clear_commands
        ;;
    "search")
        search_commands "$2"
        ;;
    "stats")
        show_stats
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    "exec")
        exec_simple "$2"
        ;;
    "install")
        install_script "$2"
        ;;
    "install-help")
        show_install_help
        ;;
    "")
        show_help
        ;;
    *)
        # Check if it's a number
        if [[ "$1" =~ ^[0-9]+$ ]]; then
            execute_command "$1"
        else
            print_error "Unknown command: $1"
            print_info "Use 'z help' for usage information"
            exit 1
        fi
        ;;
esac