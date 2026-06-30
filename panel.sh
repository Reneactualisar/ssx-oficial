#!/bin/bash

# --- CONFIGURACIÓN DE COLORES ---
V='\e[1;32m'; R='\e[1;31m'; A='\e[1;34m'; C='\e[1;36m'; Y='\e[1;33m'; B='\e[1;37m'; RE='\e[0m'

# --- RUTAS ---
PATH_LAB="/root/umbrel/umbrel-data/home/Downloads/laboratorio_c"
PATH_C="$PATH_LAB/CODIGOS"
VNC_FILE="/usr/share/novnc/vnc.html"

# --- MOTOR DE INSTALACIÓN AUTOMÁTICA ---
# Uso: install_if_missing "nombre_comando" "nombre_paquete_apt"
install_if_missing() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${Y}⚙️ Instalando herramienta necesaria para esta opción...${RE}"
        sudo apt update && sudo apt install -y ${2:-$1}
        echo -e "${V}✔ Instalación completada.${RE}"
    fi
}

# --- MOTOR DE ESTADO ---
st() {
    if pgrep "$1" > /dev/null || screen -ls | grep -q "$1"; then echo -ne "${V}● ON${RE}"; else echo -ne "${R}○ OFF${RE}"; fi
}

# --- ENCABEZADO TIPO ADM ---
header() {
    clear
    IP=$(hostname -I | awk '{print $1}')
    HORA=$(date +"%I:%M:%S %p")
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')"%"
    RAM=$(free -h | awk 'NR==2 {print $3}')
    echo -e "${C}╔══════════════════════════════════════════════════════════════╗${RE}"
    echo -e "║  ${B}SSX-OFICIAL v45.0 - MASTER-CONTROL - DXVID DEVELOPER${RE}        ${C}║${RE}"
    echo -e "╠══════════════════════┳═══════════════════════┳═══════════════╣${RE}"
    echo -e "║ ${B}SISTEMA${RE}             ${C}║${RE} ${B}MEMORIA RAM${RE}           ${C}║${RE} ${B}PROCESADOR${RE}    ${C}║${RE}"
    printf "${C}║${RE} IP: %-16s ${C}║${RE} En uso: %-14s ${C}║${RE} CPU: %-9s ${C}║${RE}\n" "$IP" "$RAM" "$CPU"
    printf "${C}║${RE} Hora: %-14s ${C}║${RE} T. C: $(st dosbox)        ${C}║${RE} BOT: $(st bot-cine)    ${C}║${RE}\n" "$HORA"
    echo -e "${C}╚══════════════════════╩═══════════════════════╩═══════════════╝${RE}"
}

# --- DEPARTAMENTOS ---

# S1: PROGRAMACION
menu_s1() {
    while true; do
        header; echo -e " ${Y}📂 [S1] PROGRAMACIÓN Y UNIVERSIDAD${RE}"
        echo -e "  [1] TURBO C ON/OFF | [2] CREAR .C (PEGAR) | [3] PLANTILLA EXAMEN"
        echo -e "  [4] ZIP SELECTIVO  | [5] FORMATEAR C     | [0] VOLVER"
        read -p " >> " op
        case $op in
            1) if screen -ls | grep -q "laboratorio"; then sudo pkill -9 dosbox; else screen -dmS laboratorio bash ~/start_turboc.sh; fi ;;
            2) read -p "Nombre: " n; [[ $n != *.c ]] && n="$n.c"; echo "Pega codigo, escribe FIN:"; lines=(); while read -r l; do [[ "$l" == "FIN" ]] && break; lines+=("$l"); done; printf "%s\n" "${lines[@]}" > "$PATH_C/$n"; chmod 777 "$PATH_C/$n" ;;
            4) install_if_missing "zip"; cd $PATH_C; files=(*.c); for i in "${!files[@]}"; do echo "[$i] ${files[$i]}"; done; read -p "Nums: " s; read -p "Nom: " nz; f_z=""; for i in $s; do f_z+="${files[$i]} "; done; zip "$PATH_LAB/$nz.zip" $f_z ;;
            5) install_if_missing "indent"; indent $PATH_C/*.c ;;
            0) break ;;
        esac
    done
}

# S3: AUDITORIA Y SEGURIDAD
menu_s3() {
    while true; do
        header; echo -e " ${Y}🛡️ [S3] CIBERSEGURIDAD Y AUDITORÍA DE RED${RE}"
        echo -e "  [1] RASTREAR IP    | [2] NMAP SCAN      | [3] NIKTO WEB"
        echo -e "  [4] SQL MAP SCAN   | [5] BAN/UNBAN IP   | [0] VOLVER"
        read -p " >> " op
        case $op in
            1) read -p "IP: " t; curl -s http://ip-api.com/json/$t; read -p "Enter..." x ;;
            2) install_if_missing "nmap"; read -p "Target: " t; nmap $t; read -p "Enter..." x ;;
            3) install_if_missing "nikto"; read -p "URL: " t; nikto -h $t; read -p "Enter..." x ;;
            4) install_if_missing "sqlmap"; read -p "URL: " t; sqlmap -u $t --batch; read -p "Enter..." x ;;
            5) read -p "IP: " bip; sudo ufw deny from $bip; sudo ufw reload ;;
            0) break ;;
        esac
    done
}

# S4: CONEXION INTERNET
menu_s4() {
    while true; do
        header; echo -e " ${Y}🌐 [S4] PROTOCOLOS DE INTERNET (ADM)${RE}"
        echo -e "  [1] DROPBEAR ALL   | [2] BADVPN (UDP)   | [3] SOCKS PYTHON"
        echo -e "  [4] STUNNEL SSL    | [5] GESTION USERS  | [0] VOLVER"
        read -p " >> " op
        case $op in
            1) install_if_missing "dropbear" ;;
            2) read -p "Puerto BadVPN: " p; screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:$p ;;
            5) while true; do header; echo "1. Nuevo Usuario | 2. Remover | 0. Volver"; read u; [[ $u == 0 ]] && break; done ;;
            0) break ;;
        esac
    done
}

# S8: ACCESO OTP
menu_s8() {
    header; echo -e " ${Y}🔐 [S8] ACCESO SEGURO (OTP UN SOLO USO)${RE}"
    P_T=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 12)
    echo -e " USUARIO: root  |  PASS: $P_T"
    install_if_missing "ttyd"; pkill -9 ttyd; screen -dmS consola_temp ttyd -p 8091 -c root:$P_T bash
    echo -e " LINK: https://web-proyect.duckdns.org/acceso/"
    read -p ">>> ENTER PARA CERRAR LA PUERTA <<<" x; pkill -9 ttyd
}

# --- MENU PRINCIPAL ---
while true; do
    header
    echo -e "  ${V}[01] • 📂 PROGRAMACION       [09] • 🗃️  GESTION DE DATOS${RE}"
    echo -e "  ${V}[02] • 🎬 CINE Y STREAMING   [10] • 🛡️  SEGURIDAD VPS${RE}"
    echo -e "  ${V}[03] • 🛡️  HACKING ETICO      [11] • 📈 MONITORES SALUD${RE}"
    echo -e "  ${V}[04] • 🌐 CONEXION INTERNET  [12] • 🔧 UTILIDADES RED${RE}"
    echo -e "  ${V}[05] • 👥 GESTION INVITADOS  [13] • 🤖 IA PRIVADA${RE}"
    echo -e "  ${V}[06] • ⚙️  MANTENIMIENTO     [14] • 🆘 RESCATE BOT${RE}"
    echo -e "  ${V}[07] • 🌍 CONFIGURAR PAIS    [15] • 🐙 GITHUB SYNC${RE}"
    echo -e "  ${V}[08] • 🔐 ACCESO SEGURO OTP  [00] • SALIR DEL PANEL${RE}"
    echo -e " ----------------------------------------------------"
    echo -ne "\n ${Y}${B}DXVID DEVELOPER - ELIJE UNA OPCION : ${RE}"
    read main_op

    case $main_op in
        1|01) menu_s1 ;;
        2|02) while true; do header; echo " [1] BOT ON | [2] BOT OFF | [3] YT-DOWNLOAD | [0] VOLVER"; read c; [[ $c == 0 ]] && break; done ;;
        3|03) menu_s3 ;;
        4|04) menu_s4 ;;
        6|06) sudo sync; sudo systemctl restart nginx; echo "Optimizado" ;;
        7|07) read -p "Ej: America/Managua: " z; sudo timedatectl set-timezone $z ;;
        8|08) menu_acceso ;;
        11) install_if_missing "htop"; htop ;;
        13) curl -fsSL https://ollama.com/install.sh | sh; ollama run llama3 ;;
        15) install_if_missing "git"; read -p "Mensaje commit: " m; git add .; git commit -m "$m"; git push ;;
        0|00) exit ;;
    esac
done
