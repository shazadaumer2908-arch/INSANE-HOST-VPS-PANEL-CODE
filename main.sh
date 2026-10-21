#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================
#  INSANE HOST | ULTIMATE VPS INSTALLER
#  V-Panel + Node.js + npm + Cloudflare Tunnel
#  Credits: INSANE HOST Development Team
# ============================================================

VERSION="2.1"
PANEL_DIR="/opt/vpanel-pro"

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================================
#  TERMINAL UI
# ============================================================

line() {
    printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

info() {
    printf "  ${CYAN}➜${NC} %s\n" "$1"
}

success() {
    printf "  ${GREEN}✔${NC} %s\n" "$1"
}

warn() {
    printf "  ${YELLOW}!${NC} %s\n" "$1"
}

fail() {
    printf "\n  ${RED}✖ ERROR:${NC} %s\n\n" "$1" >&2
}

section() {
    printf "\n"
    line
    printf "  ${MAGENTA}${BOLD}%s${NC}\n" "$1"
    line
}

# ============================================================
#  ERROR HANDLING
# ============================================================

trap 'status=$?; printf "\n\033[0;31m[ERROR]\033[0m Installer failed near line %s (exit code %s).\n" "$LINENO" "$status" >&2; exit "$status"' ERR

# ============================================================
#  INSANE HOST LOGO
# ============================================================

show_logo() {
    clear 2>/dev/null || true

    printf "${CYAN}${BOLD}"
    cat <<'LOGO'

  ██╗███╗   ██╗███████╗ █████╗ ███╗   ██╗███████╗
  ██║████╗  ██║██╔════╝██╔══██╗████╗  ██║██╔════╝
  ██║██╔██╗ ██║███████╗███████║██╔██╗ ██║█████╗
  ██║██║╚██╗██║╚════██║██╔══██╗██║╚██╗██║██╔══╝
  ██║██║ ╚████║███████║██║  ██║██║ ╚████║███████╗
  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝

  ██╗  ██╗ ██████╗ ███████╗████████╗
  ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝
  ███████║██║   ██║███████╗   ██║
  ██╔══██║██║   ██║╚════██║   ██║
  ██║  ██║╚██████╔╝███████║   ██║
  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝

LOGO
    printf "${NC}"

    line
    printf "${WHITE}${BOLD}             ULTIMATE VPS INSTALLER${NC}\n"
    printf "${YELLOW}                    VERSION %s${NC}\n" "$VERSION"
    line

    printf "\n"
    printf "  ${GREEN}◆${NC} V-Panel Control Panel\n"
    printf "  ${GREEN}◆${NC} Node.js + npm\n"
    printf "  ${GREEN}◆${NC} Cloudflare Tunnel\n"
    printf "  ${GREEN}◆${NC} Automated Installation\n"
    printf "\n"

    printf "  ${MAGENTA}Developed and maintained by INSANE HOST${NC}\n"
    printf "  ${CYAN}Credits: INSANE HOST Development Team${NC}\n"

    line
    printf "\n"
}

# ============================================================
#  STARTUP CHECKS
# ============================================================

show_logo

if [[ "$EUID" -ne 0 ]]; then
    fail "Please run this installer as root."
    printf "  Run: sudo bash main.sh\n"
    exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
    fail "This installer requires an Ubuntu/Debian-based system."
    exit 1
fi

if [[ ! -r /etc/os-release ]]; then
    fail "Cannot identify the operating system."
    exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release

if [[ "${ID:-}" != "ubuntu" && "${ID:-}" != "debian" ]]; then
    warn "This script is intended for Ubuntu or Debian."
    read -r -p "Continue anyway? [y/N]: " CONTINUE
    [[ "$CONTINUE" =~ ^[Yy]$ ]] || exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# ============================================================
#  WELCOME
# ============================================================

section "WELCOME TO INSANE HOST"

printf "  ${WHITE}This installer will set up:${NC}\n\n"
printf "  ${CYAN}[1]${NC} Required system packages\n"
printf "  ${CYAN}[2]${NC} Node.js\n"
printf "  ${CYAN}[3]${NC} npm\n"
printf "  ${CYAN}[4]${NC} V-Panel\n"
printf "  ${CYAN}[5]${NC} Cloudflare Tunnel\n"

printf "\n  ${YELLOW}V-Panel admin password: admin12${NC}\n\n"

read -r -p "  Start installation? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-Y}"

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    info "Installation cancelled."
    exit 0
fi

# ============================================================
#  STEP 1: SYSTEM PREPARATION
# ============================================================

section "STEP 1/5 - PREPARING YOUR SYSTEM"

info "Updating package lists..."
apt-get update

info "Installing required tools..."
apt-get install -y git curl ca-certificates

success "System preparation completed."

# ============================================================
#  STEP 2: NODE.JS AND NPM
# ============================================================

section "STEP 2/5 - INSTALLING NODE.JS AND NPM"

info "Installing Node.js first..."
apt-get install -y nodejs

if ! command -v node >/dev/null 2>&1; then
    fail "Node.js was not found after installation."
    exit 1
fi

success "Node.js installed."
printf "  ${DIM}Version: %s${NC}\n" "$(node --version)"

info "Installing npm..."
apt-get install -y npm

if ! command -v npm >/dev/null 2>&1; then
    fail "npm was not found after installation."
    exit 1
fi

success "npm installed."
printf "  ${DIM}Version: %s${NC}\n" "$(npm --version)"

# ============================================================
#  STEP 3: V-PANEL
# ============================================================

section "STEP 3/5 - INSTALLING V-PANEL"

if [[ -d "$PANEL_DIR/.git" ]]; then
    info "V-Panel repository already exists."
else
    if [[ -e "$PANEL_DIR" ]]; then
        fail "$PANEL_DIR exists but is not a Git repository."
        printf "  Inspect this directory before continuing.\n"
        exit 1
    fi

    info "Cloning the V-Panel repository..."
    git clone https://github.com/nobita329/vpanel-pro.git "$PANEL_DIR"
fi

cd "$PANEL_DIR"

if [[ ! -f install.sh ]]; then
    fail "V-Panel install.sh was not found."
    exit 1
fi

printf "\n"
line
printf "  ${WHITE}${BOLD}V-PANEL SETUP${NC}\n"
line
printf "  ${CYAN}Admin password requested:${NC} ${GREEN}admin12${NC}\n\n"

warn "The V-Panel installer will make system-level changes."
read -r -p "  Continue with V-Panel installation? [y/N]: " PANEL_CONFIRM

if [[ "$PANEL_CONFIRM" =~ ^[Yy]$ ]]; then
    info "Starting the V-Panel installer..."
    bash install.sh --admin-pass 'admin12'
    success "V-Panel installer finished."
else
    warn "V-Panel installation skipped."
fi

# ============================================================
#  STEP 4: CLOUDFLARE TUNNEL
# ============================================================

section "STEP 4/5 - INSTALLING CLOUDFLARE TUNNEL"

info "Preparing Cloudflare signing key..."

install -d -m 0755 /usr/share/keyrings

curl -fsSL \
    https://pkg.cloudflare.com/cloudflare-main.gpg \
    -o /usr/share/keyrings/cloudflare-main.gpg

chmod 0644 /usr/share/keyrings/cloudflare-main.gpg

info "Adding Cloudflare package repository..."

printf '%s\n' \
    'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' \
    > /etc/apt/sources.list.d/cloudflared.list

info "Updating package lists..."
apt-get update

info "Installing cloudflared..."
apt-get install -y cloudflared

if ! command -v cloudflared >/dev/null 2>&1; then
    fail "cloudflared was not found after installation."
    exit 1
fi

success "Cloudflare Tunnel package installed."
printf "  ${DIM}%s${NC}\n" "$(cloudflared --version)"

# ============================================================
#  STEP 5: CLOUDFLARE SERVICE BOX
# ============================================================

section "STEP 5/5 - CLOUDFLARE TUNNEL SETUP"

printf "\n"
printf "  ${CYAN}╔══════════════════════════════════════════════════╗${NC}\n"
printf "  ${CYAN}║${WHITE}${BOLD}            INSANE HOST - CLOUDFLARE             ${NC}${CYAN}║${NC}\n"
printf "  ${CYAN}╠══════════════════════════════════════════════════╣${NC}\n"
printf "  ${CYAN}║${NC}                                                  ${CYAN}║${NC}\n"
printf "  ${CYAN}║${NC}  ${GREEN}[1]${NC} Paste your Cloudflare Tunnel TOKEN          ${CYAN}║${NC}\n"
printf "  ${CYAN}║${NC}  ${GREEN}[2]${NC} Paste the COMPLETE service install COMMAND  ${CYAN}║${NC}\n"
printf "  ${CYAN}║${NC}                                                  ${CYAN}║${NC}\n"
printf "  ${CYAN}║${NC}  ${YELLOW}BOTH METHODS ARE SUPPORTED${NC}                    ${CYAN}║${NC}\n"
printf "  ${CYAN}║${NC}  ${DIM}Input is hidden for security.${NC}                  ${CYAN}║${NC}\n"
printf "  ${CYAN}║${NC}                                                  ${CYAN}║${NC}\n"
printf "  ${CYAN}╚══════════════════════════════════════════════════╝${NC}\n"

printf "\n"
printf "  ${WHITE}Paste your token or service install command.${NC}\n"
printf "  ${DIM}Press ENTER to skip this step.${NC}\n\n"

printf "  ${MAGENTA}Cloudflare input > ${NC}"

CLOUDFLARE_INPUT=""
IFS= read -r -s CLOUDFLARE_INPUT || true
printf "\n\n"

CLOUDFLARE_TOKEN=""

if [[ -z "$CLOUDFLARE_INPUT" ]]; then
    warn "Cloudflare service setup skipped."

elif [[ "$CLOUDFLARE_INPUT" =~ ^[A-Za-z0-9._=+/-]+$ ]]; then
    # A token entered directly.
    CLOUDFLARE_TOKEN="$CLOUDFLARE_INPUT"

elif [[ "$CLOUDFLARE_INPUT" =~ ^[[:space:]]*(sudo[[:space:]]+)?(cloudflared|/usr/bin/cloudflared)[[:space:]]+service[[:space:]]+install[[:space:]]+([A-Za-z0-9._=+/-]+)[[:space:]]*$ ]]; then
    # Accept a simple service-install command without executing it as shell.
    CLOUDFLARE_TOKEN="${BASH_REMATCH[3]}"

else
    warn "Input format not recognized."
    warn "No command was executed."
fi

unset CLOUDFLARE_INPUT

if [[ -n "$CLOUDFLARE_TOKEN" ]]; then
    printf "\n"
    line
    printf "  ${YELLOW}${BOLD}CONFIRM CLOUDFLARE SETUP${NC}\n"
    line
    printf "  This will install the Cloudflare Tunnel service.\n"
    printf "  Your token will not be printed on screen.\n\n"

    read -r -p "  Continue? [y/N]: " CF_CONFIRM

    if [[ "$CF_CONFIRM" =~ ^[Yy]$ ]]; then
        info "Installing the Cloudflare service..."

        if cloudflared service install "$CLOUDFLARE_TOKEN"; then
            success "Cloudflare service installation completed."
            info "Check the Cloudflare dashboard to verify connectivity."
        else
            warn "Service installation failed."
            warn "Check the token and your system's service manager."
        fi
    else
        warn "Cloudflare service setup cancelled."
    fi

    unset CLOUDFLARE_TOKEN
fi

# ============================================================
#  COMPLETION SCREEN
# ============================================================

section "INSANE HOST INSTALLATION FINISHED"

printf "\n"
printf "  ${GREEN}${BOLD}✔ INSTALLER PROCESS COMPLETED${NC}\n\n"
printf "  ${CYAN}Node.js:${NC} %s\n" "$(node --version)"
printf "  ${CYAN}npm:${NC} %s\n" "$(npm --version)"
printf "  ${CYAN}Cloudflared:${NC} installed\n"
printf "  ${CYAN}V-Panel password requested:${NC} admin12\n"

printf "\n"
printf "  ${MAGENTA}Developed and maintained by INSANE HOST${NC}\n"
printf "  ${CYAN}Credits: INSANE HOST Development Team${NC}\n"

line
printf "  ${WHITE}Thank you for choosing INSANE HOST!${NC}\n"
line
printf "\n"

# ============================================================
#  END
# ============================================================
