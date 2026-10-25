#!/bin/sh

# ==========================================================
#                  INSANE HOST
#             INSANE HOST DEVELOPMENT
#                  ULTIMATE EDITION
# ==========================================================

set -eu
umask 077

# -------------------- BRAND COLORS -------------------------

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
RED='\033[1;31m'
RESET='\033[0m'

if [ ! -t 1 ]; then
    GREEN=''
    YELLOW=''
    WHITE=''
    RED=''
    RESET=''
fi

# -------------------- CONFIGURATION ------------------------

UBUNTU_VERSION="24.04.5"
UBUNTU_CODENAME="noble"

ROOTFS_DIR="$HOME/ubuntu-24.04-rootfs"
TMP_DIR="$HOME/.insane-host-install-$$"

UBUNTU_BASE_URL="https://cdimages.ubuntu.com/ubuntu-base/releases/noble/release"

PROOT_BASE_URL="https://raw.githubusercontent.com/dxomg/vpsfreepterovm/main"

# -------------------- FUNCTIONS ----------------------------

banner() {
    printf '\n'
    printf "${GREEN}  ██╗███╗   ██╗███████╗ █████╗ ███╗   ██╗███████╗${RESET}\n"
    printf "${GREEN}  ██║████╗  ██║██╔════╝██╔══██╗████╗  ██║██╔════╝${RESET}\n"
    printf "${GREEN}  ██║██╔██╗ ██║███████╗███████║██╔██╗ ██║█████╗  ${RESET}\n"
    printf "${YELLOW}  ██║██║╚██╗██║╚════██║██╔══██║██║╚██╗██║██╔══╝  ${RESET}\n"
    printf "${YELLOW}  ██║██║ ╚████║███████║██║  ██║██║ ╚████║███████╗${RESET}\n"
    printf "${YELLOW}  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝${RESET}\n'
    printf '\n'
    printf "${YELLOW}             INSANE HOST DEVELOPMENT${RESET}\n"
    printf "${GREEN}                ULTIMATE EDITION${RESET}\n"
    printf "${WHITE}             Ubuntu ${UBUNTU_VERSION} LTS${RESET}\n"
    printf '\n'
    printf "${GREEN}====================================================${RESET}\n"
    printf '\n'
}

info() {
    printf "${GREEN}[INFO]${RESET} %s\n" "$1"
}

success() {
    printf "${GREEN}[SUCCESS]${RESET} %s\n" "$1"
}

warning() {
    printf "${YELLOW}[WARNING]${RESET} %s\n" "$1"
}

error() {
    printf "${RED}[ERROR]${RESET} %s\n" "$1" >&2
}

cleanup() {
    rm -rf "$TMP_DIR"
}

fail() {
    error "$1"
    exit 1
}

# -------------------- START --------------------------------

banner

info "Detecting system architecture..."

ARCH="$(uname -m)"

case "$ARCH" in
    x86_64)
        UBUNTU_ARCH="amd64"
        PROOT_ARCH="x86_64"
        ;;
    aarch64|arm64)
        UBUNTU_ARCH="arm64"
        PROOT_ARCH="aarch64"
        ;;
    *)
        fail "Unsupported architecture: $ARCH"
        ;;
esac

success "Architecture detected: $ARCH"

# -------------------- DEPENDENCIES -------------------------

for CMD in wget tar sha256sum; do
    if ! command -v "$CMD" >/dev/null 2>&1; then
        fail "Required command '$CMD' is missing. Install it first."
    fi
done

# -------------------- EXISTING INSTALLATION ----------------

if [ -f "$ROOTFS_DIR/.installed" ] &&
   [ -x "$ROOTFS_DIR/usr/local/bin/proot" ] &&
   [ -x "$ROOTFS_DIR/bin/bash" ]; then

    success "Ubuntu 24.04 is already installed."
else
    # Never overwrite an existing Ubuntu 22.04 rootfs.
    # A separate directory is used for Ubuntu 24.04.

    if [ -e "$ROOTFS_DIR" ]; then
        warning "An incomplete Ubuntu 24.04 installation was found."
        warning "Preserving the existing directory."
        fail "Back up or rename $ROOTFS_DIR, then run this script again."
    fi

    mkdir -p "$TMP_DIR/rootfs"

    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM

    ARCHIVE_NAME="ubuntu-base-${UBUNTU_VERSION}-base-${UBUNTU_ARCH}.tar.gz"

    info "Downloading Ubuntu ${UBUNTU_VERSION} root filesystem..."

    if ! wget -O "$TMP_DIR/$ARCHIVE_NAME" \
        "$UBUNTU_BASE_URL/$ARCHIVE_NAME"; then
        fail "Ubuntu download failed. Check your internet connection."
    fi

    # ---------------- SHA256 VERIFICATION ------------------

    info "Downloading official Ubuntu checksums..."

    if ! wget -O "$TMP_DIR/SHA256SUMS" \
        "$UBUNTU_BASE_URL/SHA256SUMS"; then
        fail "Could not download Ubuntu checksum file."
    fi

    if ! grep -E "^[[:xdigit:]]{64}[[:space:]]+\\*?${ARCHIVE_NAME}\$" \
        "$TMP_DIR/SHA256SUMS" > "$TMP_DIR/checksum.txt"; then
        fail "The archive checksum was not found."
    fi

    info "Verifying Ubuntu archive integrity..."

    (
        cd "$TMP_DIR"
        sha256sum -c checksum.txt
    ) || fail "Ubuntu archive checksum verification failed."

    success "Ubuntu archive checksum verified."

    # ---------------- EXTRACT ROOTFS -----------------------

    info "Extracting Ubuntu root filesystem..."

    if ! tar -xzf "$TMP_DIR/$ARCHIVE_NAME" \
        -C "$TMP_DIR/rootfs"; then
        fail "Ubuntu root filesystem extraction failed."
    fi

    if [ ! -x "$TMP_DIR/rootfs/bin/bash" ]; then
        fail "Ubuntu archive does not contain the expected Bash executable."
    fi

    # ---------------- INSTALL PROOT ------------------------

    mkdir -p "$TMP_DIR/rootfs/usr/local/bin"

    PROOT_URL="$PROOT_BASE_URL/proot-$PROOT_ARCH"

    info "Downloading PRoot for $PROOT_ARCH..."

    if ! wget -O "$TMP_DIR/rootfs/usr/local/bin/proot" \
        "$PROOT_URL"; then
        fail "PRoot download failed. Check the configured source."
    fi

    if [ ! -s "$TMP_DIR/rootfs/usr/local/bin/proot" ]; then
        fail "Downloaded PRoot file is empty."
    fi

    chmod 755 "$TMP_DIR/rootfs/usr/local/bin/proot"

    # ---------------- DNS CONFIGURATION --------------------

    info "Configuring DNS..."

    # Replace any existing resolv.conf symlink inside
    # the new rootfs so the file can be written directly.

    rm -f "$TMP_DIR/rootfs/etc/resolv.conf"

    printf 'nameserver 1.1.1.1\nnameserver 1.0.0.1\n' \
        > "$TMP_DIR/rootfs/etc/resolv.conf"

    # ---------------- INSTALLATION MARKER ------------------

    printf 'Ubuntu %s\nArchitecture: %s\n' \
        "$UBUNTU_VERSION" "$UBUNTU_ARCH" \
        > "$TMP_DIR/rootfs/.installed"

    # Move the completed installation into place.
    mv "$TMP_DIR/rootfs" "$ROOTFS_DIR"

    success "Ubuntu ${UBUNTU_VERSION} installation completed."

    cleanup
    trap - EXIT INT TERM
fi

# -------------------- LAUNCH UBUNTU -------------------------

printf '\n'
printf "${GREEN}====================================================${RESET}\n"
printf "${YELLOW}         STARTING INSANE HOST UBUNTU${RESET}\n"
printf "${GREEN}====================================================${RESET}\n"
printf '\n'

info "Ubuntu Version: ${UBUNTU_VERSION}"
info "Architecture: ${UBUNTU_ARCH}"
info "Root filesystem: $ROOTFS_DIR"

printf '\n'
printf "${YELLOW}Type 'exit' to leave Ubuntu.${RESET}\n"
printf "${GREEN}INSANE HOST DEVELOPMENT${RESET}\n"
printf '\n'

# -------------------- START PROOT --------------------------

exec "$ROOTFS_DIR/usr/local/bin/proot" \
    -r "$ROOTFS_DIR" \
    -0 \
    -w /root \
    -b /dev \
    -b /proc \
    -b /sys \
    --kill-on-exit \
    /usr/bin/env -i \
    HOME=/root \
    USER=root \
    LOGNAME=root \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    TERM="${TERM:-xterm}" \
    /bin/bash --login
