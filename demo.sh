#!/bin/bash

# Demo script for z command tool
# This script demonstrates the features of the z command tool

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

print_header() {
    echo -e "${WHITE}$1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check if z command is available
if ! command -v z &> /dev/null; then
    print_warning "z command not found. Please install it first:"
    echo -e "  ${CYAN}./install.sh${NC}"
    echo -e "  ${CYAN}source ~/.zshrc${NC}"
    exit 1
fi

print_header "🌈 z Command Tool Demo"
echo ""

print_info "This demo will showcase the main features of the z command tool."
echo ""

# Clear any existing commands
print_info "Clearing any existing commands..."
z clear > /dev/null 2>&1

# Demo 1: Adding commands
print_header "Demo 1: Adding Commands"
echo ""

print_info "Adding some sample commands..."
z add "ls -la"
z add "ps aux | grep node"
z add "docker ps"
z add "git status"
z add "find . -name '*.js' -type f"

echo ""
print_success "Added 5 sample commands"
echo ""

# Demo 2: Listing commands
print_header "Demo 2: Listing Commands"
echo ""
z list
echo ""

# Demo 3: Executing commands
print_header "Demo 3: Executing Commands"
echo ""
print_info "Executing command #1 (ls -la):"
z 1
echo ""

# Demo 4: Searching commands
print_header "Demo 4: Searching Commands"
echo ""
print_info "Searching for commands containing 'git':"
z search "git"
echo ""

print_info "Searching for commands containing 'docker':"
z search "docker"
echo ""

# Demo 5: Statistics
print_header "Demo 5: Statistics"
echo ""
z stats
echo ""

# Demo 6: Deleting commands
print_header "Demo 6: Deleting Commands"
echo ""
print_info "Deleting command #3 (docker ps):"
z delete 3
echo ""

print_info "Listing commands after deletion:"
z list
echo ""

# Demo 7: Help
print_header "Demo 7: Help System"
echo ""
print_info "Showing help:"
z help
echo ""

# Demo 8: Exec interface
print_header "Demo 8: Exec Interface"
echo ""
print_info "Showing exec interface:"
z exec
echo ""

print_header "🎉 Demo Complete!"
echo ""
print_success "You've seen all the main features of the z command tool:"
echo -e "  ${CYAN}✓${NC} Adding commands"
echo -e "  ${CYAN}✓${NC} Listing commands"
echo -e "  ${CYAN}✓${NC} Executing commands by number"
echo -e "  ${CYAN}✓${NC} Searching commands"
echo -e "  ${CYAN}✓${NC} Viewing statistics"
echo -e "  ${CYAN}✓${NC} Deleting commands"
echo -e "  ${CYAN}✓${NC} Help system"
echo -e "  ${CYAN}✓${NC} Exec interface"
echo ""
print_info "Try these commands yourself:"
echo -e "  ${YELLOW}z add \"your command\"${NC}"
echo -e "  ${YELLOW}z list${NC}"
echo -e "  ${YELLOW}z search \"term\"${NC}"
echo -e "  ${YELLOW}z stats${NC}"
echo -e "  ${YELLOW}z help${NC}"
echo ""
print_rainbow_header "Happy coding! 🌈" 