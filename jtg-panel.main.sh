```bash
#!/usr/bin/env bash

# ==========================================================
#                    INSANE HOST
#              INSANE HOST DEVELOPMENT
#                  ULTIMATE EDITION
# ==========================================================

set -Eeuo pipefail

# -------------------- COLORS ------------------------------

if [[ -t 1 ]]; then
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[1;34m'
    PURPLE='\033[1;35m'
    CYAN='\033[1;36m'
    WHITE='\033[1;37m'
    GRAY='\033[0;90m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    PURPLE=''
    CYAN=''
    WHITE=''
    GRAY=''
    BOLD=''
    RESET=''
fi

# -------------------- FUNCTIONS ---------------------------

line() {
    printf "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
}

info() {
    printf "${CYAN}  ➜ ${WHITE}%s${RESET}\n" "$1"
}

success() {
    printf "${GREEN}  ✔ ${WHITE}%s${RESET}\n" "$1"
}

warning() {
    printf "${YELLOW}  ⚠ %s${RESET}\n" "$1"
}

error() {
    printf "${RED}  ✖ %s${RESET}\n" "$1" >&2
}

loading() {
    local message="$1"
    local frames=('🔥' '✨' '⚡' '🔥' '💫' '⚡')
    local i

    for i in {1..12}; do
        printf "\r${PURPLE}  %s ${CYAN}%s${RESET}" \
            "${frames[$((i % ${#frames[@]}))]}" "$message"
        sleep 0.08
    done

    printf "\r%\*s\r" 100 ""
}

fire_animation() {
    local frames=(
        '🔥       🔥'
        ' 🔥     🔥 '
        '  🔥   🔥  '
        '   🔥 🔥   '
        '    🔥    '
        '   🔥 🔥   '
        '  🔥   🔥  '
        ' 🔥     🔥 '
    )

    local frame

    for frame in "${frames[@]}"; do
        printf "\r${RED}${BOLD}%s${RESET}" "$frame"
        sleep 0.08
    done

    printf "\r                    \r"
}

show_logo() {
    printf "${BLUE}${BOLD}"
    cat <<'EOF'
██╗███╗   ██╗███████╗ █████╗ ███╗   ██╗███████╗
██║████╗  ██║██╔════╝██╔══██╗████╗  ██║██╔════╝
██║██╔██╗ ██║███████╗███████║██╔██╗ ██║█████╗
██║██║╚██╗██║╚════██║██╔══██║██║╚██╗██║██╔══╝
██║██║ ╚████║███████║██║  ██║██║ ╚████║███████╗
╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝

██╗  ██╗ ██████╗ ███████╗████████╗
██║  ██║██╔═══██╗██╔════╝╚══██╔══╝
███████║██║   ██║███████╗   ██║
██╔══██║██║   ██║╚════██║   ██║
██║  ██║╚██████╔╝███████║   ██║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝
EOF
    printf "${RESET}\n"

    printf "${WHITE}${BOLD}       INSANE HOST DEVELOPMENT${RESET}\n"
    printf "${CYAN}          Developed by INSANE HOST${RESET}\n"
    printf "${GRAY}    Credits: INSANE HOST Development Team${RESET}\n"
}

handle_error() {
    local code=$?

    printf "\n"
    line
    error "An installation command failed (exit code: $code)."
    warning "Review the error above before trying again."
    line

    exit "$code"
}

trap handle_error ERR

# -------------------- STARTUP -----------------------------

clear 2>/dev/null || true

printf "\n"
fire_animation
show_logo

line

printf "${PURPLE}${BOLD}           ULTIMATE VPS INSTALLER${RESET}\n"
printf "${GRAY}       Jtg App | Node.js | Cloudflare${RESET}\n"

line

loading "Initializing INSANE HOST..."
success "Installer initialized."

# -------------------- ROOT CHECK --------------------------

if [[ "${EUID}" -ne 0 ]]; then
    error "Please run this installer as root."
    printf "\nRun: ${YELLOW}sudo -i${RESET}\n"
    exit 1
fi

# -------------------- OS CHECK ----------------------------

if [[ ! -f /etc/os-release ]]; then
    error "Cannot identify the operating system."
    exit 1
fi

source /etc/os-release

case "${ID:-}" in
    ubuntu|debian)
        success "Supported OS: ${PRETTY_NAME:-Linux}"
        ;;
    *)
        error "This installer supports Ubuntu and Debian."
        exit 1
        ;;
esac

# -------------------- SYSTEM PREPARATION ------------------

printf "\n"
line
printf "${PURPLE}${BOLD}       PHASE 01 — SYSTEM PREPARATION${RESET}\n"
line

info "Updating package lists..."
apt-get update

info "Installing required utilities..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git curl ca-certificates gnupg

success "System preparation completed."

# -------------------- NODE.JS -----------------------------

printf "\n"
line
printf "${PURPLE}${BOLD}       PHASE 02 — NODE.JS INSTALLATION${RESET}\n"
line

info "Installing Node.js..."
DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs

info "Installing npm..."
DEBIAN_FRONTEND=noninteractive apt-get install -y npm

node --version
npm --version

# -------------------- JTG APPLICATION ----------------------

printf "\n"
line
printf "${PURPLE}${BOLD}       PHASE 03 — JTG APPLICATION SETUP${RESET}\n"
line

if [[ -e "Jtg" ]]; then
    error "The Jtg directory already exists in $(pwd)."
    error "Move or back up that directory before running this installer again."
    exit 1
fi

info "Cloning Jtg repository..."
git clone https://github.com/JishnuTheGamer/Jtg.git

SCRIPT_DIR="$(pwd)"
cd "$SCRIPT_DIR/Jtg"

info "Installing npm dependencies..."
npm install

info "Building application..."
npm run build

info "Running createuser setup..."
npm run createuser

cd "$SCRIPT_DIR"

# -------------------- CLOUDFLARE INSTALLATION --------------

printf "\n"
line
printf "${PURPLE}${BOLD}       PHASE 04 — CLOUDFLARE INSTALLATION${RESET}\n"
line

install -d -m 0755 /usr/share/keyrings

curl -fsSL \
    https://pkg.cloudflare.com/cloudflare-main.gpg \
    -o /usr/share/keyrings/cloudflare-main.gpg

chmod 0644 /usr/share/keyrings/cloudflare-main.gpg

printf '%s\n' \
    'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' \
    > /etc/apt/sources.list.d/cloudflared.list

apt-get update

info "Installing cloudflared..."
DEBIAN_FRONTEND=noninteractive apt-get install -y cloudflared

cloudflared --version
success "Cloudflare installation completed."

# -------------------- CLOUDFLARE TUNNEL -------------------

printf "\n"
line
printf "${PURPLE}${BOLD}       PHASE 05 — CLOUDFLARE TUNNEL SETUP${RESET}\n"
line

printf "${CYAN}${BOLD}"
cat <<'EOF'
  ╔════════════════════════════════════════════════════╗
  ║             CLOUDFLARE TUNNEL SETUP                ║
  ╠════════════════════════════════════════════════════╣
  ║                                                    ║
  ║  Paste your tunnel token OR service install command║
  ║  Example: cloudflared service install YOUR_TOKEN   ║
  ║                                                    ║
  ║  Leave blank to skip.                              ║
  ╚════════════════════════════════════════════════════╝
EOF
printf "${RESET}\n"

CLOUDFLARE_INPUT=""
IFS= read -r -s -p "  Cloudflare input: " CLOUDFLARE_INPUT || true
printf "\n"

if [[ -n "${CLOUDFLARE_INPUT//[[:space:]]/}" ]]; then
    CLOUDFLARE_TOKEN=""

    if [[ "$CLOUDFLARE_INPUT" =~ ^[A-Za-z0-9._=+/-]+$ ]]; then
        CLOUDFLARE_TOKEN="$CLOUDFLARE_INPUT"
    elif [[ "$CLOUDFLARE_INPUT" =~ ^[[:space:]]*(sudo[[:space:]]+)?(cloudflared|/usr/bin/cloudflared)[[:space:]]+service[[:space:]]+install[[:space:]]+([A-Za-z0-9._=+/-]+)[[:space:]]*$ ]]; then
        CLOUDFLARE_TOKEN="${BASH_REMATCH[3]}"
    else
        warning "Input format not recognized; skipping tunnel setup."
    fi

    unset CLOUDFLARE_INPUT

    if [[ -n "$CLOUDFLARE_TOKEN" ]]; then
        printf "\n${YELLOW}Install the Cloudflare service now? [y/N]: ${RESET}"
        read -r CF_CONFIRM || true

        case "$CF_CONFIRM" in
            y|Y|yes|YES)
                if cloudflared service install "$CLOUDFLARE_TOKEN"; then
                    success "Cloudflare tunnel service installed."
                else
                    warning "Cloudflare service setup failed."
                fi
                ;;
            *)
                warning "Cloudflare service setup cancelled."
                ;;
        esac
    fi

    unset CLOUDFLARE_TOKEN
else
    warning "Cloudflare tunnel setup skipped."
fi

# -------------------- FINAL STATUS -------------------------

printf "\n"
line
printf "${PURPLE}${BOLD}       INSTALLATION CHECKS${RESET}\n"
line

command -v node >/dev/null 2>&1 && success "Node.js is available." || warning "Node.js unavailable."
command -v npm >/dev/null 2>&1 && success "npm is available." || warning "npm unavailable."
command -v cloudflared >/dev/null 2>&1 && success "cloudflared is available." || warning "cloudflared unavailable."

fire_animation
show_logo

line
printf "${GREEN}${BOLD}       INSTALLATION STEPS FINISHED${RESET}\n"
line

# -------------------- APPLICATION START -------------------

printf "\n"
line
printf "${PURPLE}${BOLD}       PHASE 06 — APPLICATION START${RESET}\n"
line

cd "$SCRIPT_DIR/Jtg"

info "Starting Jtg on port 6767 with npm run start..."

if PORT=6767 npm run start; then
    success "npm run start exited successfully."
else
    warning "npm run start failed. Trying emergency fallback: npm run dev"
    PORT=6767 npm run dev
fi

cd "$SCRIPT_DIR"

exit 0
```
