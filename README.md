# 🤖 Shelby Protocol Otomatik Resim Uploader

Shelby Protocol Devnet üzerinde günlük maksimum 25 resmi otomatik olarak yükleyen, tam otomatize edilmiş bir sistemdir.

## 📋 Özellikler

- ✅ **Tam Otomatik**: Kurulum sonrası hicbir manuel müdahale gerektirmez
- ✅ **Günlük Limit**: Her gün maksimum 25 resim upload eder
- ✅ **Rastgele Zamanlama**: Upload'lar arası 1-4 saat arası rastgele bekleme
- ✅ **Otomatik Yenileme**: Her yeni gün sayaç otomatik sıfırlanır
- ✅ **Loglama**: Tüm işlemler detaylı loglanır
- ✅ **Sistem Entegrasyonu**: Systemd timer ile otomatik başlangıç
- ✅ **Hata Yönetimi**: Basarısız işlemler otomatik yeniden denenir

## 🎯 Kullanım Senaryosu

```
┌─────────────────────────────────────────────────────────────────┐
│                    OTOMATIK DÖNGÜ                            │
├─────────────────────────────────────────────────────────────────┤
│                                                            │
│  Her 30 dakikada bir kontrol et:                           │
│  ├── Günlük limit (25) aşıldı mı?                         │
│  │   └── EVET → Yarına kadar bekle                        │
│  │   └── HAYIR → Devam et                                │
│                                                            │
│  └── Rastgele resim indir (picsum.photos)                 │
│      └── Upload et                                       │
│      └── Sayaçı artır (+1)                               │
│      └── Logla                                          │
│                                                            │
│  Yeni gün → Sayaç sıfırla                                │
└─────────────────────────────────────────────────────────────────┘
```

## 📋 Ön Koşullar

| Gereksinim | Minimum Versiyon | Not |
|-------------|-----------------|-----|
| İşletim Sistemi | Ubuntu 22.04+ | Debian/Ubuntu tabanlı |
| Node.js | v22.0.0+ | Zorunlu |
| RAM | 1 GB+ | Önerilen: 2 GB |
| Disk | 10 GB+ | Loglar için |

## 🚀 Kurulum

### 1. Adım: Sunucuya Bağlanın

```bash
ssh root@SUNUCU_IP_ADRESI
```

### 2. Adım: Depoyu Klonlayın

```bash
cd /root
git clone https://github.com/KULLANICI_ADI/shelby-auto-uploader.git
cd shelby-auto-uploader
```

### 3. Adım: Kurulum Scriptini Çalıştırın

```bash
sudo bash shelby-server-setup.sh
```

Bu script şunları yapar:
- Sistemi günceller
- Node.js v22 kurar
- Gerekli paketleri kurar
- Shelby CLI'yi kurar

### 4. Adım: Shelby İlk Kurulumu

```bash
# 1. Shelby'yi başlatın
shelby init

# 2. Hesap oluşturun
shelby account blobs

# 3. API key almak için:
#    https://geomi.dev
#    → "Sign Up / Log In" ile giriş yapın
#    → "API Access" bölümüne gidin
#    → "Generate API Key" butonuna tıklayın
#    → Network olarak "Shelbynet" seçin
#    → API key'i kopyalayın

# 4. API key'i ekleyin
shelby context update shelbynet --indexer-api-key SIZIN_API_KEYINIZ

# 5. Token alın (Aptos + ShelbyUSD)
shelby faucet
# Bu komut tarayıcıda faucet sayfasını açar
# Açılan sayfada "Fund" butonuna tıklayın

# 6. Bakiyeyi kontrol edin
shelby account balance
```

### 5. Adım: Otomatik Upload Sistemini Başlatın

```bash
sudo bash setup-systemd.sh
```

Bu script şunları yapar:
- Systemd service dosyası oluşturur
- Timer dosyası oluşturur (her 30 dakikada)
- Servisi enable eder
- Timer'ı başlatır

## 📊 Kurulum Sonrası Yapılandırmalar

### Sistem Durumu Kontrolü

```bash
# Timer durumunu görün
systemctl status shelby-upload.timer

# Service durumunu görün
systemctl status shelby-upload.service
```

### Logları İzleme

```bash
# Canlı log izleme
journalctl -u shelby-upload.service -f

# Son 50 log satırı
journalctl -u shelby-upload.service -n 50 --no-pager

# Tüm loglar
cat ~/shelby-upload.log
```

### Upload Sayaçı

```bash
# Günlük upload sayaçı
cat ~/shelby-counter.txt

# Son çalıştırma tarihi
cat ~/shelby-date.txt
```

## ⚙️ Yapılandırma

### Upload Limiti Değiştirme

Varsayılan günlük limit: 25 resim

```bash
# 50 resme çıkarmak için
nano ~/shelby-auto-upload.sh
# MAX_DAILY_UPLOADS=50 olarak değiştirin

# Veya sed ile
sed -i 's/MAX_DAILY_UPLOADS=25/MAX_DAILY_UPLOADS=50/' ~/shelby-auto-upload.sh
```

### Timer Aralığını Değiştirme

Varsayılan: Her 30 dakikada bir

```bash
# 1 saat arası ile
nano /etc/systemd/system/shelby-upload.timer
# OnUnitActiveSec=1h olarak değiştirin

# Veya sed ile
sed -i 's/OnUnitActiveSec=30min/OnUnitActiveSec=1h/' /etc/systemd/system/shelby-upload.timer

# Systemd'ı yenileyin
systemctl daemon-reload
systemctl restart shelby-upload.timer
```

### Rastgele Bekleme Aralığını Değiştirme

```bash
nano ~/shelby-auto-upload.sh

# Değiştirin:
# MIN_DELAY=3600    # Minimum 1 saat
# MAX_DELAY=14400   # Maximum 4 saat
```

## 🔧 Yönetim Komutları

### Sistemi Başlatma/Durdurma

```bash
# Timer'ı başlat
sudo systemctl start shelby-upload.timer

# Timer'ı durdur
sudo systemctl stop shelby-upload.timer

# Servisi yeniden başlat
sudo systemctl restart shelby-upload.service
```

### Sistemi Devre Dışı Bırakma

```bash
# Timer'ı devre dışı bırak
sudo systemctl disable shelby-upload.timer

# Servisi durdur
sudo systemctl stop shelby-upload.timer

# Servisi sil
sudo systemctl disable shelby-upload.service
sudo rm /etc/systemd/system/shelby-upload.*
sudo systemctl daemon-reload
```

### Manuel Upload

```bash
# Tek seferlik upload
bash ~/shelby-auto-upload.sh

# Upload sonrası sayaç kontrolü
cat ~/shelby-counter.txt
```

## 📂 Dosya Yapısı

```
shelby-auto-uploader/
├── README.md                    # Bu dosya
├── shelby-server-setup.sh        # Sunucu kurulum scripti
├── shelby-auto-upload.sh         # Otomatik upload scripti
├── setup-systemd.sh              # Systemd timer kurulumu
├── setup-cron.sh                 # Cron job alternatifi
├── .gitignore                   # Git ignore dosyası
└── LICENSE                      # MIT Lisansı
```

## 🔍 Sorun Giderme

### Sorun: "API key not found" hatası

```bash
# API key'i yenileyin
shelby context update shelbynet --indexer-api-key YENI_API_KEY

# Bakiyeyi kontrol edin
shelby account balance
```

### Sorun: "Günlük limit aşıldı"

```bash
# Sayaçı sıfırlayın
echo "0" > ~/shelby-counter.txt
echo "$(date '+%Y-%m-%d')" > ~/shelby-date.txt
```

### Sorun: Servis çalışmıyor

```bash
# Servis durumunu kontrol edin
systemctl status shelby-upload.service

# Detaylı loglar
journalctl -u shelby-upload.service -n 100 --no-pager

# Servisi yeniden başlatın
sudo systemctl restart shelby-upload.service
```

### Sorun: Indirilen resimler kalıyor

```bash
# Temizlik - eski dosyaları silin
rm -rf ~/shelby-images/*

# Sadece bugünün loglarını tutun
echo "" > ~/shelby-upload.log
```

## 📈 İstatistikler

Sistem çalışmaya başladığında şu istatistikler takip edilir:

| Metrik | Açıklama |
|--------|-----------|
| Günlük Upload Sayısı | `/root/shelby-counter.txt` |
| Son Çalıştırma Tarihi | `/root/shelby-date.txt` |
| Toplam Upload Logları | `/root/shelby-upload.log` |
| Sistem Logları | `journalctl -u shelby-upload.service` |

## 🔐 Güvenlik

- Cüzdan private key'i `~/.shelby/config.yaml` dosyasında saklanır
- Log dosyalarında hicbir hassas bilgi bulunmaz
- API key sadece shelbynet indexer API'sine erişim için kullanılır

## 📝 Lisans

Bu proje MIT Lisansı altında lisanslanmıştır. [LICENSE](LICENSE) dosyasına bakın.

## 🤝 Katkıda Bulunma

Katkıda bulunmak isterseniz:

1. Depoyu fork edin
2. Yeni bir branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📧 İletişim

Sorunlarınız için GitHub Issues kullanabilirsiniz.

## ⭐ Bağış

Bu proje size yardımcı olduysa, lütfen bir ⭐ verin!

---

**Not**: Bu proje sadece eğitim ve test amaçlıdır. Production ortamlarında kullanmadan önce lütfen gerekli testleri yapın.
