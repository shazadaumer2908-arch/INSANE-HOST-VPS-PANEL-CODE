#!/usr/bin/env bash

# ==========================================================

# INSANE HOST DEVELOPMENT

# ULTIMATE EDITION

# ==========================================================

set -Eeuo pipefail

# -------------------- COLORS ------------------------------

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BRIGHT_GREEN='\033[1;92m'
BRIGHT_YELLOW='\033[1;93m'
RED='\033[1;31m'
RESET='\033[0m'

# -------------------- CONFIGURATION -----------------------

REPO_URL="https://github.com/foxytouxxx/freeroot.git"
TARGET="$HOME/freeroot"

ROOTFS_URL="https://cdimages.ubuntu.com/ubuntu-base/releases/20.04.4/release/ubuntu-base-20.04.4-base-amd64.tar.gz"
ROOTFS_ARCHIVE="$HOME/rootfs.tar.gz"

SSHX_URL="https://s3.amazonaws.com/sshx/sshx-x86_64-unknown-linux-musl.tar.gz"
SSHX_ARCHIVE="sshx-x86_64-unknown-linux-musl.tar.gz"

# -------------------- OUTPUT FUNCTIONS --------------------

info() {
printf '%b\n' "${BRIGHT_GREEN}[INSANE HOST]${RESET} $*"
}

notice() {
printf '%b\n' "${BRIGHT_YELLOW}[NOTICE]${RESET} $*"
}

error() {
printf '%b\n' "${RED}[ERROR]${RESET} $*" >&2
}

separator() {
printf '%b\n' "${YELLOW}==========================================================${RESET}"
}

step() {
printf '\n'
separator
printf '%b\n' "${BRIGHT_GREEN}  $*${RESET}"
separator
printf '\n'
}

fail() {
error "$*"
error "Installation stopped. No existing directory was automatically deleted."
exit 1
}

# -------------------- FIRE EFFECT -------------------------

fire_effect() {
local i

```
[[ -t 1 ]] || return 0

for i in {1..3}; do
    printf '\r%b' "${BRIGHT_GREEN}             *   .   *   .   *${RESET}"
    sleep 0.12

    printf '\r%b' "${BRIGHT_YELLOW}           .  *  . * .  *  .${RESET}"
    sleep 0.12

    printf '\r%b' "${BRIGHT_GREEN}         *  .  *  .  *  .  *${RESET}"
    sleep 0.12

    printf '\r%b' "${BRIGHT_YELLOW}           .  *  . * .  *  .${RESET}"
    sleep 0.12

    printf '\r%b' "${BRIGHT_GREEN}             *   .   *   .   *${RESET}"
    sleep 0.12
done

printf '\r%40s\r\n' ' '
```

}

# -------------------- ORIGINAL BRANDING -------------------

banner() {
if [[ -t 1 ]]; then
printf '\033[2J\033[H'
fi

```
printf '%b' "${GREEN}"
printf '  ██╗███╗   ██╗███████╗ █████╗ ███╗   ██╗███████╗\n'
printf '  ██║████╗  ██║██╔════╝██╔══██╗████╗  ██║██╔════╝\n'
printf '  ██║██╔██╗ ██║███████╗███████║██╔██╗ ██║█████╗  \n'
printf '  ██║██║╚██╗██║╚════██║██╔══██║██║╚██╗██║██╔══╝  \n'
printf '  ██║██║ ╚████║███████║██║  ██║██║ ╚████║███████╗\n'
printf '  ╚═╝╚═╝  ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚══════╝\n'

printf '%b' "${YELLOW}"
printf '             INSANE HOST DEVELOPMENT\n'
printf '                  ULTIMATE EDITION\n'
printf '%b\n' "${RESET}"

separator
printf '\n'

fire_effect

printf '%b\n' "${BRIGHT_GREEN}          INSANE HOST DEVELOPMENT TEAM${RESET}"
printf '%b\n' "${BRIGHT_YELLOW}                 ULTIMATE OG EDITION${RESET}"

separator
printf '\n'
```

}

# -------------------- ERROR HANDLING ----------------------

trap 'error "Command failed at line $LINENO: $BASH_COMMAND"' ERR

# -------------------- START -------------------------------

banner

info "Welcome to INSANE HOST ULTIMATE OG EDITION."
info "Developed by INSANE HOST DEVELOPMENT TEAM."

# -------------------- SYSTEM CHECKS -----------------------

step "Checking system requirements"

if [[ "$(uname -m)" != "x86_64" ]]; then
fail "This configuration requires an x86_64 system."
fi

for cmd in git wget curl tar bash; do
command -v "$cmd" >/dev/null 2>&1 ||
fail "Required command '$cmd' is missing."
done

info "All required commands are available."

# -------------------- DIRECTORY SAFETY --------------------

step "Checking installation directory"

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
fail "$TARGET already exists. It has NOT been deleted. Move or rename it manually before retrying."
fi

# -------------------- STEP 1 ------------------------------

step "STEP 1/7 - CLONING FREEROOT"

cd "$HOME"

info "Running: git clone $REPO_URL"
git clone "$REPO_URL"

[[ -d "$TARGET/.git" ]] ||
fail "Repository clone could not be verified."

info "Repository cloned successfully."

# -------------------- STEP 2 ------------------------------

step "STEP 2/7 - ENTERING FREEROOT"

info "Running: cd freeroot"
cd freeroot

info "Running: cd ~/freeroot"
cd "$HOME/freeroot"

# -------------------- STEP 3 ------------------------------

step "STEP 3/7 - DOWNLOADING UBUNTU ROOTFS"

info "Downloading Ubuntu Base 20.04.4..."
notice "Please wait for the download to complete."

wget --show-progress -O "$ROOTFS_ARCHIVE" "$ROOTFS_URL"

[[ -s "$ROOTFS_ARCHIVE" ]] ||
fail "Rootfs archive is missing or empty."

info "Validating rootfs archive..."

tar -tzf "$ROOTFS_ARCHIVE" >/dev/null ||
fail "Rootfs archive is invalid or incomplete."

info "Rootfs archive validation successful."

# -------------------- STEP 4 ------------------------------

step "STEP 4/7 - EXTRACTING UBUNTU ROOTFS"

info "Extracting files into $TARGET..."
notice "Extraction may take several minutes."

tar --no-same-owner -xzf "$ROOTFS_ARCHIVE" -C "$HOME/freeroot"

[[ -e "$HOME/freeroot/bin/sh" ]] ||
fail "Expected Ubuntu shell was not found after extraction."

ls -l "$HOME/freeroot/bin/sh"

info "Ubuntu rootfs extracted successfully."

# -------------------- STEP 5 ------------------------------

step "STEP 5/7 - STARTING FREEROOT"

cd "$HOME/freeroot"

[[ -f "$HOME/freeroot/root.sh" ]] ||
fail "The cloned repository's root.sh was not found."

info "Running: bash root.sh"
notice "Follow the prompts displayed by FreeRoot."
notice "If it asks whether to install Ubuntu, enter YES to continue."
notice "SSHX starts after the interactive FreeRoot shell exits."

bash "$HOME/freeroot/root.sh"

# -------------------- STEP 6 ------------------------------

step "STEP 6/7 - DOWNLOADING SSHX"

cd "$HOME/freeroot"

info "Downloading SSHX..."
notice "Download progress will appear below."

curl -k -L --fail --show-error --progress-bar 
-o "$SSHX_ARCHIVE" "$SSHX_URL"

[[ -s "$SSHX_ARCHIVE" ]] ||
fail "SSHX archive download failed."

info "SSHX downloaded successfully."

# -------------------- STEP 7 ------------------------------

step "STEP 7/7 - EXTRACTING SSHX"

tar -xf "$SSHX_ARCHIVE" -C "$HOME/freeroot"

[[ -f "$HOME/freeroot/sshx" ]] ||
fail "SSHX executable was not found after extraction."

chmod +x "$HOME/freeroot/sshx"

info "SSHX extraction successful."

# -------------------- FINAL OG BRANDING -------------------

printf '\n'
printf '%b' "${GREEN}"
printf '  ██╗███╗   ██╗███████╗ █████╗ ███╗   ██╗███████╗\n'
printf '  ██║████╗  ██║██╔════╝██╔══██╗████╗  ██║██╔════╝\n'
printf '  ██║██╔██╗ ██║███████╗███████║██╔██╗ ██║█████╗  \n'
printf '  ██║██║╚██╗██║╚════██║██╔══██║██║╚██╗██║██╔══╝  \n'
printf '  ██║██║ ╚████║███████║██║  ██║██║ ╚████║███████╗\n'
printf '  ╚═╝╚═╝  ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚══════╝\n'

printf '%b' "${YELLOW}"
printf '             INSANE HOST DEVELOPMENT\n'
printf '                  ULTIMATE EDITION\n'
printf '%b\n' "${RESET}"

separator

printf '%b\n' "${BRIGHT_GREEN}          INSTALLATION STEPS COMPLETED${RESET}"
printf '%b\n' "${BRIGHT_YELLOW}       CREDITS: INSANE HOST DEVELOPMENT TEAM${RESET}"

separator

cd "$HOME/freeroot"

info "Launching SSHX..."

exec ./sshx
