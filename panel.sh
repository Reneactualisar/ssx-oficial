#!/bin/bash

# --- CONFIGURACIÓN DE COLORES (BOLD) ---
V='\e[1;32m'; R='\e[1;31m'; A='\e[1;34m'; C='\e[1;36m'; Y='\e[1;33m'; B='\e[1;37m'; RE='\e[0m'

# --- RUTAS DE TRABAJO ---
PATH_LAB="/root/umbrel/umbrel-data/home/Downloads/laboratorio_c"
PATH_C="$PATH_LAB/CODIGOS"
VNC_FILE="/usr/share/novnc/vnc.html"
SHARE_DIR="/var/www/html/share"
NGINX_CONF="/etc/nginx/sites-available/web-definitiva"

# --- MOTOR DE INSTALACIÓN AUTOMÁTICA ---
# Esta función instala CUALQUIER comando que falte al instante
instalar() {
    for pkg in "$@"; do
        if ! command -v "$pkg" &> /dev/null; then
            echo -e "${Y}⚙️ VPS detectó falta de [$pkg]. Instalando automáticamente...${RE}"
            sudo apt update -y && sudo apt install -y "$pkg"
            echo -e "${V}✔ $pkg listo.${RE}"
        fi
    done
}

# --- MOTOR DE ESTADO ---
st() {
    if pgrep "$1" > /dev/null || screen -ls | grep -q "$1"; then echo -ne "${V}ON${RE}"; else echo -ne "${R}OFF${RE}"; fi
}

# --- ENCABEZADO PROFESIONAL ---
header() {
    clear
    IP_V=$(hostname -I | awk '{print $1}')
    HORA=$(date +"%I:%M:%S %p")
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')"%"
    RAM_T=$(free -h | awk 'NR==2 {print $2}')
    RAM_U=$(free -h | awk 'NR==2 {print $3}')
    echo -e "${C}╔══════════════════════════════════════════════════════════════╗${RE}"
    echo -e "║  ${B}SSX-OFICIAL v50.0 - MASTER-CONTROL - DXVID DEVELOPER${RE}        ${C}║${RE}"
    echo -e "║  ${B}CENTRO DE CONTROL EN DESARROLLO - VPS ORLANDO${RE}               ${C}║${RE}"
    echo -e "╠══════════════════════┳═══════════════════════┳═══════════════╣${RE}"
    echo -e "║ ${B}SISTEMA${RE}             ${C}║${RE} ${B}MEMORIA RAM${RE}           ${C}║${RE} ${B}PROCESADOR${RE}    ${C}║${RE}"
    printf "${C}║${RE} IP: %-16s ${C}║${RE} Total: %-10s  ${C}║${RE} Cores: 4       ${C}║${RE}\n" "$IP_V" "$RAM_T"
    printf "${C}║${RE} Hora: %-14s ${C}║${RE} En uso: %-9s   ${C}║${RE} Uso: %-10s ${C}║${RE}\n" "$HORA" "$RAM_U" "$CPU"
    echo -e "${A}╠══════════════════════╩═══════════════════════╩═══════════════╣${RE}"
    echo -e "║ ${B}TURBO C:${RE} $(st dosbox)  | ${B}BOT TG:${RE} $(st bot-cine) | ${B}IA:${RE} $(st ollama) | ${B}WEB:${RE} $(st nginx) ║"
    echo -e "${C}╚══════════════════════════════════════════════════════════════╝${RE}"
}

# --- DEPARTAMENTOS (SUBMENÚS) ---

menu_prog() {
    while true; do
        header; echo -e " ${Y}📂 [01] PROGRAMACION NIVEL DIOS (C/UNI)${RE}"
        echo -e " ----------------------------------------------------"
        echo -e "  ${V}[01] •${RE} TURBO C ON/OFF    | ${V}[04] •${RE} PLANTILLA EXAMEN"
        echo -e "  ${V}[02] •${RE} CREAR .C (PEGAR)  | ${V}[05] •${RE} ZIP SELECTIVO"
        echo -e "  ${V}[03] •${RE} FORMATEAR (INDENT)| ${V}[06] •${RE} MODO NINJA WEB"
        echo -e " ----------------------------------------------------"
        echo -e "  ${R}[00] • VOLVER${RE}"
        read -p " Selección: " op1
        case $op1 in
            1) if screen -ls | grep -q "laboratorio"; then sudo pkill -9 dosbox; else screen -dmS laboratorio bash ~/start_turboc.sh; fi ;;
            2) read -p "Nombre: " n; [[ $n != *.c ]] && n="$n.c"; echo "Pega algoritmo y escribe 'FIN':"; lines=(); while read -r l; do [[ "$l" == "FIN" ]] && break; lines+=("$l"); done; printf "%s\n" "${lines[@]}" > "$PATH_C/$n"; chmod 777 "$PATH_C/$n" ;;
            3) instalar indent; indent $PATH_C/*.c ;;
            4) read -p "Nombre: " n; cat <<P > "$PATH_C/$n.c"
#include <stdio.h>
#include <conio.h>
void main() { clrscr(); printf("Listo..."); getch(); }
P
               chmod 777 "$PATH_C/$n.c" ;;
            5) instalar zip; cd $PATH_C; files=(*.c); for i in "${!files[@]}"; do echo "[$i] ${files[$i]}"; done; read -p "Nums: " s; read -p "Nom ZIP: " nz; f_z=""; for i in $s; do f_z+="${files[$i]} "; done; zip "$PATH_LAB/$nz.zip" $f_z ;;
            0) break ;;
        esac
    done
}

menu_hacker() {
    while true; do
        header; echo -e " ${Y}🛡️ [03] CIBERSEGURIDAD Y AUDITORIA${RE}"
        echo -e " ----------------------------------------------------"
        echo -e "  ${V}[01] •${RE} RASTREAR IP (MAPA)| ${V}[03] •${RE} SCAN WEB (NIKTO)"
        echo -e "  ${V}[02] •${RE} NMAP SCAN PUERTOS | ${V}[04] •${RE} BLOQUEAR IP (BAN)"
        echo -e " ----------------------------------------------------"
        echo -e "  ${R}[00] • VOLVER${RE}"
        read -p " Selección: " op3
        case $op3 in
            1) read -p "IP: " t; curl -s http://ip-api.com/json/$t; read -p "Enter..." x ;;
            2) instalar nmap; read -p "Host: " t; nmap -F $t; read -p "Enter..." x ;;
            3) instalar nikto; read -p "Web: " t; nikto -h $t; read -p "Enter..." x ;;
            4) read -p "IP: " b; sudo ufw deny from $b; sudo ufw reload ;;
            0) break ;;
        esac
    done
}

preparar_sistema_share() {
    instalar qrencode at
    sudo systemctl enable --now atd
    mkdir -p $SHARE_DIR && chmod 777 $SHARE_DIR
    if [ -f "$NGINX_CONF" ] && ! grep -q "location /share/" "$NGINX_CONF"; then
        sudo sed -i '/location \/c\/ {/i \    location /share/ { alias /var/www/html/share/; autoindex off; add_header Content-Disposition "attachment"; }' "$NGINX_CONF"
        sudo systemctl restart nginx
    fi
}

# --- MENU PRINCIPAL ---
while true; do
    header
    echo -e "  ${V}[01] • 📂 PROGRAMACION       [09] • 🌍 CONFIGURAR PAIS${RE}"
    echo -e "  ${V}[02] • 🎬 CINE Y STREAMING   [10] • 🆘 BOT RESCATE (TG)${RE}"
    echo -e "  ${V}[03] • 🛡️  AUDITORIA HACKER   [11] • 🤖 IA PRIVADA (LLAMA)${RE}"
    echo -e "  ${V}[04] • 🌐 CONEXION INTERNET  [12] • 📦 BACKUP TOTAL (.ZIP)${RE}"
    echo -e "  ${V}[05] • 🔐 ACCESO SEGURO OTP  [13] • 📤 COMPARTIR CON QR${RE}"
    echo -e "  ${V}[06] • 🧹 OPTIMIZAR SISTEMA   [14] • 📊 MONITORES (HTOP)${RE}"
    echo -e "  ${V}[07] • 📊 MONITOR DE RED     [15] • ⚙️  SISTEMA CLONADOR${RE}"
    echo -e "  ${V}[08] • 🗃️  GESTOR DE DISCO    [00] • 🔴 SALIR DEL PANEL${RE}"
    echo -e " ----------------------------------------------------"
    echo -ne "\n ${Y}ELIJE UNA SECCIÓN : ${RE}"
    read main_op
    case $main_op in
        1) menu_prog ;;
        2) while true; do header; echo -e " [1] BOT ON | [2] BOT OFF | [3] SUBIDA MANUAL | [0] VOLVER"; read c; [[ $c == 1 ]] && cd ~/telegram-bot && screen -dmS bot-cine /usr/local/go/bin/go run ./cmd/fsb/*.go run; [[ $c == 2 ]] && screen -XS bot-cine quit; [[ $c == 0 ]] && break; done ;;
        3) menu_hacker ;;
        5) # Acceso OTP
           P_T=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 12); instalar ttyd; pkill -9 ttyd; 
           screen -dmS consola_temp ttyd -p 8091 -c root:$P_T bash;
           echo -e "${V}Pass: $P_T | Link: .../acceso/"; read -p "Enter para cerrar..." x; pkill -9 ttyd ;;
        6) sudo sync; sudo sysctl -w vm.drop_caches=3; echo "RAM Limpia" ;;
        7) instalar nload; nload ;;
        8) instalar ncdu; ncdu / ;;
        10) screen -dmS bot-term python3 /root/bot_terminal.py; echo "Rescate ON" ;;
        11) curl -fsSL https://ollama.com/install.sh | sh; ollama run llama3 ;;
        13) preparar_sistema_share; cd "$PATH_C"; files=(*); for i in "${!files[@]}"; do echo "[$i] ${files[$i]}"; done; read -p "Num: " idx; read -p "Mins: " m; R=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8); cp "${files[$idx]}" "$SHARE_DIR/$R.c"; echo "https://web-proyect.duckdns.org/share/$R.c" | qrencode -t ansiutf8; echo "rm -f $SHARE_DIR/$R.c" | at now + $m minutes; read -p "Enter..." x ;;
        15) header; echo "Instalando bases de clonacion..."; instalar docker.io git golang-go python3-pip; echo "✔ VPS Lista."; sleep 2 ;;
        0) exit ;;
    esac
done
