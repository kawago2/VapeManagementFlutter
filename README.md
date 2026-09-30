# VapeCare

Aplikasi manajemen dan pemeliharaan perangkat vape pribadi yang dibangun menggunakan Flutter. Mendukung penyimpanan data lokal serta sinkronisasi database cloud Turso (libSQL).

---

## Fitur

- **Manajemen Baterai**: Pencatatan siklus isi ulang, indikator kesehatan baterai, dan pengurutan data otomatis.
- **Manajemen Liquid**: Pemantauan sisa volume botol, kadar nikotin, dan riwayat rasa.
- **Manajemen Tank & Coil**: Pelacakan masa pakai coil/kapas dan riwayat penggantian komponen.
- **Sinkronisasi Turso Database**: Sinkronisasi data dua arah (push dan pull) melalui REST API Turso, mendukung konfigurasi via file `.env` maupun input melalui antarmuka aplikasi.
- **Notifikasi**: Pengingat berkala untuk perawatan coil dan pergantian baterai.

---

## Spesifikasi Teknis

- **Framework**: Flutter (Dart SDK ^3.10.4)
- **State & Architecture**: Repository pattern dengan pemisahan business logic dan view.
- **Penyimpanan Lokal**: SharedPreferences
- **Database Cloud**: Turso / libSQL HTTP API
- **Notifikasi**: flutter_local_notifications

---

## Instalasi dan Menjalankan Aplikasi

### 1. Dependensi
Pastikan Flutter SDK telah terpasang di komputer Anda.

```bash
flutter pub get
```

### 2. Konfigurasi Environment (.env)
Salin contoh konfigurasi env:

```bash
cp .env.example .env
```

Sesuaikan nilai di dalam `.env`:

```env
TURSO_DATABASE_URL=https://<your-database-name>.turso.io
TURSO_AUTH_TOKEN=<your-turso-auth-token>
```

*Catatan: Konfigurasi token juga dapat diisi langsung di dalam menu pengaturan aplikasi jika tidak ingin menggunakan file `.env`.*

### 3. Menjalankan Aplikasi

Menjalankan pada simulator/perangkat:
```bash
flutter run --dart-define-from-file=.env
```

Build APK Android:
```bash
flutter build apk --release --dart-define-from-file=.env
```

Build iOS Simulator:
```bash
flutter build ios --simulator --no-codesign --dart-define-from-file=.env
```

---

## Struktur Folder

```text
lib/
├── models/         # Entity data model
├── repositories/   # Abstraksi dan implementasi data storage
├── screens/        # Komponen layout layar
├── services/       # Turso client, service notifikasi, dan config
├── theme/          # Konfigurasi tema dan warna
├── views/          # Tampilan per tab menu
└── widgets/        # Komponen UI reusable dan dialog
```

---

## Format Pesan Commit

Format pesan git commit yang digunakan pada repositori ini:

```text
[TYPE] (SCOPE) Deskripsi perubahan
```

Contoh:
- `[FEAT] (TURSO) Add support for env-based credentials`
- `[FIX] (IOS) Update deployment target to 15.0`
- `[CHORE] (DOCS) Update README file`
