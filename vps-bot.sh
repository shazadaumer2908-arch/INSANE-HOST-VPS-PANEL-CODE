```bash
#!/usr/bin/env bash
# ============================================================
#  INSANE HOST - VPS Deploy Bot Installer
#  Script: vps-bot.sh
#  Credits: INSANE HOST
# ============================================================

set -Eeuo pipefail

# Cyan + Blue Theme
CYAN='\033[1;96m'
BLUE='\033[1;94m'
WHITE='\033[1;97m'
GREEN='\033[1;92m'
YELLOW='\033[1;93m'
RED='\033[1;91m'
RESET='\033[0m'

clear_screen() {
    command -v clear >/dev/null 2>&1 && clear || true
}

line() {
    printf '%b\n' "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

banner() {
    clear_screen
    printf '\n'
    printf '%b\n' "${CYAN}██╗███╗   ██╗███████╗ █████╗ ███╗   ██╗███████╗${RESET}"
    printf '%b\n' "${CYAN}██║████╗  ██║██╔════╝██╔══██╗████╗  ██║██╔════╝${RESET}"
    printf '%b\n' "${BLUE}██║██╔██╗ ██║███████╗███████║██╔██╗ ██║█████╗  ${RESET}"
    printf '%b\n' "${BLUE}██║██║╚██╗██║╚════██║██╔══██║██║╚██╗██║██╔══╝  ${RESET}"
    printf '%b\n' "${CYAN}██║██║ ╚████║███████║██║  ██║██║ ╚████║███████╗${RESET}"
    printf '%b\n' "${CYAN}╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝${RESET}"
    printf '\n'
    line
    printf '%b\n' "${WHITE}                 VPS BOT INSTALLER${RESET}"
    printf '%b\n' "${CYAN}                 Powered by INSANE HOST${RESET}"
    line
    printf '\n'
}

info() {
    printf '%b\n' "${CYAN}[INFO]${RESET} $*"
}

success() {
    printf '%b\n' "${GREEN}[SUCCESS]${RESET} $*"
}

warning() {
    printf '%b\n' "${YELLOW}[WARNING]${RESET} $*"
}

error() {
    printf '%b\n' "${RED}[ERROR]${RESET} $*" >&2
}

on_error() {
    local exit_code=$?
    error "Installation stopped near line ${BASH_LINENO[0]:-unknown} (exit code: ${exit_code})."
    error "Check the message above, fix the issue, and run this script again."
    exit "$exit_code"
}

trap on_error ERR

main() {
    banner

    info "Starting VPS Deploy Bot installation..."
    printf '\n'

    if ! command -v git >/dev/null 2>&1; then
        error "Git is not installed."
        info "Install Git first:"
        printf '%b\n' "${YELLOW}sudo apt-get update && sudo apt-get install -y git${RESET}"
        exit 1
    fi

    if ! command -v sudo >/dev/null 2>&1; then
        error "sudo is not installed."
        exit 1
    fi

    if [[ -e "vps-deploy-bot-v1" ]]; then
        error "The folder 'vps-deploy-bot-v1' already exists."
        info "Move or rename that folder, then run this script again."
        exit 1
    fi

    info "Cloning VPS Deploy Bot repository..."
    git clone https://github.com/dipbendu1/vps-deploy-bot-v1.git

    info "Entering project directory..."
    cd vps-deploy-bot-v1

    if [[ ! -f "install.sh" ]]; then
        error "The repository does not contain install.sh."
        exit 1
    fi

    info "Making install.sh executable..."
    chmod +x install.sh

    printf '\n'
    warning "The next step runs install.sh with sudo (root privileges)."
    warning "Review the repository script before continuing."
    printf '\n'

    read -r -p "Continue with installation? [y/N]: " answer

    case "$answer" in
        [yY]|[yY][eE][sS]) ;;
        *)
            warning "Installation cancelled."
            exit 0
            ;;
    esac

    info "Launching VPS Deploy Bot installer..."
    sudo ./install.sh

    printf '\n'
    line
    success "VPS Deploy Bot installation completed!"
    printf '%b\n' "${CYAN}Thank you for choosing INSANE HOST!${RESET}"
    line
}

main "$@"
```
