# Common utilities for z command tool scripts

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
ORANGE='\033[38;5;208m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Message helpers
print_success() { echo -e "${GREEN}✓ $1${RESET}"; }
print_error()   { echo -e "${RED}✗ $1${RESET}"; }
print_info()    { echo -e "${BLUE}ℹ $1${RESET}"; }
print_warning() { echo -e "${ORANGE}⚠ $1${RESET}"; }
print_header()  { echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }
