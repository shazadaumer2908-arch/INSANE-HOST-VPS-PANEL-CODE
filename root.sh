```
#!/bin/sh

# ==========================================================
#                  INSANE HOST
#             INSANE HOST DEVELOPMENT
#                  ULTIMATE EDITION
# ==========================================================

set -eu
umask 077

# -------------------- COLORS -------------------------------

if [ -t 1 ]; then
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    WHITE='\033[1;37m'
    RED='\033[1;31m'
    RESET='\033[0m'
else
    GREEN=''
    YELLOW=''
    WHITE=''
    RED=''
    RESET=''
fi

# -------------------- CONFIGURATION ------------------------

UBUNTU_VERSION='24.04.5'
ROOTFS_DIR="${HOME:?HOME is not set}/ubuntu-24.04-rootfs"

UBUNTU_BASE_URL='https://cdimages.ubuntu.com/ubuntu-base/releases/24.04/release'
PROOT_BASE_URL='https://raw.githubusercontent.com/dxomg/vpsfreepterovm/main'

# -------------------- FUNCTIONS ----------------------------

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

fail() {
    error "$1"
    exit 1
}

banner() {
    printf '\n'
    printf "${GREEN}  ██╗███╗   ██╗███████╗ █████╗ ███╗   ██╗███████╗${RESET}\n"
    printf "${GREEN}  ██║████╗  ██║██╔════╝██╔══██╗████╗  ██║██╔════╝${RESET}\n"
    printf "${GREEN}  ██║██╔██╗ ██║███████╗███████║██╔██╗ ██║█████╗  ${RESET}\n"
    printf "${YELLOW}  ██║██║╚██╗██║╚════██║██╔══██║██║╚██╗██║██╔══╝  ${RESET}\n"
    printf "${YELLOW}  ██║██║ ╚████║███████║██║  ██║██║ ╚████║███████╗${RESET}\n"
    printf "${YELLOW}  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝${RESET}\n"
    printf '\n'
    printf "${YELLOW}          INSANE HOST DEVELOPMENT${RESET}\n"
    printf "${GREEN}             ULTIMATE EDITION${RESET}\n"
    printf "${WHITE}          Ubuntu ${UBUNTU_VERSION} LTS${RESET}\n"
    printf '\n'
    printf "${GREEN}====================================================${RESET}\n"
    printf '\n'
}

cleanup() {
    if [ -n "${TMP_DIR:-}" ] && [ -d "$TMP_DIR" ]; then
        rm -rf -- "$TMP_DIR"
    fi
}

banner

# -------------------- ARCHITECTURE ------------------------

info 'Detecting CPU architecture...'

ARCH="$(uname -m)"

case "$ARCH" in
    x86_64)
        UBUNTU_ARCH='amd64'
        PROOT_ARCH='x86_64'
        ;;
    aarch64|arm64)
        UBUNTU_ARCH='arm64'
        PROOT_ARCH='aarch64'
        ;;
    *)
        fail "Unsupported architecture: $ARCH"
        ;;
esac

success "Architecture: $ARCH"

# -------------------- DEPENDENCIES ------------------------

for CMD in wget tar sha256sum awk mktemp; do
    command -v "$CMD" >/dev/null 2>&1 ||
        fail "Required command '$CMD' is missing."
done

# -------------------- EXISTING INSTALLATION ---------------

if [ -f "$ROOTFS_DIR/.installed" ] &&
   [ -x "$ROOTFS_DIR/usr/local/bin/proot" ] &&
   [ -x "$ROOTFS_DIR/bin/bash" ]; then

    success 'Ubuntu 24.04 is already installed.'

else

    # Preserve incomplete installations instead of deleting data.

    if [ -e "$ROOTFS_DIR" ]; then
        warning "Incomplete installation found: $ROOTFS_DIR"
        fail 'Back up or rename this directory before retrying.'
    fi

    TMP_DIR="$(mktemp -d "$HOME/.insane-host-install.XXXXXX")" ||
        fail 'Could not create temporary directory.'

    trap cleanup EXIT
    trap 'exit 129' HUP
    trap 'exit 130' INT
    trap 'exit 143' TERM

    ARCHIVE_NAME="ubuntu-base-${UBUNTU_VERSION}-base-${UBUNTU_ARCH}.tar.gz"

    # ---------------- DOWNLOAD UBUNTU ---------------------

    info "Downloading Ubuntu ${UBUNTU_VERSION}..."

    wget -O "$TMP_DIR/$ARCHIVE_NAME" \
        "$UBUNTU_BASE_URL/$ARCHIVE_NAME" ||
        fail 'Ubuntu download failed.'

    # ---------------- DOWNLOAD CHECKSUMS ------------------

    info 'Downloading official Ubuntu checksums...'

    wget -O "$TMP_DIR/SHA256SUMS" \
        "$UBUNTU_BASE_URL/SHA256SUMS" ||
        fail 'Could not download Ubuntu checksums.'

    # Ubuntu SHA256SUMS uses: HASH *filename
    # Handle both starred and unstarred filenames.

    awk -v name="$ARCHIVE_NAME" \
        '$2 == name || $2 == "*" name {
            print
            found=1
        }
        END {
            if (!found) exit 1
        }' "$TMP_DIR/SHA256SUMS" > "$TMP_DIR/checksum.txt" ||
        fail 'Ubuntu archive checksum entry not found.'

    # ---------------- VERIFY ARCHIVE ----------------------

    info 'Verifying Ubuntu archive integrity...'

    (
        cd "$TMP_DIR"
        sha256sum -c checksum.txt
    ) || fail 'Checksum verification failed.'

    success 'Ubuntu archive checksum verified.'

    # ---------------- EXTRACT ROOTFS ----------------------

    mkdir "$TMP_DIR/rootfs"

    info 'Extracting Ubuntu root filesystem...'

    tar -xzf "$TMP_DIR/$ARCHIVE_NAME" \
        -C "$TMP_DIR/rootfs" ||
        fail 'Root filesystem extraction failed.'

    [ -x "$TMP_DIR/rootfs/bin/bash" ] ||
        fail 'Ubuntu root filesystem is missing /bin/bash.'

    [ -d "$TMP_DIR/rootfs/etc" ] ||
        fail 'Ubuntu root filesystem is missing /etc.'

    # ---------------- DOWNLOAD PROOT -----------------------

    mkdir -p "$TMP_DIR/rootfs/usr/local/bin"

    info "Downloading PRoot for ${PROOT_ARCH}..."

    wget -O "$TMP_DIR/rootfs/usr/local/bin/proot" \
        "$PROOT_BASE_URL/proot-$PROOT_ARCH" ||
        fail 'PRoot download failed.'

    [ -s "$TMP_DIR/rootfs/usr/local/bin/proot" ] ||
        fail 'Downloaded PRoot file is empty.'

    chmod 755 "$TMP_DIR/rootfs/usr/local/bin/proot"

    # Verify that the downloaded file can run as PRoot.

    "$TMP_DIR/rootfs/usr/local/bin/proot" --version \
        >/dev/null 2>&1 ||
        fail 'PRoot binary failed its version check.'

    success 'PRoot version check passed.'

    # ---------------- DNS CONFIGURATION --------------------

    info 'Configuring DNS...'

    rm -f "$TMP_DIR/rootfs/etc/resolv.conf"

    printf 'nameserver 1.1.1.1\nnameserver 1.0.0.1\n' \
        > "$TMP_DIR/rootfs/etc/resolv.conf"

    # ---------------- INSTALLATION MARKER ------------------

    printf 'Ubuntu %s\nArchitecture: %s\n' \
        "$UBUNTU_VERSION" "$UBUNTU_ARCH" \
        > "$TMP_DIR/rootfs/.installed"

    # Install only after download, verification and extraction.

    mv "$TMP_DIR/rootfs" "$ROOTFS_DIR" ||
        fail 'Could not install Ubuntu root filesystem.'

    success 'Ubuntu 24.04 installation completed.'

    cleanup
    trap - EXIT HUP INT TERM

fi

# -------------------- START UBUNTU -------------------------

printf '\n'
printf "${GREEN}====================================================${RESET}\n"
printf "${YELLOW}          STARTING INSANE HOST UBUNTU${RESET}\n"
printf "${GREEN}====================================================${RESET}\n"
printf '\n'

info "Ubuntu Version: ${UBUNTU_VERSION}"
info "Architecture: ${UBUNTU_ARCH}"

printf '\n'
printf "${GREEN}       INSANE HOST DEVELOPMENT${RESET}\n"
printf "${YELLOW}       Type 'exit' to leave Ubuntu.${RESET}\n"
printf '\n'

# -------------------- PROOT LAUNCH -------------------------

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
```
