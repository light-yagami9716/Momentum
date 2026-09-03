<div align="center">
  <img src="momentum/docs/screens/home-light.png" alt="Momentum — Today screen" width="280" />
  <img src="momentum/docs/screens/stats-light.png" alt="Momentum — Statistics screen" width="280" />
  <img src="momentum/docs/screens/home-dark.png" alt="Momentum — Dark mode" width="280" />
</div>

# 📱 Momentum — Habit Tracker

> A clean, motivating habit tracker that turns small daily actions into lasting streaks. Built with **Flutter** as a semester project — **offline-first: no accounts, no servers, no tracking.**

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Provider-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Provider" />
  <img src="https://img.shields.io/badge/Offline--first-34D058?style=flat-square" alt="Offline-first" />
</p>

## 🔗 Live Demo

🚧 **Coming soon** — the app runs on Android, iOS, and web (`flutter run -d chrome`); a hosted web build can be deployed with `flutter build web`.

## 📖 Overview

Momentum helps you build habits through small, daily check-ins and streaks that encourage consistency without punishing a single slip. Everything lives on your device — data survives restarts via **SharedPreferences**, and reminders fire locally.

## ✨ Features

- **🗂️ Habit management** — create, edit, archive, and delete habits (name, icon, colour, frequency), with a validated form, duplicate-name detection, and live preview
- **✅ Daily check-in** — a today-focused home screen with one-tap completion and a rest-day section
- **🔥 Streak tracking** — current & longest streaks counted on scheduled days only; one missed day is bridged so a single slip doesn't erase progress
- **📈 Progress visuals** — animated completion rings, a 7-day bar chart, and a month heatmap drawn with custom `CustomPainter` code
- **📊 Statistics dashboard** — total check-ins, 30-day completion rate, top streak, best habit, and per-habit rings
- **🔔 Reminders** — optional per-habit local notifications at times you choose
- **🌗 Light & dark themes**, a 3-page onboarding flow, and flexible settings (12/24-hour format, week start, restore archived habits, JSON export, full reset)

## 📸 Screenshots

| Today | Statistics | New Habit |
|---|---|---|
| <img src="momentum/docs/screens/home-light.png" width="250"/> | <img src="momentum/docs/screens/stats-light.png" width="250"/> | <img src="momentum/docs/screens/form-light.png" width="250"/> |

| Dark Mode | Onboarding | Settings |
|---|---|---|
| <img src="momentum/docs/screens/home-dark.png" width="250"/> | <img src="momentum/docs/screens/onboarding.png" width="250"/> | <img src="momentum/docs/screens/settings-dark.png" width="250"/> |

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter** (SDK 3.24+) | Cross-platform UI framework |
| **Provider** | State management (Habit / Theme / Settings providers) |
| **SharedPreferences** | Local persistence |
| **flutter_local_notifications** | Per-habit reminders |
| **CustomPainter** | Streak rings, bar chart, month heatmap |

## 📦 Dependencies

| Package | Version |
|---|---|
| `provider` | ^6.1.5+1 |
| `shared_preferences` | ^2.5.5 |
| `flutter_local_notifications` | ^22.3.0 |
| `timezone` | ^0.11.1 |
| `intl` | ^0.20.3 |
| `cupertino_icons` | ^1.0.8 |

**Dev dependencies:** `flutter_lints` ^6.0.0 · `flutter_test` (SDK)

Fonts: **Sora** & **Inter** (bundled as assets).

## 🚀 Run Locally

**Prerequisites:** Flutter SDK **3.24+** (Dart ^3.13.1) — [install guide](https://docs.flutter.dev/get-started/install)

```bash
# 1. Clone the repository
git clone https://github.com/rafidhasansydney/Momentum.git
cd Momentum/momentum

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run                 # on a device / emulator
flutter run -d chrome       # on the web
flutter run -t lib/preview.dart -d chrome   # seeded demo mode
```

**Testing & building:**

```bash
flutter test                        # unit tests (incl. the streak engine)
flutter build apk --release        # Android APK → build/app/outputs/flutter-apk/
flutter build web                  # web build → build/web/
```

## 🏗️ Architecture

Three layers under `lib/`:

```
lib/
├── main.dart / preview.dart / app.dart
├── core/        # constants, theme, utils
├── data/        # streak engine, models, services
├── state/       # Habit / Theme / Settings providers
└── ui/          # onboarding, home, habit form, statistics,
                 # settings, navigation, custom widgets
```

- The **streak engine** is written as pure functions and covered by unit tests
- Notifications sit behind an interface, with a no-op implementation for web/test

## 🎓 Course Concepts Covered

Multi-screen navigation (named routes, fade transitions, bottom nav) · forms & validation · Provider state management · SharedPreferences persistence · custom widgets (`StreakRing`, `WeekBarChart`, `MonthHeatmap`, `HabitCard`, …) · lists & scroll views
