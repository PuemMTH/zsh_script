#!/bin/bash

# Install working completion for MyCLI

echo "Installing MyCLI completion..."

# Create completion script
cat > ~/.mycli_completion.zsh << 'EOF'
# MyCLI completion
_mycli() {
    local -a commands
    commands=(
        'hello:Say hello to someone'
        'goodbye:Say goodbye'
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
        esac
    fi
}

compdef _mycli mycli
EOF

# Add to .zshrc if not already there
if ! grep -q "source ~/.mycli_completion.zsh" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# MyCLI completion" >> ~/.zshrc
    echo "source ~/.mycli_completion.zsh" >> ~/.zshrc
fi

echo "Completion installed! Please run: source ~/.zshrc" 