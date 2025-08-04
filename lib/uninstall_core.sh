# Uninstallation functions for z command tool

detect_shell() {
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

remove_files() {
    local install_dir="$HOME/.local/bin"
    local files_removed=0

    if [[ -f "$install_dir/z" ]]; then
        rm "$install_dir/z"
        print_success "Removed: $install_dir/z"
        files_removed=$((files_removed + 1))
    fi

    if [[ "$SHELL_TYPE" == "zsh" ]]; then
        if [[ -f "$install_dir/_z" ]]; then
            rm "$install_dir/_z"
            print_success "Removed: $install_dir/_z"
            files_removed=$((files_removed + 1))
        fi
    else
        if [[ -f "$install_dir/z_bash_completion.sh" ]]; then
            rm "$install_dir/z_bash_completion.sh"
            print_success "Removed: $install_dir/z_bash_completion.sh"
            files_removed=$((files_removed + 1))
        fi
    fi

    if [[ $files_removed -eq 0 ]]; then
        print_warning "No z command tool files found to remove"
    fi
}

remove_shell_config() {
    local temp_file
    temp_file=$(mktemp)

    if [[ ! -f "$SHELL_RC" ]]; then
        print_warning "Shell configuration file not found: $SHELL_RC"
        return
    fi

    local lines_removed=0

    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*#.*z[[:space:]]*command[[:space:]]*tool ]]; then
            lines_removed=$((lines_removed + 1))
            continue
        elif [[ "$line" =~ ^[[:space:]]*export[[:space:]]+PATH.*\.local/bin ]]; then
            lines_removed=$((lines_removed + 1))
            continue
        elif [[ "$line" =~ ^[[:space:]]*fpath.*\.local/bin ]]; then
            lines_removed=$((lines_removed + 1))
            continue
        elif [[ "$line" =~ ^[[:space:]]*source.*z_bash_completion\.sh ]]; then
            lines_removed=$((lines_removed + 1))
            continue
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$SHELL_RC"

    mv "$temp_file" "$SHELL_RC"

    if [[ $lines_removed -gt 0 ]]; then
        print_success "Removed $lines_removed z command tool configuration lines from $SHELL_RC"
    else
        print_info "No z command tool configuration found in $SHELL_RC"
    fi
}

ask_remove_commands() {
    if [[ -f "$HOME/.z_commands" ]]; then
        echo ""
        print_warning "Commands file found: $HOME/.z_commands"
        read -r -p "Do you want to remove the stored commands? (y/N) " resp
        case "$resp" in
            y|Y)
                rm "$HOME/.z_commands"
                print_success "Removed commands file: $HOME/.z_commands"
                ;;
            *)
                print_info "Commands file preserved: $HOME/.z_commands"
                ;;
        esac
    fi
}

check_remaining_files() {
    local install_dir="$HOME/.local/bin"
    local remaining_files=()

    if [[ -f "$install_dir/z" ]]; then
        remaining_files+=("$install_dir/z")
    fi

    if [[ "$SHELL_TYPE" == "zsh" ]] && [[ -f "$install_dir/_z" ]]; then
        remaining_files+=("$install_dir/_z")
    elif [[ "$SHELL_TYPE" == "bash" ]] && [[ -f "$install_dir/z_bash_completion.sh" ]]; then
        remaining_files+=("$install_dir/z_bash_completion.sh")
    fi

    if [[ ${#remaining_files[@]} -gt 0 ]]; then
        print_warning "Some files could not be removed:"
        for file in "${remaining_files[@]}"; do
            echo "  - $file"
        done
        print_info "You may need to remove them manually."
    fi
}

show_uninstall_info() {
    print_header
    print_info "Uninstallation completed!"
    print_header

    echo -e "${WHITE}What was removed:${RESET}"
    echo "  ✓ z command tool files"
    echo "  ✓ Shell configuration entries"
    echo "  ✓ Completion files"
    echo ""
    echo -e "${WHITE}Next steps:${RESET}"
    echo "1. Restart your terminal or run: source $SHELL_RC"
    echo "2. The z command will no longer be available"
    echo ""
    echo -e "${WHITE}Note:${RESET}"
    echo "  - Commands file was preserved (if you chose to keep it)"
    echo "  - You can reinstall anytime by running ./install.sh"
    print_header
}

uninstall_main() {
    print_header
    echo -e "${WHITE}z Command Tool Uninstaller${RESET}"
    print_header

    detect_shell

    echo ""
    print_warning "This will remove the z command tool from your system."
    read -r -p "Are you sure you want to continue? (y/N) " resp
    case "$resp" in
        y|Y)
            print_info "Proceeding with uninstallation..."
            ;;
        *)
            print_info "Uninstallation cancelled."
            exit 0
            ;;
    esac

    remove_files
    remove_shell_config
    ask_remove_commands
    check_remaining_files
    show_uninstall_info
}
