# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application called "BAS Rituals" - a real-time confession and reaction platform using Firebase for backend services. The app allows users to post confessions anonymously within timed sessions and react to other confessions with emojis.

## Architecture

The app follows an **MVVM (Model-View-ViewModel) pattern** with these key layers:
- **Views**: UI screens and widgets in `lib/ui/`
- **ViewModels**: Business logic in `lib/view_models/`
- **Services**: Data access and Firebase integration in `lib/services/`
- **Models**: Data structures defined in Firebase contract at `shared/contract/contract.v1.json`

### Core Components

- **Firebase Services**: Firestore for data, Firebase Auth for admin access
- **Multi-platform Support**: iOS, Android, Web, Windows, Linux, macOS
- **Real-time Features**: Live confession feeds, presence counters, maintenance mode
- **Admin Panel**: Session management, confession moderation, system controls

## Development Commands

### Flutter Development
```bash
# Install dependencies
flutter pub get

# Run the app in development mode
flutter run

# Build for different platforms
flutter build apk
flutter build ios
flutter build web
flutter build windows
flutter build linux
flutter build macos

# Run tests
flutter test

# Analyze code for issues
flutter analyze

# Check for outdated dependencies
flutter pub outdated
```

### Firebase Backend Testing
```bash
# Install backend testing dependencies
npm install

# Run Firebase security rules tests
npm test
# or
node backend/rules-test.js

# Start Firebase emulators for local development
firebase emulators:start

# Run tests against emulators
npm run emulators:test
```

## File Structure

- `lib/main.dart` - App entry point with routing configuration
- `lib/ui/screens/` - Main application screens (home, admin, maintenance)
- `lib/ui/widgets/` - Reusable UI components
- `lib/services/` - Firebase integration and business logic services
- `lib/view_models/` - MVVM view models for state management
- `shared/contract/` - Data contract definitions for Firebase collections
- `backend/` - Firebase security rules and testing

## Development Principles

**CRITICAL**: This project follows strict development principles defined in `docs/DEVELOPMENT_PRINCIPLES.md`:

1. **Bare minimum scope only** - Strip down requirements to essentials
2. **MVVM pattern, simplest possible** - Follow existing patterns, no extra layers
3. **No third-party dependencies** unless absolutely unavoidable
4. **Confirmation protocol required** - Must state plan and wait for "Approved" before coding

### Before Any Implementation:
- Read `docs/DEVELOPMENT_PRINCIPLES.md` thoroughly
- State exact files, functions, and scope for each step
- Wait for explicit "Approved" confirmation before proceeding
- Ask clarifying questions rather than making assumptions

## Data Model

The app uses Firebase Firestore with collections defined in `shared/contract/contract.v1.json`:
- **floors** - Different confession areas/topics
- **sessions** - Timed confession periods
- **confessions** - User submissions (one per user per session)
- **reactions** - Emoji responses to confessions
- **votes** - User choices during sessions

## Testing

- Flutter unit/widget tests in `test/` directory
- Firebase security rules tests in `backend/rules-test.js`
- Use Firebase emulators for local testing of backend rules