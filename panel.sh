#!/bin/bash

# --- CONFIGURACIÓN DE COLORES (BOLD) ---
V='\e[1;32m'; R='\e[1;31m'; A='\e[1;34m'; C='\e[1;36m'; Y='\e[1;33m'; B='\e[1;37m'; RE='\e[0m'

# --- RUTAS DE TRABAJO ---
PATH_LAB="/root/umbrel/umbrel-data/home/Downloads/laboratorio_c"
PATH_C="$PATH_LAB/CODIGOS"
VNC_FILE="/usr/share/novnc/vnc.html"

# --- MOTOR DE INSTALACIÓN AUTOMÁTICA (EL CEREBRO) ---
# Esta función instala CUALQUIER comando que falte al instante
preparar() {
    for pkg in "$@"; do
        if ! command -v "$pkg" &> /dev/null; then
            echo -e "${Y}🔧 VPS detectó falta de [$pkg]. Instalando automáticamente...${RE}"
            sudo apt update -y && sudo apt install -y "$pkg"
            echo -e "${V}✔ $pkg listo.${RE}"
        fi
    done
}

# --- INDICADOR DE ESTADO ---
st() {
    if pgrep "$1" > /dev/null || screen -ls | grep -q "$1"; then echo -ne "${V}ON${RE}"; else echo -ne "${R}OFF${RE}"; fi
}

# --- ENCABEZADO TIPO ADM (ALINEACIÓN PERFECTA) ---
header() {
    clear
    IP_V=$(hostname -I | awk '{print $1}')
    HORA=$(date +"%I:%M:%S %p")
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')"%"
    RAM_T=$(free -h | awk 'NR==2{print $2}')
    RAM_U=$(free -h | awk 'NR==2{print $3}')
    
    echo -e "${A}╔══════════════════════════════════════════════════════════════╗${RE}"
    echo -e "║  ${B}SSX-OFICIAL v50.0 - OMNIPOTENT MASTER - DXVID DEVELOPER${RE}     ${A}║${RE}"
    echo -e "╠══════════════════════┳═══════════════════════┳═══════════════╣${RE}"
    echo -e "║ ${B}SISTEMA${RE}             ${A}║${RE} ${B}MEMORIA RAM${RE}           ${A}║${RE} ${B}PROCESADOR${RE}    ${C}║${RE}"
    printf "${A}║${RE} IP: %-16s ${A}║${RE} Total: %-10s  ${A}║${RE} Cores: 4       ${A}║${RE}\n" "$IP_V" "$RAM_T"
    printf "${A}║${RE} Hora: %-14s ${A}║${RE} En uso: %-9s   ${A}║${RE} Uso: %-10s ${A}║${RE}\n" "$HORA" "$RAM_U" "$CPU"
    echo -e "${A}╠══════════════════════╩═══════════════════════╩═══════════════╣${RE}"
    echo -e "║ ${B}TURBO C:${RE} $(st dosbox)  | ${B}BOT TG:${RE} $(st bot-cine) | ${B}IA:${RE} $(st ollama) | ${B}WEB:${RE} $(st nginx) ║"
    echo -e "${A}╚══════════════════════════════════════════════════════════════╝${RE}"
}

# --- DEPARTAMENTOS (SUBMENÚS) ---

menu_prog() { # [01]
    while true; do
        header; echo -e " ${Y}📂 [01] PROGRAMACIÓN Y UNIVERSIDAD${RE}"
        echo -e " ----------------------------------------------------"
        echo -e "  ${V}[01] •${RE} TURBO C ON/OFF      | ${V}[05] •${RE} ZIP SELECTIVO"
        echo -e "  ${V}[02] •${RE} CREAR .C (PEGAR)    | ${V}[06] •${RE} MODO NINJA WEB"
        echo -e "  ${V}[03] •${RE} PLANTILLA EXAMEN    | ${V}[07] •${RE} FORMATEAR (INDENT)"
        echo -e "  ${V}[04] •${RE} LIBRERIA SNIPPETS   | ${V}[08] •${RE} BUSCAR EN CODIGOS"
        echo -e " ----------------------------------------------------"
        echo -e "  ${R}[00] • VOLVER${RE}"
        read -p " Elije: " op
        case $op in
            1) if screen -ls | grep -q "laboratorio"; then sudo pkill -9 dosbox; else screen -dmS laboratorio bash ~/start_turboc.sh; fi ;;
            2) read -p "Nombre: " n; [[ $n != *.c ]] && n="$n.c"; echo "Pega algoritmo y escribe FIN:"; lines=(); while read -r l; do [[ "$l" == "FIN" ]] && break; lines+=("$l"); done; printf "%s\n" "${lines[@]}" > "$PATH_C/$n"; chmod 777 "$PATH_C/$n" ;;
            5) preparar zip; cd $PATH_C; files=(*.c); for i in "${!files[@]}"; do echo "[$i] ${files[$i]}"; done; read -p "Nums: " s; read -p "Nombre: " nz; f_z=""; for i in $s; do f_z+="${files[$i]} "; done; zip "$PATH_LAB/$nz.zip" $f_z; chmod 777 "$PATH_LAB/$nz.zip" ;;
            7) preparar indent; indent $PATH_C/*.c; echo "OK"; sleep 1 ;;
            0|00) break ;;
        esac
    done
}

menu_cine() { # [02]
    while true; do
        header; echo -e " ${Y}🎬 [02] MULTIMEDIA & CINE VIP${RE}"
        echo -e " ----------------------------------------------------"
        echo -e "  ${V}[01] •${RE} BOT TELEGRAM ON/OFF | ${V}[04] •${RE} EXTRACTOR MP3"
        echo -e "  ${V}[02] •${RE} YT A MP4 DOWNLOAD   | ${V}[05] •${RE} CONVERSOR 720P"
        echo -e "  ${V}[03] •${RE} SUBIDA MANUAL TG    | ${V}[06] •${RE} STOP VAMPIROS"
        echo -e " ----------------------------------------------------"
        echo -e "  ${R}[00] • VOLVER${RE}"
        read -p " Elije: " op
        case $op in
            1) if screen -ls | grep -q "bot-cine"; then screen -XS bot-cine quit; else cd ~/telegram-bot && screen -dmS bot-cine /usr/local/go/bin/go run ./cmd/fsb/*.go run; fi ;;
            3) python3 /root/umbrel/umbrel-data/app-data/transmission/data/config/subir_peli.py; read -p "Fin..." t ;;
            4) preparar ffmpeg; read -p "Archivo video: " v; ffmpeg -i "$v" -q:a 0 -map a audio.mp3; echo "Audio OK"; sleep 2 ;;
            6) sudo docker restart stremio-server transmission_server_1; echo "Fuga cortada"; sleep 1 ;;
            0|00) break ;;
        esac
    done
}

menu_hacking() { # [03]
    while true; do
        header; echo -e " ${Y}🛡️ [03] SEGURIDAD Y PENTESTING${RE}"
        echo -e " ----------------------------------------------------"
        echo -e "  ${V}[01] •${RE} RASTREAR IP (MAPA)  | ${V}[04] •${RE} SQL MAP (DB)"
        echo -e "  ${V}[02] •${RE} ESCANEO NMAP        | ${V}[05] •${RE} SCAN WEB (NIKTO)"
        echo -e "  ${V}[03] •${RE} QUIEN ESTA ONLINE?  | ${V}[06] •${RE} DIRSEARCH (FOLDERS)"
        echo -e " ----------------------------------------------------"
        echo -e "  ${R}[00] • VOLVER${RE}"
        read -p " Elije: " op
        case $op in
            1) read -p "IP: " t; curl ipapi.co/$t/yaml; read -p "Enter..." x ;;
            2) preparar nmap; read -p "Host: " t; nmap $t; read -p "Enter..." x ;;
            4) preparar sqlmap; read -p "URL: " t; sqlmap -u $t --batch; read -p "Enter..." x ;;
            5) preparar nikto; read -p "Web: " t; nikto -h $t; read -p "Enter..." x ;;
            0|00) break ;;
        esac
    done
}

menu_internet() { # [04]
    while true; do
        header; echo -e " ${Y}🌐 [04] CONEXION INTERNET (ADM)${RE}"
        echo -e " ----------------------------------------------------"
        echo -e "  ${V}[01] •${RE} INSTALAR DROPBEAR   | ${V}[04] •${RE} STUNNEL (SSL)"
        echo -e "  ${V}[02] •${RE} BADVPN (UDP-CUSTOM) | ${V}[05] •${RE} SQUID PROXY"
        echo -e "  ${V}[03] •${RE} SOCKS PYTHON (ALL)  | ${V}[06] •${RE} GESTION USUARIOS"
        echo -e " ----------------------------------------------------"
        echo -e "  ${R}[00] • VOLVER${RE}"
        read -p " Elije: " op
        case $op in
            1) preparar dropbear; echo "Instalado."; sleep 1 ;;
            2) read -p "Puerto UDP: " p; screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:$p ;;
            0|00) break ;;
        esac
    done
}

# --- MENU PRINCIPAL ---
while true; do
    header
    echo -e "  ${V}${B}[01] • 📂 PROGRAMACION       [09] • 🤖 IA PRIVADA (LLAMA)${RE}"
    echo -e "  ${V}${B}[02] • 🎬 CINE Y MULTIMEDIA  [10] • 🗃️  GESTION DE DATOS${RE}"
    echo -e "  ${V}${B}[03] • 🛡️  HACKING ETICO      [11] • 📊 MONITORES SALUD${RE}"
    echo -e "  ${V}${B}[04] • 🌐 CONEXION INTERNET  [12] • 🔧 UTILIDADES RED${RE}"
    echo -e "  ${V}${B}[05] • 🔐 ACCESO SEGURO OTP  [13] • 🌍 CONFIGURAR PAIS${RE}"
    echo -e "  ${V}${B}[06] • ⚙️  MANTENIMIENTO     [14] • 👥 GESTION INVITADOS${RE}"
    echo -e "  ${V}${B}[07] • 🆘 RESCATE BOT (TG)   [15] • 🐙 GITHUB SYNC${RE}"
    echo -e "  ${V}${B}[08] • 🛡️  ANTIVIRUS ESCUDO   [00] • 🔴 SALIR DEL PANEL${RE}"
    echo -e " ----------------------------------------------------"
    echo -ne "\n ${Y}${B}ELIJE UNA SECCIÓN : ${RE}"
    read main_op
    case $main_op in
        1) menu_prog ;; 2) menu_cine ;; 3) menu_hacking ;; 4) menu_internet ;;
        5) # Acceso OTP
           P_T=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 12); pkill -9 ttyd; 
           screen -dmS consola_temp ttyd -p 8091 -c root:$P_T bash;
           echo -e "${V}Link: https://web-proyect.duckdns.org/acceso/ | Pass: $P_T${RE}"; 
           read -p "Enter para cerrar..." x; pkill -9 ttyd ;;
        6) sudo sync; sudo sysctl -w vm.drop_caches=3; sudo systemctl restart nginx; echo "Limpio." ;;
        7) preparar python3; screen -dmS bot-term python3 /root/bot_terminal.py; echo "Rescate ON" ;;
        8) preparar clamav; sudo clamscan -r /root ;;
        9) preparar ollama; ollama run llama3 ;;
        11) htop ;;
        12) preparar nload; nload ;;
        13) echo "Ej: America/Managua"; read -p "Zona: " z; sudo timedatectl set-timezone $z ;;
        15) preparar git; read -p "Commit: " m; git add .; git commit -m "$m"; git push ;;
        0|00) exit ;;
    esac
done
EOF
chmod +x ~/panel.sh
