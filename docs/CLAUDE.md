# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BAS Rituals is a Flutter mobile application with Firebase backend integration for anonymous social interactions. The app features real-time presence tracking, post management, and administrative controls with maintenance mode capabilities.

## Development Commands

### Flutter Commands
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build Android APK
- `flutter test` - Run Flutter unit/widget tests
- `flutter analyze` - Static analysis and linting
- `flutter pub get` - Install dependencies
- `flutter clean` - Clean build files

### Firebase Testing & Emulation
- `npm test` - Run Firebase security rules tests
- `firebase emulators:start` - Start Firebase emulators (Firestore on port 8080, Auth on port 9099, UI on port 4000)
- `firebase emulators:exec --only firestore,auth 'npm test'` - Run tests against emulators

## Architecture

### Flutter App Structure
```
lib/
├── main.dart                    # App entry point with Firebase initialization
├── firebase_options.dart       # Firebase configuration
├── services/                   # Business logic services
│   ├── admin_service.dart      # Admin authentication & operations
│   ├── ending_service.dart     # Session management
│   ├── local_storage_service.dart  # SharedPreferences wrapper
│   ├── maintenance_service.dart    # App maintenance mode
│   ├── post_service.dart       # Firestore post operations
│   └── presence_service.dart   # Real-time presence tracking
├── ui/
│   ├── screens/               # Full-screen views
│   └── widgets/               # Reusable UI components
├── view_models/               # State management
└── utils/                     # Utility functions
```

### Key Services Integration
- **Firebase Core**: Initialized in main.dart with platform-specific options
- **Cloud Firestore**: Real-time database for posts and presence data
- **SharedPreferences**: Local storage for user preferences and session data
- **Maintenance Mode**: Global app state control through MaintenanceService

### Navigation Structure
- `/` - App initialization wrapper
- `/app` - Floor picker (main entry)
- `/maintenance` - Maintenance mode screen
- `/admin` - Admin login
- `/admin/dashboard` - Admin dashboard
- All `/admin/*` routes redirect to AdminScreen with built-in authentication

### Firebase Configuration
- Project ID: basv2-9c201
- Firestore rules: `backend/firestore.rules`
- Security rules testing: `backend/rules-test.js`

## State Management Pattern

The app uses a service-based architecture with ViewModels for UI state:
- Services handle business logic and Firebase integration
- ViewModels manage screen-specific state using ChangeNotifier
- Global state (maintenance mode) handled through dedicated listeners

## Testing

- Widget tests: `test/widget_test.dart`
- Firebase rules tests: Backend security rules testing via Node.js
- Use Flutter's built-in testing framework for unit/widget tests
- Firebase emulators required for integration testing