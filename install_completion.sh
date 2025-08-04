#!/bin/bash

# Install working completion for MyCLI

echo "Installing MyCLI completion..."

# Detect shell
SHELL_NAME=$(basename "$SHELL")

case "$SHELL_NAME" in
    "zsh")
        # Create completion script for zsh
        cat > ~/.mycli_completion.zsh << 'EOF'
# MyCLI completion
_mycli() {
    local -a commands
    commands=(
        'hello:Say hello to someone'
        'goodbye:Say goodbye'
        'add:Add a custom command with optional alias'
        'list:List all stored commands'
        'run:Run a stored command by key or index'
        'exec:Execute a stored command in the current shell context'
        '--help:Show help'
        '--version:Show version'
        '--install-completion:Install shell completion'
    )
    
    if (( CURRENT == 2 )); then
        _describe -V 'mycli commands' commands
    elif (( CURRENT == 3 )); then
        case $words[2] in
            hello)
                local -a options
                options=(
                    '--name:Name to greet'
                    '--help:Show help'
                )
                _describe -V 'hello options' options
                ;;
            goodbye)
                local -a options
                options=(
                    '--help:Show help'
                )
                _describe -V 'goodbye options' options
                ;;
            add)
                local -a options
                options=(
                    '-c:Command to add'
                    '--command:Command to add'
                    '-k:Alias/key for the command'
                    '--key:Alias/key for the command'
                    '--help:Show help'
                )
                _describe -V 'add options' options
                ;;
            list)
                local -a options
                options=(
                    '--help:Show help'
                )
                _describe -V 'list options' options
                ;;
            run|exec)
                # For run/exec commands, we need to complete with stored command keys
                local -a keys
                if [[ -f ~/.cli_storage ]]; then
                    # Extract keys from JSON storage file
                    keys=($(python3 -c "
import json
try:
    with open('$HOME/.cli_storage', 'r') as f:
        data = json.load(f)
        print(' '.join(data.keys()))
except:
    pass
" 2>/dev/null))
                fi
                if [[ ${#keys[@]} -gt 0 ]]; then
                    _describe -V 'stored command keys' keys
                else
                    _describe -V 'run options' '--help:Show help'
                fi
                ;;
        esac
    elif (( CURRENT == 4 )); then
        case $words[2] in
            add)
                # Complete additional options for add command
                local -a options
                options=(
                    '-c:Command to add'
                    '--command:Command to add'
                    '-k:Alias/key for the command'
                    '--key:Alias/key for the command'
                    '--help:Show help'
                )
                _describe -V 'add options' options
                ;;
        esac
    fi
}

# lan function completion
_lan() {
    local -a keys
    if [[ -f ~/.cli_storage ]]; then
        # Extract keys from JSON storage file
        keys=($(python3 -c "
import json
try:
    with open('$HOME/.cli_storage', 'r') as f:
        data = json.load(f)
        print(' '.join(data.keys()))
except:
    pass
" 2>/dev/null))
    fi
    if [[ ${#keys[@]} -gt 0 ]]; then
        _describe -V 'stored command keys' keys
    fi
}

compdef _mycli mycli
compdef _lan lan
EOF

        # Add to .zshrc if not already there
        if ! grep -q "source ~/.mycli_completion.zsh" ~/.zshrc; then
            echo "" >> ~/.zshrc
            echo "# MyCLI completion" >> ~/.zshrc
            echo "source ~/.mycli_completion.zsh" >> ~/.zshrc
        fi
        
        echo "Zsh completion installed!"
        ;;
    "bash")
        # Create completion script for bash
        cat > ~/.mycli_completion.bash << 'EOF'
# MyCLI completion
_mycli_completion() {
    local cur prev opts cmds
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ ${cur} == * ]] ; then
        case $prev in
            mycli)
                COMPREPLY=( $(compgen -W "hello goodbye add list run exec --help --version --install-completion" -- "${cur}") )
                ;;
            add)
                COMPREPLY=( $(compgen -W "-c --command -k --key --help" -- "${cur}") )
                ;;
            run|exec)
                # Complete with stored command keys
                if [[ -f ~/.cli_storage ]]; then
                    keys=$(python3 -c "
import json
try:
    with open('$HOME/.cli_storage', 'r') as f:
        data = json.load(f)
        print(' '.join(data.keys()))
except:
    pass
" 2>/dev/null)
                    COMPREPLY=( $(compgen -W "$keys" -- "${cur}") )
                fi
                ;;
        esac
        return 0
    fi
}

# lan function completion
_lan_completion() {
    local cur
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    if [[ -f ~/.cli_storage ]]; then
        keys=$(python3 -c "
import json
try:
    with open('$HOME/.cli_storage', 'r') as f:
        data = json.load(f)
        print(' '.join(data.keys()))
except:
    pass
" 2>/dev/null)
        COMPREPLY=( $(compgen -W "$keys" -- "${cur}") )
    fi
    return 0
}

complete -F _mycli_completion mycli
complete -F _lan_completion lan
EOF

        # Add to .bashrc if not already there
        if ! grep -q "source ~/.mycli_completion.bash" ~/.bashrc; then
            echo "" >> ~/.bashrc
            echo "# MyCLI completion" >> ~/.bashrc
            echo "source ~/.mycli_completion.bash" >> ~/.bashrc
        fi
        
        echo "Bash completion installed!"
        ;;
    *)
        echo "Unsupported shell: $SHELL_NAME"
        echo "Please manually install completion for your shell"
        exit 1
        ;;
esac

echo "Completion installed! Please run: source ~/.${SHELL_NAME}rc" 