
#!/usr/bin/env bash

RED='\033[0;31m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
RESET='\033[0m'

show_banner() {
    clear
    printf "${RED}${BOLD}"
    cat <<'EOF'
██╗███╗   ██╗███████╗ █████╗ ███╗   ██╗███████╗
██║████╗  ██║╔════██║██╔══██╗████╗  ██║╔════██║
██║██╔██╗ ██║███████║███████║██╔██╗ ██║█████╗
██║██║╚██╗██║╔════██║██╔══██║██║╚██╗██║╔══╝
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
    printf "${GRAY}    Credits: INSANE HOST Development Team${RESET}\n\n"
}

loading_animation() {
    for frame in \
        "[■□□□□□□□□□] 10% - INITIALIZING" \
        "[■■■□□□□□□□] 30% - LOADING VPS TOOLS" \
        "[■■■■■■□□□□] 60% - PREPARING MENU" \
        "[■■■■■■■■■■] 100% - READY"; do
        printf "\r${ORANGE}${BOLD}%-55s${RESET}" "$frame"
        sleep 0.2
    done
    printf "\n\n"
}

goodbye_animation() {
    clear
    for frame in \
        "[■□□□□□□□□□] 10%" \
        "[■■■□□□□□□□] 30%" \
        "[■■■■■■□□□□] 60%" \
        "[■■■■■■■■■■] 100%"; do
        printf "\r${ORANGE}${BOLD}%-35s${RESET}" "$frame"
        sleep 0.2
    done

    printf "\n\n${RED}${BOLD}"
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║       THANKS FOR USING INSANE HOST       ║"
    echo "  ╚══════════════════════════════════════════╝"
    printf "${CYAN}    Developed by INSANE HOST Development Team${RESET}\n"
    sleep 1.5
}

pause_menu() {
    echo
    read -rp "Press Enter to return to main menu..." _
}

run_pterodactyl() {
    clear
    printf "${RED}${BOLD}===== INSANE HOST - PTERODACTYL =====${RESET}\n\n"

    command -v curl >/dev/null 2>&1 || {
        echo "curl is required."
        pause_menu
        return
    }

    local installer="/tmp/insane-host-ptero-installer.sh"

    echo "Downloading Nobita installer..."
    if ! curl -fsSL --connect-timeout 15 \
        https://ptero.nobitahost.in -o "$installer"; then
        echo "Installer download failed."
        rm -f "$installer"
        pause_menu
        return
    fi

    echo
    echo "Automatic selection will attempt option 2, then option 1."
    echo "The third-party installer will then remain interactive."
    read -rp "Run installer? [y/N]: " confirm

    case "$confirm" in
        y|Y|yes|YES) ;;
        *)
            rm -f "$installer"
            echo "Cancelled."
            pause_menu
            return
            ;;
    esac

    if ! command -v expect >/dev/null 2>&1; then
        if command -v apt-get >/dev/null 2>&1; then
            echo "Installing Expect..."
            apt-get update && apt-get install -y expect || {
                echo "Could not install Expect."
                rm -f "$installer"
                pause_menu
                return
            }
        else
            echo "Install Expect manually to use automatic selection."
            rm -f "$installer"
            pause_menu
            return
        fi
    fi

    INSANE_INSTALLER="$installer" expect <<'EXPECT_SCRIPT'
set timeout -1
spawn bash $env(INSANE_INSTALLER)

# Try to select the first menu option.
expect {
    -re {(?i)(choice|option|select|selection|enter.*number)} {
        send -- "2\r"
    }
    eof { exit }
}

# Try to select the next menu option.
expect {
    -re {(?i)(choice|option|select|selection|enter.*number)} {
        send -- "1\r"
    }
    eof { exit }
}

# Give the terminal back to the user.
interact
EXPECT_SCRIPT

    rm -f "$installer"
    echo
    echo "Installer closed. Returning to INSANE HOST..."
    sleep 1
}

vps_menu() {
    while true; do
        clear
        printf "${RED}${BOLD}========== VPS MANAGEMENT ==========${RESET}\n"
        echo "1. System information"
        echo "2. Memory usage"
        echo "3. Disk usage"
        echo "4. Listening ports"
        echo "0. Back"
        echo
        read -rp "Enter choice: " choice

        case "$choice" in
            1) hostnamectl 2>/dev/null || uname -a; pause_menu ;;
            2) free -h; pause_menu ;;
            3) df -h; pause_menu ;;
            4) ss -tulpen 2>/dev/null || echo "ss unavailable"; pause_menu ;;
            0) return ;;
            *) echo "Invalid option"; sleep 1 ;;
        esac
    done
}

wings_menu() {
    clear
    printf "${RED}${BOLD}============= WINGS =============${RESET}\n\n"
    echo "Wings is separate from the Panel option."
    echo "Wings functionality will be added after your instructions."
    pause_menu
}

tools_menu() {
    while true; do
        clear
        printf "${RED}${BOLD}=============== TOOLS ===============${RESET}\n"
        echo "1. Cloudflared version"
        echo "2. Cloudflared service status"
        echo "3. Cloudflared logs"
        echo "0. Back"
        echo
        read -rp "Enter choice: " choice

        case "$choice" in
            1)
                cloudflared --version 2>/dev/null ||
                    echo "Cloudflared is not installed."
                pause_menu
                ;;
            2)
                systemctl status cloudflared --no-pager
                pause_menu
                ;;
            3)
                journalctl -u cloudflared -n 60 --no-pager
                pause_menu
                ;;
            0) return ;;
            *) echo "Invalid option"; sleep 1 ;;
        esac
    done
}

main_menu() {
    while true; do
        show_banner
        printf "${ORANGE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
        printf "${WHITE}${BOLD}                  MAIN MENU${RESET}\n"
        printf "${ORANGE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
        printf "${CYAN}  [1]${WHITE} VPS Management${RESET}\n"
        printf "${CYAN}  [2]${WHITE} Pterodactyl Panel${RESET}\n"
        printf "${CYAN}  [3]${WHITE} Wings${RESET}\n"
        printf "${CYAN}  [4]${WHITE} Tools${RESET}\n"
        printf "${CYAN}  [0]${WHITE} Exit${RESET}\n"
        printf "${ORANGE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

        read -rp "$(printf "${RED}${BOLD}INSANE-HOST${RESET} ${WHITE}Enter your choice: ${RESET}")" choice

        case "$choice" in
            1) vps_menu ;;
            2) run_pterodactyl ;;
            3) wings_menu ;;
            4) tools_menu ;;
            0) goodbye_animation; exit 0 ;;
            *) printf "${RED}Invalid option. Try again.${RESET}\n"; sleep 1 ;;
        esac
    done
}

trap 'printf "\nReturning to INSANE HOST menu...\n"; sleep 1' INT

loading_animation
main_menu
