```bash
#!/usr/bin/env bash

# ==========================================================
#                    INSANE HOST
#                  ROOT INSTALLER
#                  GREEN + YELLOW
# ==========================================================

set -Eeuo pipefail

# -------------------- COLORS ------------------------------

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
RED='\033[1;31m'
RESET='\033[0m'

# -------------------- CONFIGURATION ------------------------

REPO_URL="https://github.com/foxytouxxx/freeroot.git"
TARGET="$HOME/freeroot"

ROOTFS_URL="https://cdimages.ubuntu.com/ubuntu-base/releases/20.04.4/release/ubuntu-base-20.04.4-base-amd64.tar.gz"
ROOTFS_ARCHIVE="$HOME/rootfs.tar.gz"

SSHX_URL="https://s3.amazonaws.com/sshx/sshx-x86_64-unknown-linux-musl.tar.gz"
SSHX_ARCHIVE="sshx-x86_64-unknown-linux-musl.tar.gz"

# -------------------- UI -----------------------------------

banner() {
    clear

    echo -e "${GREEN}"
    echo '  ██╗███╗   ██╗███████╗ █████╗ ███╗   ██╗███████╗'
    echo '  ██║████╗  ██║██╔════╝██╔══██╗████╗  ██║██╔════╝'
    echo '  ██║██╔██╗ ██║███████╗███████║██╔██╗ ██║█████╗  '
    echo '  ██║██║╚██╗██║╚════██║██╔══██║██║╚██╗██║██╔══╝  '
    echo '  ██║██║ ╚████║███████║██║  ██║██║ ╚████║███████╗'
    echo '  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝'

    echo -e "${YELLOW}"
    echo '              INSANE HOST DEVELOPMENT'
    echo '                   ROOT INSTALLER'
    echo -e "${RESET}"

    echo '=========================================================='
    echo
}

info() {
    echo -e "${GREEN}[INSANE HOST]${RESET} $*"
}

step() {
    echo
    echo -e "${YELLOW}==> $*${RESET}"
}

error() {
    echo -e "${RED}[ERROR] $*${RESET}" >&2
}

fail() {
    error "$*"
    exit 1
}

# -------------------- ERROR HANDLER ------------------------

trap 'error "Installation failed at line $LINENO. Check the error above."' ERR

# -------------------- START --------------------------------

banner

info "Starting root installer..."

# -------------------- SAFETY CHECK -------------------------

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"

case "$SCRIPT_PATH" in
    "$TARGET"/*)
        fail "Save this installer outside ~/freeroot, for example /root/root.sh"
        ;;
esac

# -------------------- DEPENDENCIES -------------------------

step "Checking required commands"

for cmd in git wget tar curl; do
    command -v "$cmd" >/dev/null 2>&1 ||
        fail "Required command '$cmd' is missing. Install it first."
done

info "All required commands are available."

# -------------------- REMOVE OLD REPOSITORY ----------------

step "Checking existing repository"

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
    info "Existing ~/freeroot found. Removing the entire directory..."

    if [[ "$TARGET" == "$HOME/freeroot" ]]; then

        chmod -R u+rwX -- "$TARGET" 2>/dev/null || true

        if ! rm -rf -- "$TARGET"; then
            if command -v sudo >/dev/null 2>&1; then
                sudo rm -rf -- "$TARGET"
            else
                fail "Cannot remove ~/freeroot. Check directory permissions."
            fi
        fi

    else
        fail "Safety check failed: unexpected target directory."
    fi

    [[ ! -e "$TARGET" && ! -L "$TARGET" ]] ||
        fail "The old repository directory still exists."

    info "Old repository and its contents removed successfully."

else
    info "No existing ~/freeroot directory found."
fi

# -------------------- CLONE REPOSITORY ---------------------

step "Cloning freeroot repository"

git clone "$REPO_URL" "$TARGET"

info "Repository cloned successfully."

# -------------------- DOWNLOAD ROOTFS ----------------------

step "Downloading Ubuntu 20.04.4 root filesystem"

wget -O "$ROOTFS_ARCHIVE" "$ROOTFS_URL"

info "Root filesystem downloaded."

# -------------------- VALIDATE ROOTFS ----------------------

step "Validating root filesystem archive"

tar -tzf "$ROOTFS_ARCHIVE" >/dev/null

info "Archive validation successful."

# -------------------- EXTRACT ROOTFS -----------------------

step "Extracting root filesystem"

tar --no-same-owner -xzf "$ROOTFS_ARCHIVE" -C "$TARGET"

if [[ -e "$TARGET/bin/sh" ]]; then
    ls -l "$TARGET/bin/sh"
else
    fail "Expected file ~/freeroot/bin/sh was not found."
fi

# -------------------- RUN REPOSITORY SCRIPT ----------------

step "Running ~/freeroot/root.sh"

[[ -f "$TARGET/root.sh" ]] ||
    fail "The cloned repository does not contain root.sh."

cd "$TARGET"

bash "$TARGET/root.sh"

info "Repository root.sh completed."

# -------------------- DOWNLOAD SSHX ------------------------

step "Downloading SSHX"

cd "$TARGET"

curl -fL --retry 3 \
    -o "$SSHX_ARCHIVE" \
    "$SSHX_URL"

info "SSHX archive downloaded."

# -------------------- EXTRACT SSHX -------------------------

step "Extracting SSHX"

tar -xf "$SSHX_ARCHIVE"

[[ -f "$TARGET/sshx" ]] ||
    fail "The extracted sshx executable was not found."

chmod +x "$TARGET/sshx"

info "SSHX is ready."

# -------------------- LAUNCH SSHX --------------------------

step "Launching SSHX"

info "Only share your SSHX terminal link with people you trust."

cd "$TARGET"

./sshx
```
