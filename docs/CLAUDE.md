# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is "BAS Rituals" - a Flutter app with Firebase backend that appears to be a social platform where users can post content on different "floors" and includes an admin panel for content management and system controls.

## Commands

### Development
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build Android APK
- `flutter build web` - Build for web platform
- `flutter pub get` - Install dependencies
- `flutter analyze` - Run static analysis
- `flutter test` - Run unit tests

### Firebase Testing
- `npm test` - Run Firebase security rules tests
- `npm run emulators:start` - Start Firebase emulators
- `npm run emulators:test` - Run tests with emulators

## Architecture

### Main Application Structure
- Entry point: `lib/main.dart` - Initializes Firebase, sets up routing, and implements global maintenance monitoring
- Firebase configuration: `firebase_options.dart` (auto-generated)
- Firebase project: `basv2-9c201`
- Global maintenance listener: `GlobalMaintenanceListener` wraps the app for real-time maintenance mode switching

### Screen Navigation Flow
- Root route (`/`) → `AppInitializationWrapper` (handles app state initialization)
- Main app (`/app`) → `FloorPickerScreen` (main user interface)
- Admin routes (`/admin/*`) → Protected admin interface with authentication
- Maintenance mode → `MaintenanceScreen` (users redirected here when maintenance is enabled)

### Directory Structure
- `lib/services/` - Business logic and data services
  - `admin_service.dart`, `post_service.dart`, `maintenance_service.dart`, `ending_service.dart`, etc.
- `lib/ui/screens/` - Full-screen UI components
- `lib/ui/widgets/` - Reusable UI components including `global_maintenance_listener.dart`
- `lib/view_models/` - State management and presentation logic
- `lib/utils/` - Utility functions and helpers

### Firebase Integration
- Firestore database for data persistence
- Firebase Auth for admin authentication
- Emulator support configured (ports: Auth 9099, Firestore 8080, UI 4000)
- Security rules testing setup in `package.json`
- Collections: `posts` (user posts), `endings` (phone numbers with gender/floor), `system` (maintenance status)

### Key Features
- Multi-floor content system (users can post to different "floors")
- Admin panel with post management and system controls
- Real-time maintenance mode functionality - admin can toggle maintenance and all users immediately see maintenance screen
- Phone number collection with floor and gender tracking
- Cross-platform support (Android, iOS, Web, macOS, Windows, Linux)

### Data Flow
- Users select floor → stored in LocalStorage
- Users select gender → stored in LocalStorage  
- Phone numbers saved to Firestore with floor and gender data
- Admin can view all submissions with associated floor and gender information

### Maintenance System
- Global maintenance listener monitors Firestore `system/maintenance` document
- When admin toggles maintenance mode, all users across the app immediately redirect to maintenance screen
- **Admin-aware navigation**: Admin users remain on their current screen when maintenance is toggled, while regular users experience normal maintenance mode behavior
- Uses MaterialApp's `navigatorKey` for reliable navigation context
- Both `GlobalMaintenanceListener` and `MaintenanceScreen` check admin authentication status before applying navigation changes
- Maintenance screen allows return to app when maintenance is disabled (for non-admin users only)

#### Maintenance System Implementation Notes
- **Problem Solved**: Originally, when admin users toggled maintenance mode from the admin panel, they would be redirected away from the admin screen to the user flow, disrupting their workflow
- **Root Cause**: Two separate navigation triggers were occurring:
  1. `GlobalMaintenanceListener` - wraps entire app and handles maintenance state changes
  2. `MaintenanceScreen` - has its own maintenance status listener that always redirected to `/app` when maintenance was disabled
- **Solution**: Implemented admin authentication checks in both components:
  - `GlobalMaintenanceListener._handleMaintenanceEnabled()` and `_handleMaintenanceDisabled()` now check `AdminService.isLoggedIn()` before applying navigation
  - `MaintenanceScreen._startMaintenanceStatusListener()` and `_startPeriodicCheck()` also check admin status before calling `_returnToApp()`
- **Debug Logging**: Added comprehensive debug prints with `[MAINTENANCE DEBUG]`, `[ADMIN DEBUG]`, and `[MAINTENANCE SCREEN DEBUG]` prefixes to track admin status checks and navigation decisions

### State Management Pattern
Uses a hybrid approach with ViewModels handling business logic and state, while services manage data persistence and external API calls. LocalStorage used for session data (floor, gender, posting status).