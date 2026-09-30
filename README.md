# VapeCare (Flutter Hybrid)

A cross-platform personal vape device management and maintenance app built with **Flutter**. Supports on-device offline storage alongside cloud database synchronization via **Turso (libSQL)**.

---

## Features

- **Battery Management**: Track charging cycles, purchase history, and battery health degradation indicators.
- **E-Liquid Management**: Monitor remaining bottle volume, nicotine strength, and flavor history.
- **Tank & Coil Management**: Real-time coil and cotton lifespan tracking with component replacement logs.
- **Turso Database Synchronization**: Two-way data synchronization (push and pull) via the Turso REST API, configurable via `.env` or the in-app settings UI.
- **Local Notifications**: Automated scheduled reminders via background tasks when component lifespan thresholds are reached.

---

## Technical Specifications

- **Framework**: Flutter (Dart SDK ^3.10.4)
- **Target OS**: Android & iOS
- **Local Storage**: SharedPreferences / Local SQLite
- **Cloud Database**: Turso / libSQL HTTP API
- **Notifications**: `flutter_local_notifications`
- **Architecture**: Repository Pattern separating business logic and view layers

---

## Installation & Setup

### 1. Dependencies
Ensure the Flutter SDK is installed on your machine.

```bash
flutter pub get
```

### 2. Environment Configuration (.env)
Copy the example environment configuration:

```bash
cp .env.example .env
```

Configure your credentials inside `.env`:

```env
TURSO_DATABASE_URL=https://<your-database-name>.turso.io
TURSO_AUTH_TOKEN=<your-turso-auth-token>
```

*Note: Credentials can also be configured directly via the in-app settings menu.*

### 3. Build & Run the App

Run on a connected device / simulator:
```bash
flutter run --dart-define-from-file=.env
```

Build Android APK:
```bash
flutter build apk --release --dart-define-from-file=.env
```

Build iOS Simulator:
```bash
flutter build ios --simulator --no-codesign --dart-define-from-file=.env
```

---

## Directory Structure

```text
lib/
├── models/         # Entity data models
├── repositories/   # Data storage abstractions & implementations
├── screens/        # Screen-level views & dashboard layouts
├── services/       # Turso API client, notification service, and configs
├── theme/          # App theme and color palettes
├── views/          # Sub-tab views
└── widgets/        # Reusable UI cards, dialogs, and progress bars
```

---

## Git Commit Message Convention

Format used for commit messages:

```text
[TYPE] (SCOPE) Description of changes
```

Examples:
- `[FEAT] (TURSO) Add support for env-based credentials`
- `[FIX] (IOS) Update deployment target to 15.0`
- `[CHORE] (DOCS) Update README file`