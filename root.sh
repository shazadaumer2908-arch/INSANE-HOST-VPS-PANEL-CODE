```bash
#!/bin/sh
set -eu

# ==========================================================
#                    INSANE HOST
#               UBUNTU PROOT INSTALLER
# ==========================================================

ROOTFS_DIR="$HOME/ubuntu-rootfs"
ARCH="$(uname -m)"

# -------------------- COLORS ------------------------------

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'
CLEAR='\033[2J\033[H'

# -------------------- MAIN LOGO ---------------------------

show_logo() {
    printf '\033[2J\033[H'

    printf "\n"
    printf "${YELLOW}       *       .       *       .       *${RESET}\n"
    printf "${GREEN}          FIRE UP YOUR TERMINAL${RESET}\n"
    printf "${YELLOW}       *       .       *       .       *${RESET}\n"
    printf "\n"

    printf "${GREEN}  ██╗███╗   ██╗███████╗ █████╗ ███╗   ██╗███████╗${RESET}\n"
    printf "${GREEN}  ██║████╗  ██║██╔════╝██╔══██╗████╗  ██║██╔════╝${RESET}\n"
    printf "${YELLOW}  ██║██╔██╗ ██║███████╗███████║██╔██╗ ██║█████╗  ${RESET}\n"
    printf "${YELLOW}  ██║██║╚██╗██║╚════██║██╔══██║██║╚██╗██║██╔══╝  ${RESET}\n"
    printf "${GREEN}  ██║██║ ╚████║███████║██║  ██║██║ ╚████║███████╗${RESET}\n"
    printf "${GREEN}  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝${RESET}\n"
    printf "\n"

    printf "${YELLOW}  ██╗  ██╗ ██████╗ ███████╗████████╗${RESET}\n"
    printf "${YELLOW}  ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝${RESET}\n"
    printf "${GREEN}  ███████║██║   ██║███████╗   ██║   ${RESET}\n"
    printf "${GREEN}  ██╔══██║██║   ██║╚════██║   ██║   ${RESET}\n"
    printf "${YELLOW}  ██║  ██║╚██████╔╝███████║   ██║   ${RESET}\n"
    printf "${YELLOW}  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ${RESET}\n"

    printf "\n"
    printf "${GREEN}          DEVELOPMENT TEAM${RESET}\n"
    printf "${YELLOW}       UBUNTU 22.04 PROOT SYSTEM${RESET}\n"
    printf "\n"
    printf "${CYAN}  =============================================${RESET}\n"
    printf "${GREEN}          POWERED BY INSANE HOST${RESET}\n"
    printf "${CYAN}  =============================================${RESET}\n"
    printf "\n"
}

# -------------------- FIRE EFFECT -------------------------

fire_effect() {
    if [ -t 1 ]; then
        i=1
        while [ "$i" -le 3 ]; do
            printf "\r${YELLOW}          *  FIRE IGNITION  *${RESET}"
            sleep 0.15
            printf "\r${GREEN}          *  FIRE IGNITION  *${RESET}"
            sleep 0.15
            i=$((i + 1))
        done
        printf "\n\n"
    fi
}

# -------------------- CONFIRMATION BOX --------------------

confirm_install() {
    printf "${YELLOW}"
    printf "  +------------------------------------------+\n"
    printf "  |           INSTALLATION MENU              |\n"
    printf "  +------------------------------------------+\n"
    printf "  |                                          |\n"
    printf "  |  Install or start Ubuntu 22.04 PRoot?    |\n"
    printf "  |                                          |\n"
    printf "  |  YES = Continue                          |\n"
    printf "  |  NO  = Cancel                            |\n"
    printf "  |                                          |\n"
    printf "  +------------------------------------------+\n"
    printf "${RESET}\n"

    while :; do
        printf "${GREEN}  Continue? [Yes/No]: ${RESET}"

        if ! IFS= read -r answer; then
            printf "\n${RED}Input unavailable. Cancelled.${RESET}\n"
            exit 0
        fi

        case "$answer" in
            [Yy]|[Yy][Ee][Ss])
                printf "\n${GREEN}Installation confirmed!${RESET}\n\n"
                break
                ;;
            [Nn]|[Nn][Oo])
                printf "\n${YELLOW}Installation cancelled by user.${RESET}\n"
                exit 0
                ;;
            *)
                printf "${RED}Please enter Yes or No.${RESET}\n"
                ;;
        esac
    done
}

# -------------------- STARTUP -----------------------------

show_logo
fire_effect
confirm_install

# -------------------- ARCHITECTURE -------------------------

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
        printf "${RED}Unsupported architecture: $ARCH${RESET}\n"
        exit 1
        ;;
esac

# -------------------- DEPENDENCIES -------------------------

command -v wget >/dev/null 2>&1 || {
    printf "${RED}wget is required. Install it in your host environment first.${RESET}\n"
    exit 1
}

command -v tar >/dev/null 2>&1 || {
    printf "${RED}tar is required.${RESET}\n"
    exit 1
}

# -------------------- ROOTFS INSTALLATION ------------------

if [ ! -f "$ROOTFS_DIR/.installed" ]; then

    printf "${YELLOW}Downloading Ubuntu 22.04 root filesystem...${RESET}\n"

    case "$UBUNTU_ARCH" in
        amd64)
            UBUNTU_URL="https://cdimages.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-amd64.tar.gz"
            ;;
        arm64)
            UBUNTU_URL="https://cdimages.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-arm64.tar.gz"
            ;;
    esac

    mkdir -p "$ROOTFS_DIR"

    if ! wget -O /tmp/ubuntu-base.tar.gz "$UBUNTU_URL"; then
        printf "${RED}Ubuntu download failed.${RESET}\n"
        rm -f /tmp/ubuntu-base.tar.gz
        exit 1
    fi

    if ! tar -tzf /tmp/ubuntu-base.tar.gz >/dev/null 2>&1; then
        printf "${RED}Downloaded Ubuntu archive is invalid.${RESET}\n"
        rm -f /tmp/ubuntu-base.tar.gz
        exit 1
    fi

    if ! tar -xzf /tmp/ubuntu-base.tar.gz -C "$ROOTFS_DIR"; then
        printf "${RED}Ubuntu extraction failed.${RESET}\n"
        rm -f /tmp/ubuntu-base.tar.gz
        exit 1
    fi

    rm -f /tmp/ubuntu-base.tar.gz

    mkdir -p "$ROOTFS_DIR/usr/local/bin"

    # -------------------- DOWNLOAD PROOT -------------------

    printf "${YELLOW}Downloading PRoot...${RESET}\n"

    PROOT_URL="https://raw.githubusercontent.com/dxomg/vpsfreepterovm/main/proot-${PROOT_ARCH}"

    if ! wget -O "$ROOTFS_DIR/usr/local/bin/proot" "$PROOT_URL"; then
        printf "${RED}Could not download PRoot. Check the source and architecture.${RESET}\n"
        exit 1
    fi

    if [ ! -s "$ROOTFS_DIR/usr/local/bin/proot" ]; then
        printf "${RED}Downloaded PRoot file is empty.${RESET}\n"
        exit 1
    fi

    chmod 755 "$ROOTFS_DIR/usr/local/bin/proot"

    # -------------------- DNS CONFIGURATION ----------------

    printf 'nameserver 1.1.1.1\nnameserver 1.0.0.1\n' \
        > "$ROOTFS_DIR/etc/resolv.conf"

    # Mark installation complete only after setup succeeds.
    touch "$ROOTFS_DIR/.installed"

    printf "\n${GREEN}Ubuntu 22.04 installation completed!${RESET}\n"

else
    printf "${GREEN}Ubuntu root filesystem already exists.${RESET}\n"
fi

# -------------------- VALIDATION ---------------------------

if [ ! -x "$ROOTFS_DIR/usr/local/bin/proot" ]; then
    printf "${RED}PRoot executable is missing. Reinstall may be required.${RESET}\n"
    exit 1
fi

if [ ! -x "$ROOTFS_DIR/bin/bash" ]; then
    printf "${RED}Ubuntu Bash was not found. Root filesystem may be incomplete.${RESET}\n"
    exit 1
fi

# -------------------- START UBUNTU -------------------------

printf "\n${GREEN}Starting Ubuntu 22.04...${RESET}\n"
printf "${YELLOW}Type 'exit' to leave Ubuntu.${RESET}\n\n"

exec "$ROOTFS_DIR/usr/local/bin/proot" \
    --rootfs="$ROOTFS_DIR" \
    -0 \
    -w /root \
    -b /dev \
    -b /proc \
    -b /sys \
    -b /etc/resolv.conf \
    --kill-on-exit \
    /usr/bin/env -i \
    HOME=/root \
    USER=root \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    TERM="${TERM:-xterm}" \
    /bin/bash --login
```
