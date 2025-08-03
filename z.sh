#!/usr/bin/env bash
# z Command Tool implemented as a shell function.
# Source this file in your shell (bash หรือ zsh)

# สีสำหรับข้อความ
_Z_RED='\033[0;31m'
_Z_GREEN='\033[0;32m'
_Z_YELLOW='\033[1;33m'
_Z_BLUE='\033[0;34m'
_Z_ORANGE='\033[38;5;208m'
_Z_WHITE='\033[1;37m'
_Z_RESET='\033[0m'

_z_print_success() { echo -e "${_Z_GREEN}✓ $1${_Z_RESET}"; }
_z_print_error()   { echo -e "${_Z_RED}✗ $1${_Z_RESET}"; }
_z_print_info()    { echo -e "${_Z_BLUE}ℹ $1${_Z_RESET}"; }
_z_print_warning() { echo -e "${_Z_ORANGE}⚠ $1${_Z_RESET}"; }

# ไฟล์เก็บคำสั่ง
_Z_COMMANDS_FILE="$HOME/.z_commands"
[ -f "$_Z_COMMANDS_FILE" ] || touch "$_Z_COMMANDS_FILE"

# ฟังก์ชันหลัก
z() {
    # ถ้าไม่ส่งอาร์กิวเมนต์ แสดง help
    if [ $# -eq 0 ]; then
        z help
        return
    fi

    local subcmd="$1"
    shift

    case "$subcmd" in
        add)
            if [ -z "$1" ]; then
                _z_print_error "Usage: z add \"command\""; return 1
            fi
            echo "$1" >> "$_Z_COMMANDS_FILE"
            local count; count=$(wc -l < "$_Z_COMMANDS_FILE")
            _z_print_success "Stored command #$count: $1"
            ;;
        attach)
            if [ -z "$1" ]; then
                _z_print_error "Usage: z attach \"command\""; return 1
            fi
            echo "$1" >> "$_Z_COMMANDS_FILE"
            ;;
        list|ls)
            if [ ! -s "$_Z_COMMANDS_FILE" ]; then
                _z_print_warning "No commands stored yet. Use 'z add \"<command>\"' to add one."
                return
            fi
            _z_print_info "Stored commands:"
            local idx=1
            while IFS= read -r cmd; do
                printf "%3d: %s\n" "$idx" "$cmd"
                idx=$((idx+1))
            done < "$_Z_COMMANDS_FILE"
            ;;
        delete)
            local num="$1"
            if ! [[ "$num" =~ ^[0-9]+$ ]]; then
                _z_print_error "Usage: z delete <number>"; return 1
            fi
            local cmd; cmd=$(sed -n "${num}p" "$_Z_COMMANDS_FILE")
            if [ -z "$cmd" ]; then
                _z_print_error "No command found at line $num"; return 1
            fi
            # ลบบรรทัดนั้นอย่างปลอดภัย (ใช้ไฟล์ชั่วคราวเพื่อความข้ามแพลตฟอร์ม)
            local _tmpfile; _tmpfile=$(mktemp)
            sed "${num}d" "$_Z_COMMANDS_FILE" > "$_tmpfile"
            mv "$_tmpfile" "$_Z_COMMANDS_FILE"
            _z_print_success "Deleted command #$num: $cmd"
            ;;
        clear)
            if [ ! -s "$_Z_COMMANDS_FILE" ]; then
                _z_print_warning "No commands to clear."; return
            fi
            read -r -p "Are you sure you want to clear all commands? (y/N) " resp
            case "$resp" in
                y|Y) : > "$_Z_COMMANDS_FILE"; _z_print_success "All commands cleared." ;;
                *)   _z_print_info "Operation cancelled." ;;
            esac
            ;;
        search)
            if [ -z "$1" ]; then
                _z_print_error "Usage: z search \"pattern\""; return 1
            fi
            local pattern="$1" found=0 i=1
            while IFS= read -r cmd; do
                if [[ "$cmd" == *$pattern* ]]; then
                    printf "%3d: %s\n" "$i" "$cmd"
                    found=1
                fi
                i=$((i+1))
            done < "$_Z_COMMANDS_FILE"
            if [ $found -eq 0 ]; then
                _z_print_warning "No commands found containing '$pattern'"
            fi
            ;;
        stats)
            if [ ! -s "$_Z_COMMANDS_FILE" ]; then
                _z_print_warning "No commands stored yet."; return
            fi
            local total unique most count cmd
            total=$(wc -l < "$_Z_COMMANDS_FILE")
            unique=$(sort "$_Z_COMMANDS_FILE" | uniq | wc -l)
            most=$(sort "$_Z_COMMANDS_FILE" | uniq -c | sort -nr | head -n1)
            count=$(echo "$most" | awk '{print $1}')
            cmd=$(echo "$most" | sed -e 's/^[[:space:]]*[0-9][0-9]*[[:space:]]*//')
            _z_print_info "Total commands: $total"
            _z_print_info "Unique commands: $unique"
            [ -n "$cmd" ] && _z_print_info "Most used: $cmd ($count times)"
            ;;
        help)
            cat <<'EOF'
z - Command Storage and Execution Tool

Usage:
  z add "command"     -- Store a new command
  z attach "command"  -- Store a command silently
  z <number>          -- Execute command by number
  z list | z ls       -- List all stored commands
  z delete <number>   -- Delete command by number
  z clear             -- Clear all commands
  z search "pattern"   -- Search stored commands
  z stats             -- Show statistics
  z help              -- Show this help message

Features:
  ✓ Persistent storage in ~/.z_commands
  ✓ Execute commands in the current shell (cd supported)
  ✓ Command search and statistics

Note: source this file in your shell configuration to use `z` across sessions.
EOF
            ;;
        *)
            # หากอาร์กิวเมนต์ตัวแรกเป็นตัวเลข ให้ถือว่าเป็นการรันคำสั่ง
            if [[ "$subcmd" =~ ^[0-9]+$ ]]; then
                local num="$subcmd"
                local cmd; cmd=$(sed -n "${num}p" "$_Z_COMMANDS_FILE")
                if [ -z "$cmd" ]; then
                    _z_print_error "No command found at line $num"; return 1
                fi
                _z_print_info "Executing: $cmd"
                if [[ "$cmd" =~ ^cd[[:space:]]+ ]]; then
                    # แยกไดเรกทอรีแล้วขยาย ~ และตัวแปรด้วย eval echo
                    local dir; dir=$(echo "$cmd" | sed -e 's/^cd[[:space:]]*//')
                    local expanded; expanded=$(eval echo "$dir")
                    if cd "$expanded"; then
                        _z_print_success "Changed directory to: $(pwd)"
                    else
                        _z_print_error "Failed to change directory to: $dir"
                    fi
                else
                    eval "$cmd"
                fi
            else
                _z_print_error "Unknown command: $subcmd"
                _z_print_info "Use 'z help' for usage information."
                return 1
            fi
            ;;
    esac
}