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
BOLD='\033[1m'

# -------------------- CONFIGURATION -----------------------

REPO_URL="https://github.com/foxytouxxx/freeroot.git"
TARGET="$HOME/freeroot"

ROOTFS_URL="https://cdimages.ubuntu.com/ubuntu-base/releases/20.04.4/release/ubuntu-base-20.04.4-base-amd64.tar.gz"
ROOTFS_ARCHIVE="$HOME/rootfs.tar.gz"

SSHX_URL="https://s3.amazonaws.com/sshx/sshx-x86_64-unknown-linux-musl.tar.gz"
SSHX_ARCHIVE="$HOME/sshx-x86_64-unknown-linux-musl.tar.gz"

# -------------------- OUTPUT FUNCTIONS --------------------

info() {
printf "${BRIGHT_GREEN}[INSANE HOST]${RESET} %s\n" "$*"
}

notice() {
printf "${BRIGHT_YELLOW}[NOTICE]${RESET} %s\n" "$*"
}

error() {
printf "${RED}[ERROR]${RESET} %s\n" "$*" >&2
}

separator() {
printf "${YELLOW}%s${RESET}\n" 
'=========================================================='
}

step() {
printf '\n'
separator
printf "${BRIGHT_GREEN}  %s${RESET}\n" "$*"
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
if [[ ! -t 1 ]]; then
    return 0
fi

printf '\n'

for i in {1..3}; do
    printf "\r${BRIGHT_GREEN}              *   .   *   .   *${RESET}"
    sleep 0.12

    printf "\r${BRIGHT_YELLOW}            .  *  . * .  *  .${RESET}   "
    sleep 0.12

    printf "\r${BRIGHT_GREEN}          *  .  *  .  *  .  *${RESET}     "
    sleep 0.12

    printf "\r${BRIGHT_YELLOW}            .  *  . * .  *  .${RESET}   "
    sleep 0.12

    printf "\r${BRIGHT_GREEN}              *   .   *   .   *${RESET}"
    sleep 0.12
done

printf '\r%45s\r' ' '
printf '\n'
```

}

# -------------------- ORIGINAL OG BRANDING ----------------

show_banner() {
if [[ -t 1 ]]; then
printf '\033[2J\033[H'
fi

```
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

fire_effect

printf "${BRIGHT_GREEN}"
printf '          INSANE HOST DEVELOPMENT TEAM\n'
printf "${BRIGHT_YELLOW}"
printf '             ULTIMATE OG EDITION\n'
printf "${RESET}\n"

separator
printf '\n'
```

}

# -------------------- ERROR HANDLING ----------------------

trap 'error "Command failed at line $LINENO: $BASH_COMMAND"' ERR

# -------------------- STARTUP -----------------------------

show_banner

info "Welcome to the ULTIMATE OG EDITION."
info "Developed by INSANE HOST DEVELOPMENT TEAM."
info "Initializing installation..."

# -------------------- SYSTEM CHECKS -----------------------

step "SYSTEM REQUIREMENTS"

if [[ "$(uname -m)" != "x86_64" ]]; then
fail "This configuration uses x86_64 Ubuntu and SSHX archives."
fi

for cmd in git wget curl tar bash; do
command -v "$cmd" >/dev/null 2>&1 
|| fail "Required command '$cmd' is missing."
done

info "System requirements verified."

# -------------------- DIRECTORY SAFETY --------------------

step "DIRECTORY SAFETY CHECK"

if [[ -e "$TARGET" ]]; then
fail "$TARGET already exists. It has NOT been deleted. Move or rename it manually before retrying."
fi

info "Target directory is available."

# -------------------- STEP 1 ------------------------------

step "STEP 1/7 - CLONING FREEROOT"

cd "$HOME"

info "Running: git clone $REPO_URL"
git clone "$REPO_URL"

info "Repository cloned successfully."

# -------------------- STEP 2 ------------------------------

step "STEP 2/7 - ENTERING FREEROOT"

info "Running: cd freeroot"
cd freeroot

info "Running: cd ~/freeroot"
cd "$HOME/freeroot"

info "Current directory: $PWD"

# -------------------- STEP 3 ------------------------------

step "STEP 3/7 - DOWNLOADING UBUNTU ROOTFS"

info "Downloading Ubuntu Base 20.04.4..."
notice "Please wait for the download to finish."

wget --show-progress -O "$ROOTFS_ARCHIVE" "$ROOTFS_URL"

[[ -s "$ROOTFS_ARCHIVE" ]] 
|| fail "The downloaded rootfs archive is missing or empty."

info "Validating the archive..."

tar -tzf "$ROOTFS_ARCHIVE" >/dev/null 
|| fail "The rootfs archive is invalid or incomplete."

info "Archive validation successful."

# -------------------- STEP 4 ------------------------------

step "STEP 4/7 - EXTRACTING UBUNTU ROOTFS"

info "Extracting Ubuntu rootfs into $HOME/freeroot..."
notice "Extraction can take several minutes."

tar --no-same-owner -xzf "$ROOTFS_ARCHIVE" -C "$HOME/freeroot"

info "Checking the extracted shell..."

ls -l "$HOME/freeroot/bin/sh"

[[ -e "$HOME/freeroot/bin/sh" ]] 
|| fail "Ubuntu shell was not found after extraction."

info "Ubuntu rootfs extraction completed."

# -------------------- STEP 5 ------------------------------

step "STEP 5/7 - STARTING FREEROOT"

cd "$HOME/freeroot"

info "Running: bash root.sh"
notice "Follow any prompts shown by the FreeRoot installer."
notice "If it asks whether to install Ubuntu, respond YES to continue."
notice "FreeRoot may open an interactive Ubuntu shell."
notice "SSHX will start after that shell exits."

bash root.sh

# -------------------- STEP 6 ------------------------------

step "STEP 6/7 - DOWNLOADING SSHX"

cd "$HOME/freeroot"

info "Running SSHX download..."
notice "Download progress will appear below."

curl -k -LO "$SSHX_URL"

[[ -s "$SSHX_ARCHIVE" ]] 
|| fail "SSHX archive was not downloaded successfully."

info "SSHX download completed."

# -------------------- STEP 7 ------------------------------

step "STEP 7/7 - EXTRACTING SSHX"

info "Running: tar -xf sshx-x86_64-unknown-linux-musl.tar.gz"

tar -xf sshx-x86_64-unknown-linux-musl.tar.gz

[[ -f "$HOME/freeroot/sshx" ]] 
|| fail "SSHX executable was not found after extraction."

chmod +x "$HOME/freeroot/sshx"

info "SSHX executable is ready."

# -------------------- FINAL OG BRANDING -------------------

printf '\n'
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

separator

printf "${BRIGHT_GREEN}"
printf '            INSTALLATION STEPS COMPLETED\n'
printf "${BRIGHT_YELLOW}"
printf '         CREDITS: INSANE HOST DEVELOPMENT TEAM\n'
printf "${RESET}\n"

separator

cd "$HOME/freeroot"

info "Launching SSHX..."

exec ./sshx
