
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

PANEL_DIR="/opt/vpanel-pro"
PANEL_REPO="https://github.com/nobita329/vpanel-pro.git"

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

    printf "\r%*s\r" 100 ""
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
    printf "${RED}${BOLD}"
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
printf "${GRAY}       V-Panel | Node.js | Cloudflare${RESET}\n"

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

# -------------------- PASSWORD INPUT ----------------------

printf "\n"
line
printf "${PURPLE}${BOLD}       V-PANEL ADMIN PASSWORD${RESET}\n"
line

printf "${CYAN}Enter your preferred V-Panel admin password.${RESET}\n"
printf "${GRAY}Your password will be visible while typing.${RESET}\n\n"

while true; do
    PANEL_PASSWORD=""

    if ! IFS= read -r -p "  Enter password: " PANEL_PASSWORD; then
        printf "\n"
        error "Unable to read password."
        exit 1
    fi

    printf "\n"

    if [[ -z "$PANEL_PASSWORD" ]]; then
        warning "Password cannot be empty."
        continue
    fi

    PANEL_CONFIRM=""

    if ! IFS= read -r -p "  Confirm password: " PANEL_CONFIRM; then
        printf "\n"
        error "Unable to confirm password."
        exit 1
    fi

    printf "\n"

    if [[ "$PANEL_PASSWORD" != "$PANEL_CONFIRM" ]]; then
        warning "Passwords do not match. Try again."
        unset PANEL_PASSWORD PANEL_CONFIRM
        continue
    fi

    unset PANEL_CONFIRM
    success "Password received."
    break
done

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
success "Node.js installation command completed."

info "Installing npm..."
DEBIAN_FRONTEND=noninteractive apt-get install -y npm
success "npm installation command completed."

if command -v node >/dev/null 2>&1; then
    printf "${CYAN}  Node.js version: ${WHITE}"
    node --version
else
    warning "Node.js command was not found."
fi

if command -v npm >/dev/null 2>&1; then
    printf "${CYAN}  npm version: ${WHITE}"
    npm --version
else
    warning "npm command was not found."
fi

# -------------------- V-PANEL -----------------------------

printf "\n"
line
printf "${PURPLE}${BOLD}       PHASE 03 — V-PANEL INSTALLATION${RESET}\n"
line

if [[ -d "$PANEL_DIR/.git" ]]; then
    warning "Existing V-Panel repository found."
elif [[ -e "$PANEL_DIR" ]]; then
    error "$PANEL_DIR exists but is not a Git repository."
    error "Inspect or back up this directory before continuing."
    exit 1
else
    info "Downloading V-Panel repository..."
    git clone "$PANEL_REPO" "$PANEL_DIR"
    success "Repository downloaded."
fi

if [[ ! -f "$PANEL_DIR/install.sh" ]]; then
    error "V-Panel install.sh was not found."
    exit 1
fi

printf "\n"
warning "The V-Panel installer will receive your chosen password."
warning "Continue only if you trust this repository."

printf "${YELLOW}Continue with V-Panel installation? [y/N]: ${RESET}"
read -r PANEL_CONFIRM || true

case "$PANEL_CONFIRM" in
    y|Y|yes|YES)
        ;;
    *)
        unset PANEL_PASSWORD
        error "V-Panel installation cancelled."
        exit 1
        ;;
esac

cd "$PANEL_DIR"

info "Starting V-Panel installer..."

bash install.sh --admin-pass "$PANEL_PASSWORD"

unset PANEL_PASSWORD
success "V-Panel installer process finished."

# -------------------- CLOUDFLARE --------------------------

printf "\n"
line
printf "${PURPLE}${BOLD}       PHASE 04 — CLOUDFLARE INSTALLATION${RESET}\n"
line

info "Preparing Cloudflare package repository..."

install -d -m 0755 /usr/share/keyrings

curl -fsSL \
    https://pkg.cloudflare.com/cloudflare-main.gpg \
    -o /usr/share/keyrings/cloudflare-main.gpg

chmod 0644 /usr/share/keyrings/cloudflare-main.gpg

printf '%s\n' \
    'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' \
    > /etc/apt/sources.list.d/cloudflared.list

info "Refreshing package lists..."
apt-get update

info "Installing cloudflared..."
DEBIAN_FRONTEND=noninteractive apt-get install -y cloudflared

success "cloudflared installation command completed."

if command -v cloudflared >/dev/null 2>&1; then
    cloudflared --version
fi

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
  ║           BOTH METHODS ARE SUPPORTED               ║
  ║                                                    ║
  ║  METHOD 1: Paste your tunnel token                 ║
  ║  METHOD 2: Paste the service install command       ║
  ║                                                    ║
  ║  Example: cloudflared service install YOUR_TOKEN    ║
  ║                                                    ║
  ║  Leave blank to skip this step.                    ║
  ╚════════════════════════════════════════════════════╝
EOF
printf "${RESET}\n"

printf "${GRAY}Input is hidden for privacy.${RESET}\n"

CLOUDFLARE_INPUT=""
IFS= read -r -s -p "  Cloudflare input: " CLOUDFLARE_INPUT || true
printf "\n"

if [[ -z "${CLOUDFLARE_INPUT//[[:space:]]/}" ]]; then
    warning "Cloudflare service setup skipped."
else
    CLOUDFLARE_TOKEN=""

    if [[ "$CLOUDFLARE_INPUT" =~ ^[A-Za-z0-9._=+/-]+$ ]]; then
        CLOUDFLARE_TOKEN="$CLOUDFLARE_INPUT"

    elif [[ "$CLOUDFLARE_INPUT" =~ ^[[:space:]]*(sudo[[:space:]]+)?(cloudflared|/usr/bin/cloudflared)[[:space:]]+service[[:space:]]+install[[:space:]]+([A-Za-z0-9._=+/-]+)[[:space:]]*$ ]]; then
        CLOUDFLARE_TOKEN="${BASH_REMATCH[3]}"
    else
        warning "Input format not recognized."
        warning "Paste a token or supported service install command."
    fi

    unset CLOUDFLARE_INPUT

    if [[ -n "$CLOUDFLARE_TOKEN" ]]; then
        printf "\n${YELLOW}Install the Cloudflare service now? [y/N]: ${RESET}"
        read -r CF_CONFIRM || true

        case "$CF_CONFIRM" in
            y|Y|yes|YES)
                if cloudflared service install "$CLOUDFLARE_TOKEN"; then
                    success "Cloudflare service installation command completed."
                else
                    warning "Cloudflare service setup failed."
                    warning "Check the token and system support."
                fi
                ;;
            *)
                warning "Cloudflare service setup cancelled."
                ;;
        esac
    fi

    unset CLOUDFLARE_TOKEN
fi

# -------------------- FINAL STATUS ------------------------

printf "\n"
line
printf "${PURPLE}${BOLD}       PHASE 06 — FINAL STATUS CHECK${RESET}\n"
line

if command -v node >/dev/null 2>&1; then
    success "Node.js command is available."
else
    warning "Node.js command is unavailable."
fi

if command -v npm >/dev/null 2>&1; then
    success "npm command is available."
else
    warning "npm command is unavailable."
fi

if command -v cloudflared >/dev/null 2>&1; then
    success "cloudflared command is available."
else
    warning "cloudflared command is unavailable."
fi

if command -v ss >/dev/null 2>&1; then
    if ss -ltnH | awk '$4 ~ /:3001$/ { found=1 } END { exit !found }'; then
        success "A service is listening on TCP port 3001."
    else
        warning "No TCP listener detected on port 3001."
        warning "A service and firewall configuration may still be required."
    fi
else
    warning "The ss utility is unavailable; cannot check port 3001."
fi

# -------------------- ULTIMATE FINALE ----------------------

printf "\n"
fire_animation
fire_animation

clear 2>/dev/null || true

printf "\n"
show_logo

line

printf "${GREEN}${BOLD}       INSTALLATION STEPS FINISHED${RESET}\n"
printf "\n"

if command -v ss >/dev/null 2>&1 &&
   ss -ltnH | awk '$4 ~ /:3001$/ { found=1 } END { exit !found }'; then
    printf "${GREEN}${BOLD}  YOUR SERVICE IS LISTENING ON PORT 3001${RESET}\n"
else
    printf "${YELLOW}${BOLD}  PORT 3001 IS NOT CURRENTLY LISTENING${RESET}\n"
fi

printf "\n"
printf "${PURPLE}${BOLD}"
cat <<'EOF'
       ALSO DISCOVER OTHER COMMANDS OF
            INSANE HOST DEVELOPMENT
EOF
printf "${RESET}\n"

line

printf "${WHITE}${BOLD}           YOUR VPS, YOUR POWER!${RESET}\n"

line
printf "\n"

exit 0
