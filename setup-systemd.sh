#!/bin/bash

# ============================================
# Shelby Protocol - Systemd Service Kurulum
# ============================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}======================================"
echo "Shelby Systemd Service Kurulumu"
echo -e "======================================${NC}"

SCRIPT_PATH="$HOME/shelby-auto-upload.sh"
SERVICE_FILE="/etc/systemd/system/shelby-upload.service"
TIMER_FILE="/etc/systemd/system/shelby-upload.timer"

# Service dosyası oluştur
echo -e "${YELLOW}Service dosyası oluşturuluyor...${NC}"

sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Shelby Protocol Auto Upload Service
After=network.target

[Service]
Type=oneshot
User=root
WorkingDirectory=$HOME
ExecStart=$SCRIPT_PATH
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Timer dosyası oluştur
echo -e "${YELLOW}Timer dosyası oluşturuluyor...${NC}"

sudo tee $TIMER_FILE > /dev/null <<EOF
[Unit]
Description=Shelby Protocol Auto Upload Timer
Requires=shelby-upload.service

[Timer]
OnBootSec=5min
OnUnitActiveSec=30min
AccuracySec=1s

[Install]
WantedBy=timers.target
EOF

# Systemd'ı yenile
echo -e "${YELLOW}Systemd yenileniyor...${NC}"
sudo systemctl daemon-reload

# Service ve timer'ı başlat
echo -e "${YELLOW}Service ve timer başlatılıyor...${NC}"
sudo systemctl enable shelby-upload.timer
sudo systemctl start shelby-upload.timer

echo ""
echo -e "${GREEN}✓ Kurulum tamamlandı!${NC}"
echo ""
echo -e "${YELLOW}Durum kontrolü:${NC}"
sudo systemctl status shelby-upload.timer --no-pager
echo ""
echo -e "${YELLOW}Son loglar:${NC}"
sudo journalctl -u shelby-upload.service -n 20 --no-pager
echo ""
echo -e "${YELLOW}Log izleme:${NC}"
echo "sudo journalctl -u shelby-upload.service -f"
echo ""
echo -e "${YELLOW}Timer durdurmak için:${NC}"
echo "sudo systemctl stop shelby-upload.timer"
echo ""
echo -e "${YELLOW}Timer başlatmak için:${NC}"
echo "sudo systemctl start shelby-upload.timer"
