# KONUM Core Depo İncelemesi (5 Nisan 2026)

## 0) Tekrar Kontrol Notu (5 Nisan 2026 - İkinci Geçiş)

Bu ikinci kontrolde önceki bulgular yeniden doğrulandı ve güncel durum aşağıdaki gibi revize edildi:

- ✅ **Android paket kimliği tutarsızlığı düzeltilmiş görünüyor.**
  - `namespace`, `applicationId` ve `AndroidManifest` paket adı `com.konum.app` olarak tutarlı.
- ⚠️ **Test dosyasında paket importu kırık durumdaydı** (eski paket adı), bu nedenle test altyapısı halen kırılgan.
- ⚠️ **e-posta bazlı admin sabiti ile sabit süper yetki ataması** sürüyor; RBAC tarafında tek noktadan yetkilendirme önerisi geçerliliğini koruyor.
- ⚠️ **Hata yönetimi ve gözlemlenebilirlik** hâlâ büyük oranda `Get.snackbar + debugPrint` düzeyinde.
- ⚠️ **Timestamp standardizasyonu** büyük ölçüde iyi olsa da bazı yerlerde string zaman formatı kullanımına dikkat edilmeli.

### Tekrar Kontrol Sonrası Net Eleştiri

1. Mimari yön doğru: rol bazlı ayrım korunmuş, ancak authorization modeli büyümeye karşı hâlâ kırılgan.
2. Operasyonel akışlar iyi kapsamlanmış, fakat hata takibi/telemetri üretim ölçeğinde yetersiz.
3. Kod tabanı canlı ürün hissi veriyor; buna rağmen test güveni düşük kaldığı için regressions riski yüksek.

### Tekrar Kontrol Sonrası Kısa Öneri Paketi

1. **RBAC sertleştirme:** e-posta bazlı admin sabiti kuralını acil olarak claim + rule tabanlı modele taşıyın.
2. **Test kapısı:** CI’da minimum `flutter analyze` + `flutter test` zorunlu olsun.
3. **Error logging standardı:** kritik akışlarda merkezi log servisi + severity standardı ekleyin.
4. **Tarih alanı standardı:** tüm domainlerde `Timestamp` + tek biçimlenmiş serializer/deserializer kullanın.
5. **Yolculuk durum geçişleri için unit test:** özellikle acceptance/start/complete/cancel state akışına hedefli test yazın.

## 1) Genel Mimari Özeti

- Proje bir **Flutter + GetX** mobil uygulaması ve üç temel rol etrafında kurgulanmış: `driver`, `passenger`, `admin` (ve e-posta bazlı e-posta bazlı süper admin).
- Giriş noktası `lib/main.dart` içinde Firebase init + global controller kayıtları ile başlıyor.
- Rotalar `lib/routes/app_pages.dart` üzerinde merkezi tanımlı; ekranlar rol bazlı organize edilmiş.
- Veri katmanı doğrudan Firebase Auth + Firestore + Storage üzerinden controller/service içinde yönetiliyor.

## 2) Güçlü Yönler

1. **Rol bazlı akış net:**
   - Auth değişiminde rol tespiti var (`admins` → `drivers` → `passengers`) ve role göre yönlendirme yapılıyor.
2. **Domain ayrımı mevcut:**
   - Driver, passenger, admin akışları ayrı controller ve ayrı view klasörlerinde.
3. **Canlı operasyon odaklı alanlar:**
   - Driver konum yayını, ride lifecycle, payout ve penalty akışları temel MVP için yerinde.
4. **Fiyatlandırma modeli tek yerde:**
   - `RideService` içinde segment, komisyon, piyasa katsayısı ve fatura numarası üreten tekil yapı bulunuyor.

## 3) Kritik Riskler / Teknik Borç

### A) Güvenlik ve Gizli Bilgi Yönetimi

- **Kritik:** `lib/firebase_options.dart` içinde açık API anahtarları görünüyor.
- **Kritik:** `AndroidManifest.xml` içinde Google Maps API key düz metin olarak gömülü.
- Bu anahtarlar istemci tarafında tamamen gizlenemese de, en azından platform kısıtları (SHA/package, bundle id, API restriction, quota alerts) ve çevresel ayrıştırma zorunlu.

### B) Kimlik/Rol Güvenliği

- e-posta bazlı süper admin rolü tek e-posta sabiti (e-posta bazlı admin sabiti) üzerinden atanıyor. Bu yaklaşım operasyonel ama ölçeklenebilir RBAC için kırılgan.
- Admin kontrolü `admins` koleksiyonuna dayanıyor; iyi bir başlangıç olsa da Firestore security rules tarafı görünmüyor.

### C) Android Paket Kimliği Tutarsızlığı

- `build.gradle.kts` içindeki `namespace/applicationId = com.ortakyol.driver`.
- `AndroidManifest.xml` ise `package="com.konum.app"`.
- Kaynak klasörlerinde iki farklı `MainActivity` yolu var (`com/konum/app` ve `com/ortakyol/driver`).
- Bu durum release, deeplink, push, store dağıtımı ve hata izleme entegrasyonlarında sorun çıkarabilir.

### D) Test Altyapısı Zayıf ve Muhtemelen Kırık

- Tek widget testi var ve package import geçmişte güncel adla uyumsuzdu; `pubspec.yaml` paket adı `konum_app`.
- Testte aranan metin (eski marka metni) güncel UI ile uyumlu görünmüyor.
- İş mantığı (fare hesaplama, rol/redirect, ride state geçişleri) için unit test yok.

### E) Controller Katmanında Yoğun Sorumluluk

- Controller’lar hem UI state hem network/store hem business rule yönetiyor.
- Özellikle `DriverController` ve `PassengerController` büyümüş; transaction/atomic update gerektiren yerlerde servis/repository sınırı zayıf.

## 4) Kod Kalitesi ve Bakım Değerlendirmesi

- Kod okunabilirliği genel olarak iyi, Türkçe açıklamalar güçlü.
- Ancak **hata yönetimi** çoğunlukla `Get.snackbar + debugPrint` ile sınırlı; merkezi error model/logging yok.
- Firestore timestamp/string karışımı var (`createdAt` bazen ISO string, bazen `FieldValue.serverTimestamp`). Bu uzun vadede sorgu/sıralamada sürpriz üretir.
- Bazı route guard kararları iyi olsa da permission matrisi kapsamı sınırlı; yeni route eklendikçe kaçak risk artar.

## 5) Öncelikli İyileştirme Planı (Önerilen)

### İlk 7 Gün (Hızlı Kazanç)

1. Android paket adını tekilleştir (`namespace`, `applicationId`, manifest package, kotlin path).
2. Test importlarını ve smoke testi düzelt; CI’da en az `flutter analyze` + `flutter test` koştur.
3. Firestore tarih alanlarını standardize et (tercihen Timestamp).
4. Route izin matrisi için tüm private route’ları kapsayan deny-by-default yaklaşımına geç.

### 2–4 Hafta

1. Controller → Service/Repository ayrımı.
2. Fare hesaplama ve matching için unit test paketi.
3. Auth/role akışına integration test.
4. Güvenlik sertleştirme (rules audit, API restrictions, monitoring).

### 1–2 Ay

1. Observability: Crashlytics + yapılandırılmış log/event standardı.
2. Domain bazlı modülerizasyon (auth, ride, payout, legal).
3. Offline dayanıklılığı ve retry stratejileri.

## 6) Sonuç

Depo, MVP’den üretim olgunluğuna geçmeye aday bir temel sunuyor: rol bazlı akışlar, fiyatlandırma motoru ve operasyon ekranları mevcut. En büyük risk alanları **güvenlik yapılandırması**, **paket kimliği tutarlılığı** ve **test otomasyonu eksikliği**. Bu üç başlık önceliklendirilirse ürünün stabilitesi ve güveni ciddi şekilde artar.

## 7) Ek Talimat Notu: GenAI App Builder Trial Credit Kaydı

Aşağıdaki finansal/promo satırı ayrıca kayıt altına alınmıştır:

- Ürün: **GenAI App Builder Trial credit**
- Durum: **Available (%100)**
- Tutar: **₺42,451.50**
- Tür: **One-time**
- Referans: `da4d55d98b481190361e1c2ae95c944c17544fcf5e57f401f72a7af9684c7dcb`
- Geçerlilik aralığı: **14 Aralık 2025 – 14 Aralık 2026**
- Not: "Certain usage; see the terms of the promotion for details." ifadesi nedeniyle gerçek kullanım kapsamı promosyon şartlarına bağlıdır.

### Operasyonel Yorum

- Bu kayıt, doğrudan uygulama kodu kalitesini etkilemez; ancak bulut maliyet planlaması ve tüketim takibi için önemlidir.
- 14 Aralık 2026 tarihine kadar kullanım/harcama metriklerinin aylık olarak izlenmesi ve kredi tükenmeden önce maliyet alarmı tanımlanması önerilir.

## 8) Bu Kredi ile Neler Yaparız? (Pratik Plan)

> Geçerlilik: **14 Aralık 2025 – 14 Aralık 2026** aralığında kullanılabilir.

### A) Üründe Hızlı Değer Üretecek 5 Senaryo

1. **Sürücü AI Asistanını güçlendirme (ilk öncelik):**
   - Sürücülerin rota, yoğunluk, kazanç optimizasyonu ve sık soru cevapları için GenAI tabanlı yardımcı akışları.
2. **Admin paneli için operasyon özeti üretimi:**
   - "Bugün en yoğun saatler", "en çok iptal edilen bölgeler", "riskli operasyon noktaları" gibi metin özetleri.
3. **Destek otomasyonu (müşteri/sürücü):**
   - Sık gelen destek taleplerini sınıflandırma ve hazır cevap taslakları.
4. **Hukuki metin sadeleştirme yardımcıları:**
   - KVKK/aydınlatma/şartlar metinlerinin sade anlatımlı özetleri (nihai onay insan kontrolünde).
5. **Kalite güvence ve içerik denetimi:**
   - Uygulama içi metinlerin ton, tutarlılık ve dil kalite kontrolü.

### B) 90 Günlük Uygulanabilir Yol Haritası

- **Gün 1–14:** PoC dönemi
  - 1 adet yüksek etkili kullanım (AI Asistan) seçimi
  - İstek/yanıt loglaması, token tüketim ölçümü, hata oranı takibi
- **Gün 15–45:** Kontrollü pilot
  - Sadece belirli kullanıcı segmentinde açma (ör. seçili sürücüler)
  - Başarı metrikleri: çözüm süresi, kullanım oranı, memnuniyet
- **Gün 46–90:** Ölçekleme kararı
  - Fayda/maliyet analizi
  - En iyi 1–2 use-case’i kalıcı ürün özelliğine çevirme

### C) Bütçe ve Risk Yönetimi

- Kredi tek seferlik olduğu için aylık "hedef tüketim tavanı" belirlenmeli.
- Aylık bütçenin üstüne çıkmadan önce otomatik alarm (billing alert) kurulmalı.
- Prompt/yanıt cache stratejisi ile gereksiz çağrılar azaltılmalı.
- Üretimde kademeli rollout yapılmalı; ani tam açılım maliyet sıçratır.

### D) Başarı KPI'ları (Öneri)

- AI özelliği kullanım oranı (% aktif kullanıcı)
- Destek talebi çözüm süresinde azalma (%)
- Sürücü başına günlük net kazançta iyileşme (%)
- İptal oranı düşüşü (%)
- 1 faydalı AI yanıt başına maliyet (₺)

### E) Net Öneri

Önce tek bir yüksek etkili akışa (Sürücü AI Asistanı) odaklanıp 90 gün ölçümlü pilot yapmak en doğru yaklaşım olur. Kredi, doğru kurgulanırsa doğrudan operasyon verimliliğine ve kullanıcı memnuniyetine çevrilebilir.
