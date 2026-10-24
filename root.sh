#!/usr/bin/env bash
# INSANE HOST — Ultimate Root Tool
# Review this script and all downloaded code before running it.
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
  printf '%b' "$GREEN"
  printf '  ██╗███╗   ██╗███████╗ █████╗ ███╗   ██╗███████╗\n'
  printf '  ██║████╗  ██║██╔════╝██╔══██╗████╗  ██║██╔════╝\n'
  printf '  ██║██╔██╗ ██║███████╗███████║██╔██╗ ██║█████╗  \n'
  printf '  ██║██║╚██╗██║╚════██║██╔══██║██║╚██╗██║██╔══╝  \n'
  printf '  ██║██║ ╚████║███████║██║  ██║██║ ╚████║███████╗\n'
  printf '  ╚═╝╚═╝  ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚══════╝\n'
  printf '%b' "$YELLOW"
  printf '              INSANE HOST DEVELOPMENT\n'
  printf '                 ULTIMATE EDITION\n'
  printf '%b\n' "$RESET"
  printf '%s\n\n' '=========================================================='
}

info()  { printf '%b\n' "${GREEN}[SUCCESS]${RESET} $*"; }
step()  { printf '\n%b\n' "${YELLOW}==> $*${RESET}"; }
warn()  { printf '%b\n' "${YELLOW}[WARNING]${RESET} $*" >&2; }
error() { printf '%b\n' "${RED}[ERROR]${RESET} $*" >&2; }
fail()  { error "$*"; exit 1; }
confirm() {
  local answer
  read -r -p "$1 [y/N] " answer
  [[ "$answer" == "y" || "$answer" == "Y" ]]
}

trap 'error "Command failed at line $LINENO. Check the message above."' ERR

# -------------------- START --------------------------------
banner
info "Welcome to INSANE HOST Ultimate Root Tool!"
warn "This downloads third-party code. The repository script and SSHX can execute code or expose a remotely accessible session."
confirm "Continue?" || exit 0

# -------------------- SAFETY CHECK ------------------------
step "Checking installation path"
[[ "$TARGET" == "$HOME/freeroot" ]] || fail "Unexpected installation path."
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
case "$SCRIPT_PATH" in
  "$TARGET"/*) fail "Save this installer outside ~/freeroot, such as ~/insane-host.sh." ;;
esac

# -------------------- DEPENDENCIES -------------------------
step "Checking required commands"
for cmd in git wget tar curl; do
  command -v "$cmd" >/dev/null 2>&1 || fail "Required command '$cmd' is missing."
done
info "All required commands are available."

# -------------------- CLONE REPOSITORY --------------------
step "Cloning freeroot repository"
if [[ -e "$TARGET" || -L "$TARGET" ]]; then
  fail "$TARGET already exists. It has NOT been deleted. Move or rename it manually before running this installer."
fi
git clone "$REPO_URL" "$TARGET"
[[ -d "$TARGET/.git" ]] || fail "Repository clone could not be verified."
info "Repository cloned successfully."

# -------------------- DOWNLOAD ROOTFS ----------------------
step "Downloading Ubuntu 20.04.4 root filesystem"
wget --show-progress -O "$ROOTFS_ARCHIVE" "$ROOTFS_URL"
[[ -s "$ROOTFS_ARCHIVE" ]] || fail "Root filesystem archive is missing or empty."
info "Root filesystem downloaded."

# -------------------- VALIDATE AND EXTRACT -----------------
step "Validating root filesystem archive"
tar -tzf "$ROOTFS_ARCHIVE" >/dev/null
info "Root filesystem archive is valid."

step "Extracting root filesystem"
tar --no-same-owner -xzf "$ROOTFS_ARCHIVE" -C "$TARGET"
[[ -e "$TARGET/bin/sh" ]] || fail "Extraction finished, but bin/sh was not found."
ls -l "$TARGET/bin/sh"
info "Root filesystem extracted successfully."

# -------------------- RUN REPOSITORY SCRIPT ---------------
step "Repository root.sh"
[[ -f "$TARGET/root.sh" ]] || fail "The cloned repository does not contain root.sh."
warn "Review $TARGET/root.sh before running it; it is third-party code."
if confirm "Run the repository's root.sh now?"; then
  (cd "$TARGET" && bash "$TARGET/root.sh")
  info "Repository root.sh completed."
else
  warn "Skipped repository root.sh. Stopping before SSHX setup."
  exit 0
fi

# -------------------- DOWNLOAD SSHX -----------------------
step "Downloading SSHX"
curl -fL --retry 3 -o "$TARGET/$SSHX_ARCHIVE" "$SSHX_URL"
[[ -s "$TARGET/$SSHX_ARCHIVE" ]] || fail "SSHX archive download failed."
info "SSHX downloaded successfully."

# -------------------- EXTRACT SSHX -------------------------
step "Extracting SSHX"
# Show archive contents for review before extracting.
tar -tf "$TARGET/$SSHX_ARCHIVE"
if ! confirm "Extract this archive into $TARGET?"; then
  warn "Skipped SSHX extraction."
  exit 0
fi
tar -xf "$TARGET/$SSHX_ARCHIVE" -C "$TARGET"
[[ -f "$TARGET/sshx" ]] || fail "SSHX executable was not found after extraction."
chmod +x "$TARGET/sshx"
info "SSHX extraction completed."

# -------------------- LAUNCH SSHX --------------------------
step "Launch SSHX"
warn "Only share any SSHX terminal link with people you trust."
if confirm "Launch SSHX now? This may create a remotely accessible session."; then
  cd "$TARGET"
  exec ./sshx
else
  info "Setup complete; SSHX was not launched."
fi
