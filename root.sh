```bash
#!/usr/bin/env bash

# ==========================================================
#                     INSANE HOST
#                  ULTIMATE ROOT TOOL
#                    GREEN + YELLOW
# ==========================================================

set -Eeuo pipefail

# -------------------- COLORS ------------------------------

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
RED='\033[1;31m'
CYAN='\033[1;36m'
RESET='\033[0m'

# -------------------- CONFIGURATION -----------------------

REPO_URL="https://github.com/foxytouxxx/freeroot.git"
TARGET="$HOME/freeroot"

ROOTFS_URL="https://cdimages.ubuntu.com/ubuntu-base/releases/20.04.4/release/ubuntu-base-20.04.4-base-amd64.tar.gz"
ROOTFS_ARCHIVE="$HOME/rootfs.tar.gz"

SSHX_URL="https://s3.amazonaws.com/sshx/sshx-x86_64-unknown-linux-musl.tar.gz"
SSHX_ARCHIVE="sshx-x86_64-unknown-linux-musl.tar.gz"

# -------------------- TERMINAL UI -------------------------

banner() {
    clear || true

    echo -e "${GREEN}"
    echo '  ██╗███╗   ██╗███████╗ █████╗ ███╗   ██╗███████╗'
    echo '  ██║████╗  ██║██╔════╝██╔══██╗████╗  ██║██╔════╝'
    echo '  ██║██╔██╗ ██║███████╗███████║██╔██╗ ██║█████╗  '
    echo '  ██║██║╚██╗██║╚════██║██╔══██║██║╚██╗██║██╔══╝  '
    echo '  ██║██║ ╚████║███████║██║  ██║██║ ╚████║███████╗'
    echo '  ╚═╝╚═╝  ╚════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚══════╝'

    echo -e "${YELLOW}"
    echo '              INSANE HOST DEVELOPMENT'
    echo '                 ULTIMATE EDITION'
    echo -e "${RESET}"

    echo '=========================================================='
    echo
}

info() {
    echo -e "${GREEN}[SUCCESS]${RESET} $*"
}

step() {
    echo
    echo -e "${YELLOW}==> $*${RESET}"
}

warn() {
    echo -e "${YELLOW}[WARNING]${RESET} $*" >&2
}

error() {
    echo -e "${RED}[ERROR]${RESET} $*" >&2
}

fail() {
    error "$*"
    exit 1
}

# -------------------- ERROR HANDLING ----------------------

trap 'error "Command failed at line $LINENO. Check the message above."' ERR

# -------------------- START -------------------------------

banner

info "Welcome to INSANE HOST Ultimate Root Tool!"

# -------------------- SAFETY CHECK ------------------------

step "Checking installation path"

[[ "$TARGET" == "$HOME/freeroot" ]] ||
    fail "Unexpected installation path."

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"

case "$SCRIPT_PATH" in
    "$TARGET"/*)
        fail "Save this installer outside ~/freeroot, such as /root/root.sh."
        ;;
esac

# -------------------- DEPENDENCIES ------------------------

step "Checking required commands"

for cmd in git wget tar curl; do
    command -v "$cmd" >/dev/null 2>&1 ||
        fail "Required command '$cmd' is missing."
done

info "All required commands are available."

# -------------------- CLONE REPOSITORY ---------------------

step "Cloning freeroot repository"

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
    fail "~/freeroot already exists. Move it or choose another target before running this installer."
fi

git clone "$REPO_URL" "$TARGET"

[[ -d "$TARGET/.git" ]] ||
    fail "Repository clone could not be verified."

info "Repository cloned successfully."

# -------------------- DOWNLOAD ROOTFS ----------------------

step "Downloading Ubuntu 20.04.4 root filesystem"

wget -O "$ROOTFS_ARCHIVE" "$ROOTFS_URL"

[[ -s "$ROOTFS_ARCHIVE" ]] ||
    fail "Root filesystem archive is missing or empty."

info "Root filesystem downloaded."

# -------------------- VALIDATE ARCHIVE ---------------------

step "Validating root filesystem archive"

tar -tzf "$ROOTFS_ARCHIVE" >/dev/null

info "Root filesystem archive is valid."

# -------------------- EXTRACT ROOTFS -----------------------

step "Extracting root filesystem"

tar --no-same-owner -xzf "$ROOTFS_ARCHIVE" -C "$TARGET"

[[ -e "$TARGET/bin/sh" ]] ||
    fail "Extraction finished, but bin/sh was not found."

ls -l "$TARGET/bin/sh"

info "Root filesystem extracted successfully."

# -------------------- RUN REPOSITORY SCRIPT ----------------

step "Running repository root.sh"

[[ -f "$TARGET/root.sh" ]] ||
    fail "The cloned repository does not contain root.sh."

cd "$TARGET"

bash "$TARGET/root.sh"

info "Repository root.sh completed."

# -------------------- DOWNLOAD SSHX ------------------------

step "Downloading SSHX"

curl -fL --retry 3 \
    -o "$TARGET/$SSHX_ARCHIVE" \
    "$SSHX_URL"

[[ -s "$TARGET/$SSHX_ARCHIVE" ]] ||
    fail "SSHX archive download failed."

info "SSHX downloaded successfully."

# -------------------- EXTRACT SSHX -------------------------

step "Extracting SSHX"

tar -xf "$TARGET/$SSHX_ARCHIVE" -C "$TARGET"

[[ -f "$TARGET/sshx" ]] ||
    fail "SSHX executable was not found after extraction."

chmod +x "$TARGET/sshx"

info "SSHX extraction completed."

# -------------------- LAUNCH SSHX --------------------------

step "Launching SSHX"

warn "Only share your SSHX terminal link with people you trust."

cd "$TARGET"

./sshx
```
