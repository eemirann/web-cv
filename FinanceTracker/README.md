# Finans Takibi (Finance Tracker)

Basit bir kişisel finans takip uygulaması. SwiftUI + Swift Charts ile yazılmıştır,
iOS 17+ / iPhone 15 uyumludur. MVVM mimarisi kullanılır ve veriler `UserDefaults`
üzerinde saklanır (Core Data gerekmez).

## Özellikler

- Toplam gelir ve toplam borç girişi
- Günlük harcama ekleme (tutar, isteğe bağlı not, tarih)
- Otomatik kalan bakiye hesaplama: `kalan = gelir - borç - harcamalar toplamı`
- Harcamaların tablo/liste görünümü (kaydırarak silme)
- Swift Charts ile zaman içindeki bakiye değişim grafiği
- Alternatif senaryo simülatörü: günlük harcama tahmini girip projeksiyon bakiyeyi görme
- Negatif değer girişine karşı temel doğrulama/hata yönetimi
- Türkçe arayüz metinleri

## Proje Yapısı (MVVM)

```
FinanceTracker/
└── FinanceTracker/
    ├── App/
    │   └── FinanceTrackerApp.swift      # @main giriş noktası
    ├── Models/
    │   ├── Expense.swift                 # Harcama modeli (Codable)
    │   └── BalancePoint.swift            # Grafik için (tarih, bakiye) noktası
    ├── ViewModels/
    │   └── FinanceViewModel.swift        # İş mantığı, hesaplamalar, doğrulama
    ├── Views/
    │   ├── ContentView.swift             # TabView (Ana Sayfa / Harcamalar / Grafik / Senaryo)
    │   ├── HomeView.swift                # Gelir/borç girişi + özet kartları
    │   ├── AddExpenseView.swift          # Harcama ekleme formu (sheet)
    │   ├── ExpenseListView.swift         # Harcama tablosu/listesi
    │   ├── BalanceChartView.swift        # Swift Charts çizgi grafiği
    │   └── ScenarioView.swift            # Senaryo simülatörü
    ├── Persistence/
    │   └── PersistenceManager.swift      # UserDefaults tabanlı basit veri katmanı
    └── Utilities/
        └── Formatters.swift              # Para birimi (₺) ve tarih formatlayıcılar
```

## Xcode'da Kurulum

1. Xcode'u açın → **File ▸ New ▸ Project… ▸ iOS ▸ App**
   - Product Name: `FinanceTracker`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Minimum Deployments: **iOS 17**
2. Xcode varsayılan olarak `FinanceTrackerApp.swift` ve `ContentView.swift` dosyalarını
   oluşturur. Bu iki dosyayı silin (Move to Trash) — yerlerine bu depodaki
   dosyaları kullanacağız.
3. Xcode proje gezgininde (Project Navigator), sarı grup klasörleri olarak
   `App`, `Models`, `ViewModels`, `Views`, `Persistence`, `Utilities` gruplarını
   oluşturun (sağ tık ▸ New Group).
4. Bu depodaki `FinanceTracker/FinanceTracker/` altındaki her klasörün içeriğini,
   Xcode'daki aynı isimli gruba sürükleyip bırakın:
   - `App/FinanceTrackerApp.swift` → Xcode'daki **App** grubuna
   - `Models/Expense.swift`, `Models/BalancePoint.swift` → **Models** grubuna
   - `ViewModels/FinanceViewModel.swift` → **ViewModels** grubuna
   - `Views/*.swift` (6 dosya) → **Views** grubuna
   - `Persistence/PersistenceManager.swift` → **Persistence** grubuna
   - `Utilities/Formatters.swift` → **Utilities** grubuna
   - Dosyaları sürüklerken açılan pencerede **"Copy items if needed"** kutucuğunu
     işaretli bırakın ve hedef target olarak `FinanceTracker` seçili olduğundan
     emin olun.
5. **Swift Charts** framework'ü iOS SDK'sının bir parçasıdır (iOS 16+), ekstra bir
   paket kurulumu gerekmez — sadece `import Charts` yeterlidir.
6. Build target'ın **iOS 17.0** veya üzeri olduğundan emin olun
   (Project ▸ Target ▸ General ▸ Minimum Deployments).
7. Bir iPhone 15 simülatörü seçip ⌘R ile çalıştırın.

## Notlar

- Veriler cihazda `UserDefaults` ile saklanır; uygulama kapatılıp açıldığında
  gelir, borç ve harcama geçmişi korunur.
- Tüm giriş alanları negatif değerlere karşı doğrulanır; geçersiz bir değer
  girildiğinde kullanıcıya Türkçe bir hata mesajı gösterilir.
- Proje ileride Core Data'ya geçişe uygun şekilde `PersistenceManager` içinde
  izole edilmiştir; sadece bu dosya değiştirilerek depolama katmanı
  değiştirilebilir.
