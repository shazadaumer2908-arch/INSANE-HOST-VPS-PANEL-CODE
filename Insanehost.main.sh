
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
██║████╗  ██║██╔════╝██╔══██╗████╗  ██║██╔════╝
██║██╔██╗ ██║███████╗███████║██╔██╗ ██║█████╗
██║██║╚██╗██║╚════██║██╔══██╗██║╚██╗██║╔══╝
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
    sleep 1
}

pause_menu() {
    echo
    read -rp "Press Enter to continue..." _
}

vps_menu() {
    clear
    printf "${RED}${BOLD}========== VPS MANAGEMENT ==========${RESET}\n\n"
    echo "1. System information"
    echo "2. Memory usage"
    echo "3. Disk usage"
    echo "4. Listening ports"
    echo "0. Back"
    echo
    read -rp "Enter choice: " choice

    case "$choice" in
        1) hostnamectl 2>/dev/null || uname -a ;;
        2) free -h ;;
        3) df -h ;;
        4) ss -tulpen 2>/dev/null || echo "ss unavailable" ;;
        0) return ;;
        *) echo "Invalid option." ;;
    esac
    pause_menu
}

tools_menu() {
    clear
    printf "${RED}${BOLD}=============== TOOLS ===============${RESET}\n\n"
    echo "1. Cloudflared version"
    echo "2. Cloudflared service status"
    echo "3. Cloudflared logs"
    echo "0. Back"
    echo
    read -rp "Enter choice: " choice

    case "$choice" in
        1) cloudflared --version 2>/dev/null || echo "Cloudflared is not installed." ;;
        2) systemctl status cloudflared --no-pager ;;
        3) journalctl -u cloudflared -n 60 --no-pager ;;
        0) return ;;
        *) echo "Invalid option." ;;
    esac
    pause_menu
}

main_menu() {
    show_banner
    printf "${ORANGE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    printf "${WHITE}${BOLD}                  MAIN MENU${RESET}\n"
    printf "${ORANGE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    printf "${CYAN}  [1]${WHITE} VPS Management${RESET}\n"
    printf "${CYAN}  [2]${WHITE} Pterodactyl Panel${RESET}\n"
    printf "${CYAN}  [3]${WHITE} Tools${RESET}\n"
    printf "${CYAN}  [0]${WHITE} Exit${RESET}\n"
    printf "${ORANGE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

    read -rp "INSANE-HOST Enter your choice: " choice

    case "$choice" in
        1) vps_menu ;;
        2) bash <(curl -s https://pterodactyl-installer.se) ;;
        3) tools_menu ;;
        0) goodbye_animation; exit 0 ;;
        *) echo "Invalid option."; sleep 1 ;;
    esac
}

loading_animation
main_menu
