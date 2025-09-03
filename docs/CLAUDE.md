# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

**Flutter Development:**
- `flutter pub get` - Install dependencies
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build for Android
- `flutter analyze` - Static analysis and linting
- `flutter test` - Run all tests
- `flutter clean` - Clean build artifacts

**Firebase Development:**
- `npm test` - Run Firebase security rules tests (backend/rules-test.js)
- `firebase emulators:start` - Start Firebase emulators (Firestore on port 8080, Auth on port 9099, UI on port 4000)
- `npm run emulators:test` - Run security tests with Firebase emulators
- `npm run emulators:start` - Alternative command to start emulators

## Architecture Overview

**BAS Rituals App** - A Flutter Firebase app for ritual queue management with real-time messaging and presence tracking.

### Core Architecture
- **MVVM Pattern**: Strict Model-View-ViewModel with no extra abstractions
- **Firebase Backend**: Firestore for data, Firebase Auth for authentication
- **Real-time Features**: Ritual queue system with timed rotations, typing indicators, presence tracking

### Key Directory Structure
```
lib/
├── models/           # Data models (Message, QueueUser, RitualQueueState)
├── services/         # Business logic services 
├── view_models/      # MVVM view models
├── ui/
│   ├── screens/      # Main app screens
│   └── widgets/      # Reusable UI components
├── utils/           # Utilities (animations, accessibility)
└── config/          # App configuration
```

### Core Services
- **RitualQueueService**: Manages queue state, turn timers, and rotations
- **TypingIndicatorService**: Real-time typing status
- **PresenceService**: User presence tracking
- **AdminService**: Admin authentication and controls
- **MaintenanceService**: App-wide maintenance mode

### Key Features
- **Ritual Queue System**: Timed user rotations with configurable intervals
- **Real-time Messaging**: Message feed with reactions and typing indicators  
- **Admin Dashboard**: System controls, maintenance mode, post management
- **Presence Tracking**: Real-time user count display
- **Multi-platform**: Supports Android, iOS, Web, Windows, macOS

## Development Principles

**Critical**: Always read and follow `docs/DEVELOPMENT_PRINCIPLES.md` before making any changes:

1. **Bare minimum only** - Strip scope until it breaks, add back only what's necessary
2. **MVVM, simplest possible** - Follow existing MVVM pattern, no extra layers
3. **Confirm before coding** - State plan and wait for "Approved" before implementing
4. **No third-party dependencies** unless absolutely unavoidable

## Firebase Configuration

- Project ID: `basv2-9c201`
- Firestore rules: `backend/firestore.rules`
- Security rules testing via Node.js in `backend/`
- Emulators configured for local development

## Testing

- Widget tests in `test/widget_test.dart`
- Firebase security rules tests via npm scripts
- Use `mocktail` for service mocking

## Common Patterns

**Service Integration**: Services are injected into ViewModels, ViewModels are used by UI widgets
**State Management**: Primarily using StreamControllers and StreamBuilder widgets
**Firestore Collections**: `posts`, `system`, `endings`, `presence_home`, `ritual_queue`, `ritual_messages`, `typing_indicators`

## Backend Testing Structure

**Node.js Testing Setup** (package.json in root):
- Firebase security rules testing via `@firebase/rules-unit-testing`
- Test file: `backend/rules-test.js`
- Firebase emulators configuration in `firebase.json`

## Development Workflow Requirements

**Critical Process** from `docs/DEVELOPMENT_PRINCIPLES.md`:
1. **Confirmation Protocol**: For every code change, developer must state the plan with exact file paths, functions, data structures, and test cases, then wait for explicit "Approved" confirmation
2. **Questioning**: Always ask questions rather than making assumptions - no room for assumptions allowed
3. **Scope Minimization**: Strip scope until it breaks, add back only necessary functionality