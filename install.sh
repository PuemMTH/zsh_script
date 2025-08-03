#!/bin/bash

# z Command Tool Installer
# สคริปต์ติดตั้งสำหรับ z command tool

# สีสำหรับข้อความ (rainbow colors as preferred by user)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
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

# ตรวจสอบว่าเป็น root หรือไม่
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_warning "This script should not be run as root!"
        print_info "Please run as a regular user."
        exit 1
    fi
}

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

# ตรวจสอบไฟล์ที่จำเป็น
check_files() {
    local required_files=("z.sh" "_z_completion" "z_bash_completion.sh")
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
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

# สร้างไดเรกทอรีสำหรับติดตั้ง
create_install_dir() {
    local install_dir="$HOME/.local/bin"
    
    if [[ ! -d "$install_dir" ]]; then
        mkdir -p "$install_dir"
        print_success "Created installation directory: $install_dir"
    fi
    
    INSTALL_DIR="$install_dir"
}

# ติดตั้งไฟล์
install_files() {
    local script_dir
    script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    
    # คัดลอกไฟล์หลัก
    cp "$script_dir/z.sh" "$INSTALL_DIR/z"
    chmod +x "$INSTALL_DIR/z"
    print_success "Installed z command to: $INSTALL_DIR/z"
    
    # คัดลอกไฟล์ completion
    if [[ "$SHELL_TYPE" == "zsh" ]]; then
        cp "$script_dir/_z_completion" "$INSTALL_DIR/_z"
        print_success "Installed zsh completion to: $INSTALL_DIR/_z"
    else
        cp "$script_dir/z_bash_completion.sh" "$INSTALL_DIR/z_bash_completion.sh"
        print_success "Installed bash completion to: $INSTALL_DIR/z_bash_completion.sh"
    fi
}

# เพิ่ม PATH ถ้าจำเป็น
add_to_path() {
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        print_info "Adding $INSTALL_DIR to PATH..."
        
        # เพิ่มใน shell configuration
        echo "" >> "$SHELL_RC"
        echo "# z command tool" >> "$SHELL_RC"
        echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_RC"
        
        print_success "Added PATH to $SHELL_RC"
    else
        print_info "PATH already includes $INSTALL_DIR"
    fi
}

# เพิ่มการโหลด completion
setup_completion() {
    if [[ "$SHELL_TYPE" == "zsh" ]]; then
        # ตรวจสอบว่า fpath มี INSTALL_DIR หรือไม่
        if ! grep -q "fpath=(\$fpath $INSTALL_DIR)" "$SHELL_RC" 2>/dev/null; then
            echo "fpath=(\$fpath $INSTALL_DIR)" >> "$SHELL_RC"
            echo "autoload -Uz compinit" >> "$SHELL_RC"
            echo "compinit" >> "$SHELL_RC"
            print_success "Added zsh completion setup to $SHELL_RC"
        fi
    else
        # สำหรับ bash
        if ! grep -q "source.*z_bash_completion.sh" "$SHELL_RC" 2>/dev/null; then
            echo "source $INSTALL_DIR/z_bash_completion.sh" >> "$SHELL_RC"
            print_success "Added bash completion setup to $SHELL_RC"
        fi
    fi
}

# ทดสอบการติดตั้ง
test_installation() {
    print_info "Testing installation..."
    
    # ทดสอบการโหลด z function
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
    
    # ทดสอบการสร้างไฟล์ commands
    if [[ -f "$HOME/.z_commands" ]]; then
        print_success "Commands file created: $HOME/.z_commands"
    else
        print_warning "Commands file not found (will be created on first use)"
    fi
    
    return 0
}

# แสดงข้อมูลการใช้งาน
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
    echo "  ✓ Rainbow-colored output"
    echo "  ✓ Programmer-style interface"
    echo "  ✓ Persistent command storage"
    echo "  ✓ Shell completion support"
    echo "  ✓ Cross-platform compatibility"
    echo ""
    echo -e "${WHITE}Configuration:${RESET}"
    echo "  Commands file: $HOME/.z_commands"
    echo "  Installation: $INSTALL_DIR"
    echo "  Shell config: $SHELL_RC"
    print_header
}

# ฟังก์ชันหลัก
main() {
    print_header
    echo -e "${WHITE}z Command Tool Installer${RESET}"
    print_header
    
    # ตรวจสอบ root
    check_root
    
    # ตรวจสอบไฟล์
    check_files
    
    # ตรวจสอบ shell
    detect_shell
    
    # สร้างไดเรกทอรี
    create_install_dir
    
    # ติดตั้งไฟล์
    install_files
    
    # เพิ่ม PATH
    add_to_path
    
    # ตั้งค่า completion
    setup_completion
    
    # ทดสอบการติดตั้ง
    if test_installation; then
        show_usage_info
    else
        print_error "Installation test failed. Please check the installation manually."
        exit 1
    fi
}

# รันฟังก์ชันหลัก
main "$@" 