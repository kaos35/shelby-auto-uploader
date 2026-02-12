#!/bin/bash

# ============================================
# Shelby Protocol - Otomatik Resim Upload Scripti
# Günlük max 25 resim, rastgele zamanlama
# ============================================

# Ayarlar
MAX_DAILY_UPLOADS=25              # Günlük max upload
IMAGES_DIR="$HOME/shelby-images"   # Resim klasörü
LOG_FILE="$HOME/shelby-upload.log"  # Log dosyası
DATE_FILE="$HOME/shelby-date.txt"  # Son upload tarihi
COUNTER_FILE="$HOME/shelby-counter.txt"  # Günlük sayaç

# Rastgele bekleme suresi (saniye) - 60 dakika ile 4 saat arası
MIN_DELAY=3600     # 1 saat
MAX_DELAY=14400    # 4 saat

# Renkli çıktı
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Klasör oluştur
mkdir -p "$IMAGES_DIR"
cd "$IMAGES_DIR"

# Kontrol: shelby CLI
if ! command -v shelby &> /dev/null; then
    log "${RED}Hata: shelby CLI bulunamadı${NC}"
    exit 1
fi

# Kontrol: config.yaml
if [ ! -f "$HOME/.shelby/config.yaml" ]; then
    log "${RED}Hata: ~/.shelby/config.yaml bulunamadı${NC}"
    exit 1
fi

# Tarihi kontrol et ve sayaçı sıfırla
TODAY=$(date '+%Y-%m-%d')
if [ -f "$DATE_FILE" ]; then
    LAST_DATE=$(cat "$DATE_FILE")
    if [ "$LAST_DATE" != "$TODAY" ]; then
        log "${GREEN}Yeni gün! Sayaç sıfırlanıyor${NC}"
        echo "$TODAY" > "$DATE_FILE"
        echo "0" > "$COUNTER_FILE"
        CURRENT_COUNT=0
    else
        CURRENT_COUNT=$(cat "$COUNTER_FILE")
    fi
else
    echo "$TODAY" > "$DATE_FILE"
    echo "0" > "$COUNTER_FILE"
    CURRENT_COUNT=0
fi

# Günlük limit kontrolü
if [ "$CURRENT_COUNT" -ge "$MAX_DAILY_UPLOADS" ]; then
    log "${YELLOW}Günlük limit ($MAX_DAILY_UPLOADS) aşıldı! Yarına kadar bekleniyor${NC}"
    exit 0
fi

log "${GREEN}======================================"
log "Shelby Auto Upload Başlıyor"
log "Günlük: $CURRENT_COUNT/$MAX_DAILY_UPLOADS"
log "${GREEN}======================================${NC}"

# Bakiye kontrolü
log "${YELLOW}Bakiye kontrolü...${NC}"
shelby account balance | tee -a "$LOG_FILE"

# Upload işlemi
log "${GREEN}Upload işlemi başlıyor...${NC}"

# Rastgele resim URL
RANDOM_ID=$((RANDOM * RANDOM))
IMAGE_URL="https://picsum.photos/seed/$RANDOM_ID/800/600"
FILENAME="image_$RANDOM_ID.jpg"

log "${YELLOW}→ İndiriliyor: $IMAGE_URL${NC}"

if curl -L -s -o "$FILENAME" "$IMAGE_URL"; then
    FILE_SIZE=$(stat -c%s "$FILENAME" 2>/dev/null || stat -f%z "$FILENAME" 2>/dev/null)

    if [ "$FILE_SIZE" -gt 1000 ]; then
        log "${GREEN}✓ İndirme başarılı: $FILENAME ($FILE_SIZE bytes)${NC}"

        # Upload komutu
        log "${YELLOW}→ Upload ediliyor...${NC}"
        if shelby upload "$FILENAME" files/ekran.png -e tomorrow --assume-yes 2>&1 | tee -a "$LOG_FILE"; then
            log "${GREEN}✓ Upload BAŞARILI!${NC}"

            # Sayaçı artır
            NEW_COUNT=$((CURRENT_COUNT + 1))
            echo "$NEW_COUNT" > "$COUNTER_FILE"
            log "${GREEN}Günlük upload: $NEW_COUNT/$MAX_DAILY_UPLOADS${NC}"
        else
            log "${RED}✗ Upload BAŞARISIZ${NC}"
            rm "$FILENAME"
            exit 1
        fi

        # Dosyayı sil
        rm "$FILENAME"
    else
        log "${RED}✗ Dosya çok küçük, atlanıyor${NC}"
        rm "$FILENAME"
        exit 1
    fi
else
    log "${RED}✗ İndirme başarısız${NC}"
    exit 1
fi

log "${GREEN}======================================"
log "İşlem TAMAMLANDI!"
log "Sıradaki çalıştırma için cron job aktif"
log "${GREEN}======================================${NC}"
