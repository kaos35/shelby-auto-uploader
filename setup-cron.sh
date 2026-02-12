#!/bin/bash

# ============================================
# Shelby Protocol - Cron Job Kurulum Scripti
# ============================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}======================================"
echo "   Shelby Cron Job Kurulumu"
echo -e "======================================${NC}"

SCRIPT_PATH="$HOME/shelby-auto-upload.sh"

# Script'in varlığını kontrol et
if [ ! -f "$SCRIPT_PATH" ]; then
    echo -e "${RED}Hata: $SCRIPT_PATH bulunamadı!${NC}"
    exit 1
fi

# Çalıştırma izni ver
chmod +x "$SCRIPT_PATH"

# Eski cron job'ları temizle
echo -e "${YELLOW}Eski cron job'lar kontrol ediliyor...${NC}"
crontab -l 2>/dev/null | grep -v "shelby-auto-upload" | crontab -

# Yeni cron job ekle - Her 30 dakikada bir kontrol et
# Script kendi içinde limiti kontrol eder
CRON_JOB="*/30 * * * * $SCRIPT_PATH"

(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo -e "${GREEN}✓ Cron job kuruldu!${NC}"
echo ""
echo -e "${YELLOW}Aktif cron job'lar:${NC}"
crontab -l | grep shelby
echo ""
echo -e "${GREEN}======================================"
echo "Sistem şimdi her 30 dakikada bir:"
echo "- Günlük limiti kontrol eder"
echo "- Limit doluysa bekleme yapar"
echo "- Rastgele bir resim upload eder"
echo -e "======================================${NC}"
echo ""
echo -e "${YELLOW}Log dosyasını izlemek için:${NC}"
echo "tail -f ~/shelby-upload.log"
echo ""
echo -e "${YELLOW}Logları görüntülemek için:${NC}"
echo "cat ~/shelby-upload.log"
