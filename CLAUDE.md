# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BAS Rituals - A Flutter app with Firebase backend for a social platform where users post content on different "floors" with admin management capabilities.

## Critical Development Principles

**MUST READ**: All development follows strict principles defined in `docs/DEVELOPMENT_PRINCIPLES.md`:
- Bare minimum scope only - strip down until it breaks, add back what's necessary
- Follow existing MVVM pattern without extra layers
- **Confirmation required**: State plan, get "Approved" before coding each step
- No assumptions - always ask clarifying questions

## Commands

### Development
- `flutter run` - Run app in development
- `flutter build apk` - Build Android APK  
- `flutter build web` - Build for web
- `flutter pub get` - Install dependencies
- `flutter analyze` - Static analysis
- `flutter test` - Run unit tests

### Firebase Testing
- `npm test` - Run Firebase security rules tests
- `npm run emulators:start` - Start Firebase emulators
- `npm run emulators:test` - Run tests with emulators

## Architecture

### Entry Point & Navigation
- `lib/main.dart` - Firebase initialization, routing, global maintenance monitoring
- Firebase project: `basv2-9c201`
- `GlobalMaintenanceListener` wraps entire app for real-time maintenance switching
- Routes: `/` → `AppInitializationWrapper`, `/app` → `FloorPickerScreen`, `/admin/*` → protected admin interface

### MVVM Structure
- `lib/services/` - Data services and business logic
- `lib/view_models/` - State management and presentation logic
- `lib/ui/screens/` - Full-screen UI components  
- `lib/ui/widgets/` - Reusable components
- `lib/utils/` - Utility functions

### Firebase Integration
- Firestore collections: `posts`, `endings` (phone numbers), `system` (maintenance), `presence_home`
- Firebase Auth for admin authentication
- Emulator ports: Auth 9099, Firestore 8080, UI 4000
- Security rules: `backend/firestore.rules`

### Key Features
- Multi-floor content system with LocalStorage session data
- Real-time maintenance mode with admin-aware navigation
- Phone number collection with floor/gender tracking
- Cross-platform support (Android, iOS, Web, macOS, Windows, Linux)

### Maintenance System
- `GlobalMaintenanceListener` monitors `system/maintenance` Firestore document
- Admin users remain on current screen when toggling maintenance
- Regular users redirect to maintenance screen when enabled
- Admin authentication checks prevent admin workflow disruption

### Testing
- Firebase rules testing: `backend/rules-test.js`
- Widget tests: `test/widget_test.dart`
- Emulator configuration in `firebase.json`