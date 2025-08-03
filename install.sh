#!/usr/bin/env bash

# z Command Tool Installer
# สีสำหรับข้อความ
_RED='\033[0;31m'
_GREEN='\033[0;32m'
_YELLOW='\033[1;33m'
_BLUE='\033[0;34m'
_ORANGE='\033[38;5;208m'
_WHITE='\033[1;37m'
_RESET='\033[0m'

_print_success() { echo -e "${_GREEN}✓ $1${_RESET}"; }
_print_error()   { echo -e "${_RED}✗ $1${_RESET}"; }
_print_info()    { echo -e "${_BLUE}ℹ $1${_RESET}"; }
_print_warning() { echo -e "${_ORANGE}⚠ $1${_RESET}"; }

# ตรวจสอบว่าเป็น root หรือไม่
if [ "$EUID" -eq 0 ]; then
    _print_warning "ไม่แนะนำให้รัน installer ด้วย root privileges"
    read -r -p "ต้องการดำเนินการต่อหรือไม่? (y/N) " resp
    case "$resp" in
        y|Y) ;;
        *) exit 1 ;;
    esac
fi

# กำหนด path สำหรับติดตั้ง
INSTALL_DIR="$HOME/.local/bin"
ZSH_COMPLETION_DIR="$HOME/.zsh/completions"
BASH_COMPLETION_DIR="$HOME/.bash_completion.d"

_print_info "เริ่มการติดตั้ง z Command Tool..."

# สร้าง directory ที่จำเป็น
mkdir -p "$INSTALL_DIR"
mkdir -p "$ZSH_COMPLETION_DIR"
mkdir -p "$BASH_COMPLETION_DIR"

# คัดลอกไฟล์ z.sh ไปยัง INSTALL_DIR
if [ -f "z.sh" ]; then
    cp z.sh "$INSTALL_DIR/z"
    chmod +x "$INSTALL_DIR/z"
    _print_success "คัดลอก z.sh ไปยัง $INSTALL_DIR/z"
else
    _print_error "ไม่พบไฟล์ z.sh ในไดเรกทอรีปัจจุบัน"
    exit 1
fi

# สร้าง tab completion สำหรับ zsh
cat > "$ZSH_COMPLETION_DIR/_z" << 'EOF'
#compdef z

_z() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        '1: :->cmds' \
        '*:: :->args'

    case "$state" in
        cmds)
            local -a commands
            commands=(
                'add:Store a new command'
                'attach:Store a command silently'
                'list:List all stored commands'
                'ls:List all stored commands'
                'delete:Delete command by number'
                'clear:Clear all commands'
                'search:Search stored commands'
                'stats:Show statistics'
                'help:Show help message'
            )
            _describe -t commands 'z commands' commands
            ;;
        args)
            case "$words[1]" in
                add|attach)
                    _message "Enter command to store"
                    ;;
                delete)
                    _message "Enter command number to delete"
                    ;;
                search)
                    _message "Enter search pattern"
                    ;;
            esac
            ;;
    esac
}

compdef _z z
EOF

_print_success "สร้าง zsh completion ไฟล์"

# สร้าง tab completion สำหรับ bash
cat > "$BASH_COMPLETION_DIR/z" << 'EOF'
_z_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ ${cur} == * ]] ; then
        case "${prev}" in
            z)
                opts="add attach list ls delete clear search stats help"
                COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                return 0
                ;;
            add|attach)
                COMPREPLY=( $(compgen -c -- ${cur}) )
                return 0
                ;;
            delete)
                # แสดงหมายเลขคำสั่งที่มีอยู่
                if [ -f "$HOME/.z_commands" ]; then
                    local numbers
                    numbers=$(awk '{print NR}' "$HOME/.z_commands" | tr '\n' ' ')
                    COMPREPLY=( $(compgen -W "${numbers}" -- ${cur}) )
                fi
                return 0
                ;;
            search)
                COMPREPLY=( $(compgen -c -- ${cur}) )
                return 0
                ;;
        esac
    fi
}

complete -F _z_completion z
EOF

_print_success "สร้าง bash completion ไฟล์"

# สร้างไฟล์สำหรับ source ใน shell configuration
_print_info "สร้างไฟล์ configuration..."

# สำหรับ zsh
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "source.*z" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# z Command Tool" >> "$HOME/.zshrc"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc"
        echo "autoload -U compinit" >> "$HOME/.zshrc"
        echo "compinit -d \$HOME/.zcompdump" >> "$HOME/.zshrc"
        echo "fpath=(\$HOME/.zsh/completions \$fpath)" >> "$HOME/.zshrc"
        _print_success "เพิ่ม configuration ลงใน ~/.zshrc"
    else
        _print_warning "พบ z configuration ใน ~/.zshrc แล้ว"
    fi
else
    _print_warning "ไม่พบ ~/.zshrc - กรุณาเพิ่ม PATH และ completion เอง"
fi

# สำหรับ bash
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "source.*z" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# z Command Tool" >> "$HOME/.bashrc"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
        echo "if [ -f \$HOME/.bash_completion.d/z ]; then" >> "$HOME/.bashrc"
        echo "    . \$HOME/.bash_completion.d/z" >> "$HOME/.bashrc"
        echo "fi" >> "$HOME/.bashrc"
        _print_success "เพิ่ม configuration ลงใน ~/.bashrc"
    else
        _print_warning "พบ z configuration ใน ~/.bashrc แล้ว"
    fi
else
    _print_warning "ไม่พบ ~/.bashrc - กรุณาเพิ่ม PATH และ completion เอง"
fi

# ตรวจสอบ PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    _print_warning "PATH ไม่รวม $INSTALL_DIR"
    _print_info "กรุณาเพิ่ม export PATH=\"\$HOME/.local/bin:\$PATH\" ใน shell configuration ของคุณ"
fi

_print_success "การติดตั้งเสร็จสิ้น!"
_print_info ""
_print_info "การใช้งาน:"
_print_info "1. รีสตาร์ท terminal หรือรัน 'source ~/.zshrc' (zsh) หรือ 'source ~/.bashrc' (bash)"
_print_info "2. ใช้คำสั่ง 'z help' เพื่อดูวิธีใช้งาน"
_print_info "3. ใช้ Tab เพื่อ autocomplete คำสั่ง"
_print_info ""
_print_info "ไฟล์ที่ติดตั้ง:"
_print_info "  - $INSTALL_DIR/z (executable)"
_print_info "  - $ZSH_COMPLETION_DIR/_z (zsh completion)"
_print_info "  - $BASH_COMPLETION_DIR/z (bash completion)"
_print_info "  - $HOME/.z_commands (command storage)" 