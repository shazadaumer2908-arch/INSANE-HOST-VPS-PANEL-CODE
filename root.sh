bash
#!/usr/bin/env bash

# ==========================================================
#                     INSANE HOST
#                  ULTIMATE ROOT TOOL
#                    GREEN + YELLOW
# ==========================================================

set -Eeuo pipefail

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

REPO_URL="https://github.com/foxytouxxx/freeroot.git"
TARGET="$HOME/freeroot"

SSHX_URL="https://s3.amazonaws.com/sshx/sshx-x86_64-unknown-linux-musl.tar.gz"
SSHX_ARCHIVE="$HOME/sshx-x86_64-unknown-linux-musl.tar.gz"

info() {
    printf "${GREEN}[INSANE HOST]${RESET} %s\n" "$*"
}

step() {
    printf "\n${YELLOW}==> %s${RESET}\n" "$*"
}

fail() {
    printf "${RED}[ERROR] %s${RESET}\n" "$*" >&2
    exit 1
}

banner() {
    clear 2>/dev/null || true

    printf "${GREEN}"
    printf '  ██╗███╗   ██╗███████╗ █████╗ ███╗   ██╗███████╗\n'
    printf '  ██║████╗  ██║██╔════╝██╔══██╗████╗  ██║██╔════╝\n'
    printf '  ██║██╔██╗ ██║███████╗███████║██╔██╗ ██║█████╗  \n'
    printf '  ██║██║╚██╗██║╚════██║██╔══██║██║╚██╗██║██╔══╝  \n'
    printf '  ██║██║ ╚████║███████║██║  ██║██║ ╚████║███████╗\n'
    printf '  ╚═╝╚═╝  ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚══════╝\n'
    printf "${YELLOW}"
    printf '             INSANE HOST DEVELOPMENT\n'
    printf '                  ULTIMATE EDITION\n'
    printf "${RESET}\n"
    printf '%s\n\n' '=========================================================='
}

banner

info "Starting INSANE HOST installer..."

# -------------------- DEPENDENCIES -------------------------

step "Checking dependencies"

for cmd in git curl tar; do
    command -v "$cmd" >/dev/null 2>&1 ||
        fail "Missing command: $cmd"
done

info "Dependencies verified."

# -------------------- ARCHITECTURE -------------------------

step "Checking CPU architecture"

ARCH="$(uname -m)"

case "$ARCH" in
    x86_64)
        SSHX_FILE="sshx-x86_64-unknown-linux-musl.tar.gz"
        ;;
    aarch64|arm64)
        fail "The configured SSHX download is for x86_64. Install an ARM64-compatible SSHX build first."
        ;;
    *)
        fail "Unsupported CPU architecture: $ARCH"
        ;;
esac

info "Architecture: $ARCH"

# -------------------- REPOSITORY ---------------------------

step "Preparing repository"

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
    fail "$TARGET already exists. This installer will not delete your files. Rename or move the existing directory before retrying."
fi

step "Cloning freeroot"

git clone "$REPO_URL" "$TARGET" ||
    fail "Git clone failed. Check the repository URL and network."

[[ -f "$TARGET/root.sh" ]] ||
    fail "The repository root.sh was not found."

info "Repository cloned successfully."

# -------------------- INSTALL ROOT ENVIRONMENT --------------

step "Starting the repository installer"

cd "$TARGET"

bash "$TARGET/root.sh"

info "The repository installer has exited."

# -------------------- SSHX DOWNLOAD ------------------------

step "Downloading SSHX"

curl -fL --retry 3 \
    -o "$SSHX_ARCHIVE" \
    "$SSHX_URL" ||
    fail "SSHX download failed."

[[ -s "$SSHX_ARCHIVE" ]] ||
    fail "SSHX archive is empty."

info "SSHX downloaded successfully."

# -------------------- SSHX EXTRACTION -----------------------

step "Extracting SSHX"

mkdir -p "$HOME/sshx-extract"

tar -xf "$SSHX_ARCHIVE" -C "$HOME/sshx-extract" ||
    fail "SSHX extraction failed."

[[ -f "$HOME/sshx-extract/sshx" ]] ||
    fail "SSHX executable was not found."

chmod +x "$HOME/sshx-extract/sshx"

# -------------------- LAUNCH SSHX ---------------------------

step "Launching SSHX"

info "Only share the terminal link with people you trust."

exec "$HOME/sshx-extract/sshx"

