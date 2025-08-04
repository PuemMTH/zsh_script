# Installation functions for z command tool

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_warning "This script should not be run as root!"
        print_info "Please run as a regular user."
        exit 1
    fi
}

detect_shell() {
    if [[ -n "$SHELL_TYPE_OVERRIDE" ]]; then
        case "$SHELL_TYPE_OVERRIDE" in
            zsh)
                SHELL_TYPE="zsh"
                SHELL_RC="$HOME/.zshrc"
                ;;
            bash)
                SHELL_TYPE="bash"
                SHELL_RC="$HOME/.bashrc"
                ;;
            *)
                print_error "Unknown shell type: $SHELL_TYPE_OVERRIDE"
                exit 1
                ;;
        esac
        print_info "Shell selected by user: $SHELL_TYPE"
        print_info "Configuration file: $SHELL_RC"
        return
    fi
    local current_shell
    current_shell=$(basename "$SHELL")

    case "$current_shell" in
        zsh)
            SHELL_TYPE="zsh"
            SHELL_RC="$HOME/.zshrc"
            ;;
        bash)
            SHELL_TYPE="bash"
            SHELL_RC="$HOME/.bashrc"
            ;;
        *)
            print_warning "Unsupported shell: $current_shell"
            print_info "Defaulting to bash configuration"
            SHELL_TYPE="bash"
            SHELL_RC="$HOME/.bashrc"
            ;;
    esac

    print_info "Detected shell: $SHELL_TYPE"
    print_info "Configuration file: $SHELL_RC"
}

check_files() {
    local required_files=("z.sh" "_z_completion" "z_bash_completion.sh")
    local missing_files=()

    for file in "${required_files[@]}"; do
        if [[ ! -f "$SCRIPT_DIR/$file" ]]; then
            missing_files+=("$file")
        fi
    done

    if [[ ${#missing_files[@]} -gt 0 ]]; then
        print_error "Missing required files:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        print_info "Please run this script from the directory containing the z command tool files."
        exit 1
    fi

    print_success "All required files found"
}

create_install_dir() {
    local install_dir="$HOME/.local/bin"

    if [[ ! -d "$install_dir" ]]; then
        mkdir -p "$install_dir"
        print_success "Created installation directory: $install_dir"
    fi

    INSTALL_DIR="$install_dir"
}

install_files() {
    cp "$SCRIPT_DIR/z.sh" "$INSTALL_DIR/z"
    chmod +x "$INSTALL_DIR/z"
    print_success "Installed z command to: $INSTALL_DIR/z"

    cp "$SCRIPT_DIR/_z_completion" "$INSTALL_DIR/_z"
    cp "$SCRIPT_DIR/z_bash_completion.sh" "$INSTALL_DIR/z_bash_completion.sh"
    print_success "Installed completion files to: $INSTALL_DIR"
}

add_to_path() {
    if ! grep -q "$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
        print_info "Adding $INSTALL_DIR to PATH..."

        {
            echo ""
            echo "# z command tool"
            echo "export PATH=\"\$PATH:$INSTALL_DIR\""
        } >> "$SHELL_RC"

        print_success "Added PATH to $SHELL_RC"
    else
        print_info "PATH already configured in $SHELL_RC"
    fi
}

setup_completion() {
    if [[ "$SHELL_TYPE" == "zsh" ]]; then
        if ! grep -q "fpath=(\\$fpath $INSTALL_DIR)" "$SHELL_RC" 2>/dev/null; then
            echo "fpath=(\\$fpath $INSTALL_DIR)" >> "$SHELL_RC"
            echo "autoload -Uz compinit" >> "$SHELL_RC"
            echo "compinit" >> "$SHELL_RC"
            print_success "Added zsh completion setup to $SHELL_RC"
        fi
    else
        if ! grep -q "source.*z_bash_completion.sh" "$SHELL_RC" 2>/dev/null; then
            echo "source $INSTALL_DIR/z_bash_completion.sh" >> "$SHELL_RC"
            print_success "Added bash completion setup to $SHELL_RC"
        fi
    fi
}

test_installation() {
    print_info "Testing installation..."

    if source "$INSTALL_DIR/z" 2>/dev/null; then
        if type z >/dev/null 2>&1; then
            print_success "z command is available"
        else
            print_error "z command is not available"
            return 1
        fi
    else
        print_error "Failed to load z command"
        return 1
    fi

    if [[ -f "$HOME/.z_commands" ]]; then
        print_success "Commands file created: $HOME/.z_commands"
    else
        print_warning "Commands file not found (will be created on first use)"
    fi

    return 0
}

show_usage_info() {
    print_header
    print_info "Installation completed successfully!"
    print_header

    echo -e "${WHITE}Next steps:${RESET}"
    echo "1. Restart your terminal or run: source $SHELL_RC"
    echo "2. Test the installation: z help"
    echo ""
    echo -e "${WHITE}Usage examples:${RESET}"
    echo "  z add \"ls -la\"          # Store a command"
    echo "  z list                    # List stored commands"
    echo "  z 1                       # Execute command #1"
    echo "  z search \"grep\"          # Search commands"
    echo "  z stats                   # Show statistics"
    echo ""
    echo -e "${WHITE}Features:${RESET}"
    echo "  \xE2\x9C\x93 Rainbow-colored output"
    echo "  \xE2\x9C\x93 Programmer-style interface"
    echo "  \xE2\x9C\x93 Persistent command storage"
    echo "  \xE2\x9C\x93 Shell completion support"
    echo "  \xE2\x9C\x93 Cross-platform compatibility"
    echo ""
    echo -e "${WHITE}Configuration:${RESET}"
    echo "  Commands file: $HOME/.z_commands"
    echo "  Installation: $INSTALL_DIR"
    echo "  Shell config: $SHELL_RC"
    print_header
}

install_main() {
    print_header
    echo -e "${WHITE}z Command Tool Installer${RESET}"
    print_header

    SHELL_TYPE_OVERRIDE=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --shell)
                shift
                if [[ "$1" == "zsh" || "$1" == "bash" ]]; then
                    SHELL_TYPE_OVERRIDE="$1"
                else
                    print_error "--shell must be 'zsh' or 'bash'"
                    exit 1
                fi
                ;;
            *)
                print_warning "Unknown argument: $1"
                ;;
        esac
        shift
    done

    check_root
    check_files
    detect_shell
    create_install_dir
    install_files
    add_to_path
    setup_completion

    if test_installation; then
        show_usage_info
    else
        print_error "Installation test failed. Please check the installation manually."
        exit 1
    fi
}
