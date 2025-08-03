#!/bin/bash
# Bash completion for z command tool

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
                # แนะนำคำสั่งทั่วไป
                local common_commands="ls ps df du find grep cat echo wget curl git docker"
                COMPREPLY=( $(compgen -W "${common_commands}" -- ${cur}) )
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
                # แนะนำคำสั่งทั่วไปสำหรับการค้นหา
                local search_terms="ls ps grep find cat echo"
                COMPREPLY=( $(compgen -W "${search_terms}" -- ${cur}) )
                return 0
                ;;
        esac
    fi
}

complete -F _z_completion z 