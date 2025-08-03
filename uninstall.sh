#!/bin/bash

# z Command Tool Uninstaller
# สคริปต์ถอนการติดตั้งสำหรับ z command tool

# สีสำหรับข้อความ (rainbow colors as preferred by user)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
ORANGE='\033[38;5;208m'
WHITE='\033[1;37m'
RESET='\033[0m'

# ฟังก์ชันแสดงข้อความ
print_success() { echo -e "${GREEN}✓ $1${RESET}"; }
print_error()   { echo -e "${RED}✗ $1${RESET}"; }
print_info()    { echo -e "${BLUE}ℹ $1${RESET}"; }
print_warning() { echo -e "${ORANGE}⚠ $1${RESET}"; }
print_header()  { echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }

# ตรวจสอบ shell ที่ใช้งาน
detect_shell() {
    local current_shell
    current_shell=$(basename "$SHELL")
    
    case "$current_shell" in
        "zsh")
            SHELL_TYPE="zsh"
            SHELL_RC="$HOME/.zshrc"
            ;;
        "bash")
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

# ลบไฟล์ที่ติดตั้ง
remove_files() {
    local install_dir="$HOME/.local/bin"
    local files_removed=0
    
    # ลบไฟล์หลัก
    if [[ -f "$install_dir/z" ]]; then
        rm "$install_dir/z"
        print_success "Removed: $install_dir/z"
        files_removed=$((files_removed + 1))
    fi
    
    # ลบไฟล์ completion
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

# ลบการตั้งค่าใน shell configuration
remove_shell_config() {
    local temp_file
    temp_file=$(mktemp)
    
    if [[ ! -f "$SHELL_RC" ]]; then
        print_warning "Shell configuration file not found: $SHELL_RC"
        return
    fi
    
    # สร้างไฟล์ชั่วคราวโดยไม่รวมบรรทัดที่เกี่ยวกับ z command tool
    local lines_removed=0
    
    while IFS= read -r line; do
        # ข้ามบรรทัดที่เกี่ยวกับ z command tool
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
    
    # แทนที่ไฟล์เดิม
    mv "$temp_file" "$SHELL_RC"
    
    if [[ $lines_removed -gt 0 ]]; then
        print_success "Removed $lines_removed z command tool configuration lines from $SHELL_RC"
    else
        print_info "No z command tool configuration found in $SHELL_RC"
    fi
}

# ถามผู้ใช้ว่าต้องการลบไฟล์ commands หรือไม่
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

# ตรวจสอบว่าไฟล์ยังคงอยู่หรือไม่
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

# แสดงข้อมูลการถอนการติดตั้ง
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

# ฟังก์ชันหลัก
main() {
    print_header
    echo -e "${WHITE}z Command Tool Uninstaller${RESET}"
    print_header
    
    # ตรวจสอบ shell
    detect_shell
    
    # ยืนยันการถอนการติดตั้ง
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
    
    # ลบไฟล์
    remove_files
    
    # ลบการตั้งค่า shell
    remove_shell_config
    
    # ถามเกี่ยวกับไฟล์ commands
    ask_remove_commands
    
    # ตรวจสอบไฟล์ที่เหลือ
    check_remaining_files
    
    # แสดงข้อมูล
    show_uninstall_info
}

# รันฟังก์ชันหลัก
main "$@" 