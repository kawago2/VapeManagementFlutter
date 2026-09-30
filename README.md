# VapeCare

Aplikasi manajemen dan perawatan perlengkapan vape personal berbasis **Flutter**. Dirancang dengan arsitektur bersih (**Clean Architecture & SOLID principles**), mendukung penyimpanan lokal (**Offline-first / SharedPreferences**) serta sinkronisasi cloud dengan **Turso Database (libSQL)**.

---

## ✨ Fitur Utama

- **🔋 Manajemen Baterai**:
  - Pelacakan siklus pengisian, status kesehatan baterai, dan pengurutan terorganisir.
- **💧 Manajemen Liquid**:
  - Monitoring sisa kapasitas, level nikotin, rasa, dan estimasi waktu habis.
- **💨 Manajemen Setup Tank & Coil**:
  - Rekam pemakaian coil/kapas, status usia pakai, dan riwayat pergantian.
- **☁️ Sinkronisasi Turso Cloud (libSQL)**:
  - Dukungan database cloud terenkripsi via REST API Turso.
  - Opsi konfigurasi via environment file (`.env`) atau input langsung dari menu Cloud Sync di dalam aplikasi.
  - Dukungan auto-push saat perubahan data dan manual pull data terbaru dari cloud.
- **🔔 Notifikasi & Reminder**:
  - Pengingat pemeliharaan setup atau rotasi baterai via `flutter_local_notifications`.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Dart 3.x)
- **Architecture**: Clean Architecture & SOLID Principles (Repository Pattern, ViewModels / State Separation)
- **Local Storage**: `shared_preferences`
- **Cloud Database**: [Turso (libSQL)](https://turso.tech/) via HTTP / REST API
- **Styling & Icons**: Custom dark/modern aesthetic, Google Fonts, Cupertino Icons
- **Notifications**: `flutter_local_notifications`

---

## 🚀 Persiapan & Instalasi

### 1. Prasyarat
- Flutter SDK (>= 3.10.4)
- Android Studio / Xcode (jika build untuk iOS)
- CocoaPods (untuk iOS)

### 2. Clone & Install Dependencies
```bash
git clone https://github.com/username/VapeManagement.git
cd VapeManagement
flutter pub get
```

### 3. Konfigurasi Environment (Turso Cloud DB)
Salin template konfigurasi:
```bash
cp .env.example .env
```

Buka `.env` dan isi dengan kredensial Turso Database Anda:
```env
TURSO_DATABASE_URL=https://nama-db-anda.turso.io
TURSO_AUTH_TOKEN=eyJh...token_anda
```

> **Catatan**: File `.env` bersifat privat dan sudah di-ignore di `.gitignore`. Anda juga dapat mengosongkannya dan mengatur token langsung dari menu **Cloud Database** di aplikasi.

---

## 📱 Menjalankan Aplikasi

### Mode Debug (dengan konfigurasi `.env`)
```bash
flutter run --dart-define-from-file=.env
```

### Build APK Release (Android)
```bash
flutter build apk --release --dart-define-from-file=.env
```
File APK output berada di: `build/app/outputs/flutter-apk/app-release.apk`.

### Build iOS Simulator
```bash
flutter build ios --simulator --no-codesign --dart-define-from-file=.env
```

---

## 📂 Struktur Proyek

```text
lib/
├── models/         # Entity data & serialization (Tank, Battery, Liquid)
├── repositories/   # Data layer & abstraction (VapeRepository)
├── screens/        # Screen level composables & routes
├── services/       # Cloud sync (TursoClient), notifications & config
├── theme/          # Custom theme tokens & visual styling
├── views/          # UI tabs & page views
└── widgets/        # Reusable component widgets & bottom sheets
```

---

## 📝 Commit Convention

Repositori ini mengikuti format commit:
```text
[TYPE] (SCOPE) Pesan deskripsi commit
```
Contoh:
- `[FEAT] (TURSO) Support .env for database credentials`
- `[FIX] (IOS) Update deployment target to 15.0`
- `[CHORE] (DOCS) Update README with project details and build guides`
