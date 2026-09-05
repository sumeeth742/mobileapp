# AI Mock Interview

Phases 1–3 establish the Flutter application shell, local session prototype,
Material 3 themes, Riverpod, interview setup, and a realistic interview-room flow.

## Architecture

The app uses feature-first presentation folders with shared core infrastructure:

```text
lib/
  app.dart                         # MaterialApp, theme and route registration
  main.dart                        # ProviderScope application entry point
  core/
    constants/app_routes.dart       # Typed route names
    theme/app_theme.dart            # Light and dark Material 3 theme definitions
  features/
    auth/presentation/auth_screen.dart
    interview/presentation/interview_screen.dart
    splash/presentation/splash_screen.dart
    home/presentation/home_screen.dart
  models/                           # Auth and interview setup models
  services/                         # Local and future API services
  repositories/                     # Repository abstractions and implementations
  providers/                        # Shared Riverpod providers
  widgets/                          # Phase 2: reusable widgets
```

The Phase 2 sign-in is a local prototype. The Flutter app automatically calls the
FastAPI backend when both `BACKEND_BASE_URL` and `DEV_AUTH_TOKEN` are supplied as
`--dart-define` values; otherwise it retains the deterministic demo repository
so the UI remains usable offline. The backend owns the LLM key and validates its
structured question response. Future phases add production Supabase JWTs,
PostgreSQL persistence, scoring reports, history, profile, and analytics.

The FastAPI service, its environment template, structured API contracts, and
local development instructions are in [`backend/`](backend/README.md).

## Run Flutter against the local backend

Start the API as described in `backend/README.md`, then use the Android emulator
host alias and the same development token from `backend/.env`:

```bash
flutter run \
  --dart-define=BACKEND_BASE_URL=http://10.0.2.2:8000 \
  --dart-define=DEV_AUTH_TOKEN=replace-with-a-long-local-development-token
```

For a physical phone, replace `10.0.2.2` with the LAN IP address of the machine
running FastAPI. Never put an LLM API key in a `--dart-define` value.

## Phase 1 dependencies

| Package | Version | Purpose |
| --- | --- | --- |
| `flutter_riverpod` | `^2.6.1` | Dependency injection and reactive state management. |
| `flutter_lints` | `^5.0.0` | Recommended static-analysis rules. |

## Run on Android

Install Flutter stable and Android Studio (including an Android SDK), then run:

```bash
flutter doctor
flutter create --platforms=android .
flutter pub get
flutter analyze
flutter test
flutter devices
flutter run
```

For an emulator, create one in **Android Studio → Device Manager**, start it, and
then run `flutter run`. For a physical phone, enable **Developer options** and
**USB debugging**, connect it by USB, confirm it appears in `flutter devices`,
and run `flutter run -d <device-id>`.
