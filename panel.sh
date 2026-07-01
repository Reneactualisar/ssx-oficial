cat <<'EOF' > ~/panel.sh
#!/bin/bash

# --- COLORES Y ESTILO ---
V='\e[1;32m'; R='\e[1;31m'; A='\e[1;34m'; C='\e[1;36m'; Y='\e[1;33m'; B='\e[1;37m'; RE='\e[0m'

# --- RUTAS ---
PATH_LAB="/root/umbrel/umbrel-data/home/Downloads/laboratorio_c"
PATH_C="$PATH_LAB/CODIGOS"
VNC_FILE="/usr/share/novnc/vnc.html"
{
# --- FUNCIÓN: CONFIGURACIÓN AUTOMÁTICA DE INTERCAMBIO ---
auto_setup_share() {
    echo -e "${Y}🔍 Verificando sistema de intercambio...${RE}"

    # 1. Instalar qrencode (QR) y at (Tiempo) si no existen
    if ! command -v qrencode &> /dev/null || ! command -v at &> /dev/null; then
        echo -e "${Y}⚙️ Instalando herramientas faltantes...${RE}"
        sudo apt update && sudo apt install -y qrencode at
        sudo systemctl enable --now atd
    fi

    # 2. Crear carpeta pública si no existe
    if [ ! -d "/var/www/html/share" ]; then
        sudo mkdir -p /var/www/html/share
        sudo chmod 777 /var/www/html/share
    fi

    # 3. Inyectar en Nginx si la ruta /share/ no existe
    NGINX_FILE="/etc/nginx/sites-available/web-definitiva"
    if [ -f "$NGINX_FILE" ]; then
        if ! grep -q "location /share/" "$NGINX_FILE"; then
            echo -e "${Y}⚙️ Abriendo puerta /share/ en Nginx...${RE}"
            sudo sed -i '/location \/c\/ {/i \
    location /share/ { \
        alias /var/www/html/share/; \
        autoindex off; \
        add_header Content-Disposition "attachment"; \
    }' "$NGINX_FILE"
            sudo systemctl restart nginx
        fi
    fi
    echo -e "${V}✔ Todo listo para compartir.${RE}"
    sleep 1
    }
# --- FUNCIÓN DE AUTO-INSTALACIÓN PARA COMPARTIR ---
preparar_sistema_share() {
    # 1. Instalar paquetes si faltan (at para tiempo, qrencode para QR)
    if ! command -v at &> /dev/null || ! command -v qrencode &> /dev/null; then
        echo -e "${Y}⚙️ Componentes faltantes detectados. Instalando...${RE}"
        sudo apt update && sudo apt install -y at qrencode
        sudo systemctl enable --now atd
    fi

    # 2. Crear la carpeta compartida si no existe
    if [ ! -d "/var/www/html/share" ]; then
        sudo mkdir -p "/var/www/html/share"
        sudo chmod 777 "/var/www/html/share"
    fi

    # 3. Inyectar la "puerta" en Nginx automáticamente
    if ! grep -q "location /share/" "/etc/nginx/sites-available/web-definitiva"; then
        echo -e "${Y}⚙️ Configurando acceso publico en Nginx...${RE}"
        sudo sed -i '/location \/c\/ {/i \
    location /share/ { \
        alias /var/www/html/share/; \
        autoindex off; \
        add_header Content-Disposition "attachment"; \
    }' "/etc/nginx/sites-available/web-definitiva"
        sudo systemctl restart nginx
    fi
}

# --- MOTOR DE ESTADO ---
st() {
    if pgrep "$1" > /dev/null || screen -ls | grep -q "$1" || [ "$(systemctl is-active $1 2>/dev/null)" == "active" ]; then
        echo -ne "${V}ON${RE}"; else echo -ne "${R}OFF${RE}"; fi
}

# --- ENCABEZADO PRO ---
header() {
    clear
    IP_V=$(hostname -I | awk '{print $1}')
    HORA=$(date +"%I:%M:%S %p")
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')"%"
    RAM=$(free -h | awk 'NR==2 {print $3}')
    echo -e "${A}╔══════════════════════════════════════════════════════════════╗${RE}"
    echo -e "║  ${B}SSX-OFICIAL v60.0 - SECURITY ARCHITECT EDITION${RE}              ${A}║${RE}"
    echo -e "║  ${B}DXVID DEVELOPER - MODO PREVENTIVO ACTIVADO${RE}                  ${A}║${RE}"
    echo -e "╠══════════════════════┳═══════════════════════┳═══════════════╣${RE}"
    echo -e "║ ${C}SISTEMA${RE}             ${A}║${RE} ${C}MEMORIA RAM${RE}           ${A}║${RE} ${C}PROCESADOR${RE}    ${A}║${RE}"
    printf "${A}║${RE} IP: %-16s ${A}║${RE} En uso: %-14s ${A}║${RE} CPU: %-9s ${A}║${RE}\n" "$IP_V" "$RAM" "$CPU"
    printf "${A}║${RE} Hora: %-14s ${A}║${RE} T. C: $(st dosbox)        ${A}║${RE} BOT: $(st bot-cine)    ${A}║${RE}\n" "$HORA"
    echo -e "${A}╚══════════════════════╩═══════════════════════╩═══════════════╝${RE}"
}

# --- DEPARTAMENTOS ---

menu_prog() { # [S1]
    while true; do
        header; echo -e " ${Y}📂 [01] PROGRAMACION Y OPTIMIZACION (C)${RE}"
        echo -e " ----------------------------------------------------"
        echo -e "  ${V}[01] •${RE} TURBO C (ON/OFF)    | ${V}[05] •${RE} COMPILAR (GCC PRO)"
        echo -e "  ${V}[02] •${RE} CREAR .C (PEGAR)    | ${V}[06] •${RE} FORMATEAR (INDENT)"
        echo -e "  ${V}[03] •${RE} PLANTILLA EXAMEN    | ${V}[07] •${RE} ZIP SELECTIVO"
        echo -e "  ${V}[04] •${RE} BUSCAR EN CODIGOS   | ${V}[08] •${RE} LIMPIAR .OBJ/.EXE"
        echo -e " ----------------------------------------------------"
        echo -e "  ${R}[00] • VOLVER${RE}"
        read -p " Acción: " op
        case $op in
            1) if screen -ls | grep -q "laboratorio"; then sudo pkill -9 dosbox; else screen -dmS laboratorio bash ~/start_turboc.sh; fi ;;
            2) read -p "Nombre: " n; [[ $n != *.c ]] && n="$n.c"; echo "Pega código y escribe FIN:"; lines=(); while read -r l; do [[ "$l" == "FIN" ]] && break; lines+=("$l"); done; printf "%s\n" "${lines[@]}" > "$PATH_C/$n"; chmod 777 "$PATH_C/$n" ;;
            5) read -p "Archivo a compilar: " f; gcc -O3 "$PATH_C/$f" -o "$PATH_C/prog.out" -lm && echo "¡Optimizado! Ejecutando:"; "$PATH_C/prog.out"; read -p "Enter..." x ;;
            7) cd $PATH_C; files=(*.c); for i in "${!files[@]}"; do echo "[$i] ${files[$i]}"; done; read -p "Nums: " s; read -p "Nom: " nz; f_z=""; for i in $s; do f_z+="${files[$i]} "; done; zip "$PATH_LAB/$nz.zip" $f_z ;;
            8) rm -rf $PATH_C/*.OBJ $PATH_C/*.EXE; echo "Limpio." ;;
            0|00) break ;;
        esac
    done
}

menu_hacker() { # [S3]
    while true; do
        header; echo -e " ${Y}🛡️ [03] AUDITORIA DE SEGURIDAD Y HACKING${RE}"
        echo -e " ----------------------------------------------------"
        echo -e "  ${V}[01] •${RE} RASTREAR IP (MAPA)  | ${V}[04] •${RE} NMAP (SCAN PUERTOS)"
        echo -e "  ${V}[02] •${RE} NIKTO (SCAN WEB)    | ${V}[05] •${RE} SQL MAP (AUDIT DB)"
        echo -e "  ${V}[03] •${RE} DIRB (FOLDERS)      | ${V}[06] •${RE} BLOQUEAR IP (BAN)"
        echo -e " ----------------------------------------------------"
        echo -e "  ${V}[07] •${RE} QUIEN ENTRA A MI WEB (LOGS EN VIVO)"
        echo -e "  ${V}[08] •${RE} HISTORIAL DE ACCESOS (SSH)"
        echo -e "  ${R}[00] • VOLVER${RE}"
        read -p " Acción: " op
        case $op in
            1) read -p "IP: " t; DATA=$(curl -s http://ip-api.com/json/$t); LAT=$(echo $DATA | grep -oP '(?<="lat":)[^,]*'); LON=$(echo $DATA | grep -oP '(?<="lon":)[^,]*'); echo -e "${V}Ubicación: $DATA${RE}\n${C}Mapa: https://www.google.com/maps?q=$LAT,$LON${RE}"; read -p "Enter..." x ;;
            2) read -p "URL: " t; nikto -h $t; read -p "Enter..." x ;;
            3) read -p "URL: " t; dirb $t; read -p "Enter..." x ;;
            4) read -p "Host: " t; nmap -F $t; read -p "Enter..." x ;;
            5) read -p "URL: " t; sqlmap -u $t --batch; read -p "Enter..." x ;;
            6) read -p "IP a banear: " bip; sudo ufw deny from $bip; sudo ufw reload ;;
            7) sudo tail -f /var/log/nginx/access.log ;;
            8) last -n 15; read -p "Enter..." x ;;
            0|00) break ;;
        esac
    done
}
# --- DEPARTAMENTO DE INTERCAMBIO ---
menu_compartir() {
    auto_setup_share  # <--- ESTA LÍNEA HACE LA MAGIA
    while true; do
        header
        echo -e " ${Y}📤 [S13] COMPARTIR LINK CON QR${RE}"
        # ... (el resto de tu código igual)
    preparar_sistema_share # Primero ejecuta la auto-instalacion
    while true; do
        header
        echo -e " ${Y}📤 [S13] INTERCAMBIO DE ARCHIVOS (QR)${RE}"
        echo -e " ----------------------------------------------------"
        echo -e "  ${V}[1] •${RE} COMPARTIR CODIGO .C (CON QR)"
        echo -e "  ${V}[2] •${RE} COMPARTIR LINK EXTERNO (QR TEMP)"
        echo -e " ----------------------------------------------------"
        echo -e "  ${R}[0] • VOLVER${RE}"
        read -p " Acción: " c_op
        
        if [ "$c_op" == "1" ]; then
            cd "$PATH_C"
            files=(*)
            for i in "${!files[@]}"; do echo -e "[$i] ${files[$i]}"; done
            read -p "Número: " idx
            read -p "Minutos de vida: " mins
            RANDOM_N=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)
            FILE_FIN="$RANDOM_N.${files[$idx]##*.}"
            cp "${files[$idx]}" "/var/www/html/share/$FILE_FIN"
            LINK="https://web-proyect.duckdns.org/share/$FILE_FIN"
            clear; echo -e "${V}✔ QR GENERADO PARA: ${files[$idx]}${RE}"; qrencode -t ansiutf8 "$LINK"
            echo "rm -f /var/www/html/share/$FILE_FIN" | at now + $mins minutes
            read -p "Enter para volver..." x
        elif [ "$c_op" == "0" ]; then break; fi
    done
}
# --- MENU PRINCIPAL ---
while true; do
    header
    echo -e "  ${V}${B}[01] • 📂 PROGRAMACION DIOS   [06] • 🧹 OPTIMIZAR SISTEMA${RE}"
    echo -e "  ${V}${B}[02] • 🎬 CINE Y STREAMING   [07] • 📊 MONITORES (HTOP)${RE}"
    echo -e "  ${V}${B}[03] • 🛡️  AUDITORIA HACKER   [08] • 🗃️  GESTOR DE DISCO${RE}"
    echo -e "  ${V}${B}[04] • 🌐 CONEXION INTERNET  [09] • 🌍 CONFIGURAR PAIS${RE}"
    echo -e "  ${V}${B}[05] • 🔐 ACCESO SEGURO OTP  [10] • 🆘 BOT RESCATE (TG)${RE}"
    echo -e " ----------------------------------------------------"
    echo -e "  ${V}${B}[11] • 🤖 IA PRIVADA (LLAMA) [12] • 📦 BACKUP AUTO (ZIP)${RE}"
    echo -e "  ${V}${B}[13] • 📤 COMPARTIR LINK CON QR
    echo -e " ----------------------------------------------------"
    echo -ne "\n ${Y}${B}INFORME UNA OPCION : ${RE}"
    read main_op
    case $main_op in
        1) menu_prog ;;
        2) while true; do header; echo -e " [1] BOT ON | [2] BOT OFF | [3] SUBIDA MANUAL | [0] VOLVER"; read c; [[ $c == 1 ]] && cd ~/telegram-bot && screen -dmS bot-cine /usr/local/go/bin/go run ./cmd/fsb/*.go run; [[ $c == 2 ]] && screen -XS bot-cine quit; [[ $c == 3 ]] && python3 $SCRIPT_PELI; [[ $c == 0 ]] && break; done ;;
        3) menu_hacker ;;
        4) header; echo -e "${Y}Protocolos de Red (ADM):${RE}"; read -p "Enter..." t ;;
        5) P_T=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 12); pkill -9 ttyd; screen -dmS consola_temp ttyd -p 8091 -c root:$P_T bash; echo -e "${V}Pass: $P_T | Link: .../acceso/"; read -p "Enter para cerrar..." x; pkill -9 ttyd ;;
        6) sudo sync; sudo sysctl -w vm.drop_caches=3; sudo docker system prune -f; echo "Limpio." ;;
        7) htop ;;
        8) ncdu / ;;
        9) echo "Ej: America/Managua"; read -p "Zona: " z; sudo timedatectl set-timezone $z ;;
        10) screen -dmS bot-term python3 /root/bot_terminal.py; echo "Rescate ON" ;;
        11) ollama run llama3 ;;
        12) cd /root && zip -r backup_$(date +%d%m).zip umbrel telegram-bot; echo "Hecho." ;;
        13) menu_compartir ;;
        0) exit ;;
    esac
done
EOF
chmod +x ~/panel.sh
alias panel='bash ~/panel.sh'
source ~/.bashrc
