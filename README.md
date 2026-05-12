 🌍 Global Temperature Globe Dashboard

Global Temperature Globe Dashboard, dünya genelindeki sıcaklık verilerini interaktif bir 3D küre ve dinamik grafikler aracılığıyla sunan gelişmiş bir veri görselleştirme projesidir. Bu çalışma, karmaşık mekansal verilerin (Geospatial Data) analiz edilerek kullanıcı dostu bir arayüzle sunulmasını hedefleyen bir **Yönetim Bilişim Sistemleri (YBS)** projesi olarak geliştirilmiştir.

---

 🚀 Canlı Demo
Uygulama yayına alınmıştır ve aşağıdaki bağlantı üzerinden anlık olarak incelenebilir:
👉 [https://cananpelinyildirim.shinyapps.io/cbsharita/]

---

📌 Projenin Amacı ve Kapsamı
Bu proje, küresel iklim verilerini sadece tablolarda bırakmak yerine, kullanıcıların etkileşim kurabileceği bir platforma dönüştürmeyi amaçlar. Proje kapsamında şu hedeflere ulaşılmıştır:
- Gerçek Veri Entegrasyonu: Kaggle tabanlı küresel hava durumu verileri işlenerek harita üzerinde anlamlı hale getirilmiştir.
- 3D Mekansal Görselleştirme: Verilerin küre (Orthographic) üzerinde sergilenmesiyle coğrafi bağlam güçlendirilmiştir.
- Dinamik Analitik: Seçilen ülkeye göre anlık güncellenen 2D grafiklerle uç değerlerin (en sıcak/en soğuk) tespiti kolaylaştırılmıştır.

 🛠 Teknik Mimari ve Teknoloji Yığını

 Kullanılan Teknolojiler
- Dil:R Programming
- Framework: Shiny (Web Application Framework for R)
- Görselleştirme: Plotly (Interactive Graphs & 3D Globe)
- Mekansal Veri İşleme: `sf` (Simple Features), `rnaturalearth` (Geography Data), `geojsonsf`
- Veri Manipülasyonu:`dplyr`, `tidyr` (Tidyverse)

### Temel Özellikler
1. İnteraktif 3D Küre: Kullanıcılar küreyi döndürebilir, yakınlaştırabilir ve ülkelerin üzerine gelerek anlık ortalama sıcaklık değerlerini görebilir.
2. Akıllı Veri Birleştirme (Data Joining): Dünya haritası geometrisi ile CSV dosyasındaki sıcaklık verileri `ISO-3` ülke kodları ve isim eşleştirmeleri üzerinden hatasız bir şekilde birleştirilmiştir.
3. Uç Değer Analizi (Top 5): Küresel ölçekte en sıcak ve en soğuk 5 ülke, yan yana sütun grafikleriyle (Grouped Bar Chart) karşılaştırmalı olarak sunulur.
4. Sıcaklık Dağılımı: Tüm veri setinin sıcaklık dağılımını gösteren bir histogram, seçilen ülkenin bu dağılımdaki yerini dikey bir çizgi ile vurgular.

## 📂 Veri Kaynağı ve İşleme
Projede kullanılan veriler `GlobalWeatherRepository.csv` dosyasından çekilmektedir. Veri işleme adımları:
- Veri seti ülke bazında gruplandırılarak sıcaklık ortalamaları (`mean`) hesaplanmıştır.
- Eksik veriler (`NA`) ve isim uyumsuzlukları (örn: USA/United States) kod seviyesinde normalize edilmiştir.
- Geometrik veriler, web tarayıcısı performansını artırmak amacıyla sadeleştirilmiştir (`st_simplify`).

## 💻 Yerel Çalıştırma Talimatları
Projeyi kendi bilgisayarınızda çalıştırmak için:
1. R ve RStudio'nun yüklü olduğundan emin olun.
2. Gerekli kütüphaneleri yükleyin:
   ```R
   install.packages(c("shiny", "plotly", "sf", "dplyr", "tidyr", "rnaturalearth", "geojsonsf"))


  #
  [Canan Pelin Yıldırım]
  İskenderun Teknik Üniversitesi/
  Yönetim Bilişim Sistemleri Bölümü
   
