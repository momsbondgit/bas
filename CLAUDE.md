# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BAS Rituals - A Flutter app with Firebase backend for a social platform where users post anonymous confessions on different "floors" (building levels), with admin management capabilities and session-based access control.

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
- `flutter build web` - Build for web deployment
- `flutter pub get` - Install dependencies
- `flutter analyze` - Static analysis
- `flutter test` - Run unit tests

### Firebase Testing
- `npm test` - Run Firebase security rules tests
- `npm run emulators:start` - Start Firebase emulators (Auth:9099, Firestore:8080, UI:4000)
- `npm run emulators:test` - Run tests with emulators

### Deployment
- GitHub Pages deployed from `gh-pages` branch
- Custom domain: `www.bas.today`
- Web builds require base href configuration for proper routing

## Architecture

### Core Application Flow
1. **FloorPickerScreen** - User selects building floor (1-4) and gender, saves to LocalStorage
2. **HomeScreen** - Main feed showing confession posts with session timer
3. **PostInput** - Loads user's floor/gender from LocalStorage for posting
4. **SessionEndScreen** - Appears when 1-minute timer expires

### Data Flow & State Management
- **LocalStorage** (`shared_preferences`): Floor, gender, posting status per session
- **ViewModels**: Handle business logic, state changes, Firebase streams
- **Services**: Data persistence, Firebase operations, maintenance monitoring
- **Critical**: PostInput must load user preferences from LocalStorage on initialization

### Firebase Integration
- **Project**: `basv2-9c201`
- **Collections**: 
  - `posts` (confessions with floor/gender/reactions)
  - `endings` (phone number collection)
  - `system` (maintenance status, session timers)
  - `presence_home` (live user count simulation)
- **Auth**: Admin authentication only
- **Rules**: Located in `backend/firestore.rules`

### Session & Timer System
- 1-minute session timer managed by `MaintenanceService`
- Real-time countdown displayed in UI
- Users redirected to `SessionEndScreen` when timer expires
- Timer state persisted in Firestore `system` collection

### Maintenance Mode Architecture
- **GlobalMaintenanceListener**: Wraps entire app, monitors maintenance status
- **Admin-aware navigation**: Admins stay on current screen during maintenance toggle
- **Real-time switching**: All users instantly see maintenance screen when enabled
- **Navigation context**: Uses `MaterialApp.navigatorKey` for global navigation control

### Admin System
- **Access**: Long-press on FloorPickerScreen header
- **Routes**: `/admin/*` with authentication protection
- **Capabilities**: Post management, system controls, maintenance toggle, phone number viewing
- **Separation**: Admin posts marked with `isAdminPost: true`, support custom authors

### Content Restriction Logic
- Users must post to see full feed (enforced by `hasPosted` LocalStorage flag)
- Non-posters see first post only, rest are blurred with overlay
- Reactions only available after posting
- Session-based restrictions reset when timer expires

### Key Components
- **ConfessionCard**: Displays posts with floor/gender attribution ("A girl From Freaky Floor 2")
- **PostInput**: Loads user's selected floor/gender from LocalStorage for accurate posting
- **StatusIndicator**: Shows timer countdown and simulated live viewer count
- **FloorButton**: Handles floor selection with visual feedback

### Common Issues & Solutions
- **Floor display problems**: Ensure PostInput loads preferences from LocalStorage correctly
- **Maintenance mode bugs**: Check admin authentication in both GlobalMaintenanceListener and MaintenanceScreen
- **Navigation issues**: Verify MaterialApp.navigatorKey usage for global navigation
- **Session state**: LocalStorage handles per-session data, Firestore handles persistent system state