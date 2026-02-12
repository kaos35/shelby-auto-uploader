#!/bin/bash

# ============================================
# Shelby Protocol - Sunucu Kurulum Scripti
# Ubuntu/Debian için
# ============================================

set -e

# Renkli çıktı
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================"
echo -e "   Shelby Protocol - Sunucu Kurulumu"
echo -e "============================================${NC}"

# Root kontrolü
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Bu script root yetkisi gerektiriyor. Lütfen çalıştırın:${NC}"
    echo -e "${YELLOW}sudo bash shelby-server-setup.sh${NC}"
    exit 1
fi

echo -e "${GREEN}[1/5] Sistem güncelleniyor...${NC}"
apt update && apt upgrade -y

echo -e "${GREEN}[2/5] Gerekli paketler kuruluyor...${NC}"
apt install -y curl wget git build-essential

echo -e "${GREEN}[3/5] Node.js v22 kuruluyor...${NC}"
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt install -y nodejs
else
    echo -e "${YELLOW}Node.js zaten kurulu: $(node -v)${NC}"
fi

echo -e "${GREEN}[4/5] Shelby CLI kuruluyor...${NC}"
npm i -g @shelby-protocol/cli

echo -e "${GREEN}[5/5] Kurulum doğrulanıyor...${NC}"
node --version
npm --version
shelby --version

echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${GREEN}✓ Kurulum tamamlandı!${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "${YELLOW}Sırada adımlar:${NC}"
echo -e "1. ${YELLOW}shelby init${NC} - İlk kez başlatma"
echo -e "2. ${YELLOW}shelby account blobs${NC} - Hesap oluşturma"
echo -e "3. API key oluşturma: ${BLUE}https://console.shelby.com${NC}"
echo -e "4. Faucet: ${YELLOW}shelby faucet${NC} (Aptos + ShelbyUSD)"
echo ""
echo -e "${GREEN}Otomatik upload scripti: ${BLUE}shelby-auto-upload.sh${NC}"
echo -e "${GREEN}Upload scripti çalıştırma: ${YELLOW}./shelby-auto-upload.sh${NC}"
