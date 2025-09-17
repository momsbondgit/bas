# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter web application called "BAS Rituals" - a social interaction platform featuring multiple "worlds" where users participate in confession-style messaging experiences with bot interactions. The app includes a comprehensive admin system for content management.

## Development Commands

### Core Flutter Commands
- **Build for web**: `flutter build web --release --web-renderer html`
- **Run in development**: `flutter run -d chrome`
- **Install dependencies**: `flutter pub get`
- **Run tests**: `flutter test`
- **Analyze code**: `flutter analyze`

### Project Setup
```bash
flutter pub get
flutter run -d chrome  # For development
```

## Architecture Overview

### Core Application Structure

**Main Entry Point**: `lib/main.dart`
- Firebase initialization with `firebase_options.dart`
- Material app with Google Fonts (Noto Sans)
- Route handling for main app, admin, and maintenance screens
- Global navigator key for programmatic navigation

**Key Services Layer**:
- **WorldService**: Manages multiple "worlds" (Girl/Guy Meets College) with different bot configurations
- **RitualQueueService**: Handles real-time messaging queue system with turn-based interactions
- **QueueService**: Local queue management with bot interactions (guarantees real user at position 3 with exactly 5 bots)
- **AdminService**: Authentication and session management for admin features
- **LocalStorageService**: Persistent storage using SharedPreferences

### World System Architecture

The app uses a multi-world system where each world has:
- **WorldConfig**: Configuration including bot tables, UI theming, character limits
- **Three bot tables**: Table 1 (chaotic/edgy), Table 2 (goofy/soft), Table 3 (balanced/mixed) personality types
- **World-specific**: Topic of day, modal copy, background colors, entry images

**World Files**:
- `lib/config/world_config.dart` - Base configuration model
- `lib/config/worlds/girl_meets_college_world.dart`
- `lib/config/worlds/guy_meets_college_world.dart`
- `lib/services/core/world_service.dart` - World management service

### Real-time Messaging System

**Ritual Queue System** (`lib/services/core/ritual_queue_service.dart`):
- Turn-based messaging with configurable durations
- Real-time state synchronization via Firestore streams
- User queue management with bot assignments
- Local user ID generation and persistence

**Message Flow**:
- Users join ritual queues for specific worlds
- Turn rotation system with configurable timing
- Bot interactions based on world personality tables
- Real-time typing indicators and message cards

### Admin System

**Comprehensive admin dashboard** with three main sections:

1. **Authentication** (`lib/services/admin/admin_service.dart`):
   - Session-based auth with 24-hour expiry
   - Credentials: username `hap`, password `happyman`
   - Persistent login state with session extension

2. **Content Management** (`lib/ui/widgets/admin/admin_posts_section.dart`):
   - Real-time post viewing, editing, and deletion
   - Admin post creation with world/floor selection
   - Announcement system with custom authors

3. **System Controls** (`lib/ui/widgets/admin/admin_system_controls_section.dart`):
   - Maintenance mode toggle with custom messages
   - Session timer controls
   - User analytics (Instagram IDs, phone numbers, returning users)
   - Data reset capabilities

### Firebase Integration

**Collections Used**:
- `ritual_queue/current` - Active queue state
- `ritual_messages` - Message history
- `posts` - User and admin posts
- `endings` - User submissions (analytics)
- `system/maintenance` - Maintenance mode status
- `returning_users` - User analytics

### UI Architecture

**Screen Structure**:
- `GeneralScreen` - Main application interface
- `AdminScreen` - Admin dashboard with sidebar navigation
- `MaintenanceScreen` - Displayed during system maintenance
- `AppInitializationWrapper` - Handles Firebase and app initialization

**Key UI Patterns**:
- Stream-based real-time updates throughout the app
- Responsive design with mobile/desktop considerations
- Card-based message display with reaction systems
- Modal dialogs for world access and admin actions

### State Management

**Approach**: Combination of:
- Flutter's built-in `setState` for local UI state
- Firestore streams for real-time data synchronization
- SharedPreferences for persistent local data
- StreamController for custom event management

### Testing & Quality

**Configuration**:
- Flutter lints enabled via `analysis_options.yaml`
- Test dependencies: `mocktail` for service mocking
- Basic widget test structure in `test/widget_test.dart`

**Deployment**:
- GitHub Actions workflow for web deployment
- Builds for GitHub Pages with HTML renderer
- Flutter 3.8.1 stable channel

## Important Implementation Details

### Queue Management System
The application uses two distinct queue systems:

1. **RitualQueueService** (`lib/services/core/ritual_queue_service.dart`):
   - Firebase-based real-time messaging queue
   - Turn-based messaging with 60-second turns
   - Handles real user interactions and message submission

2. **QueueService** (`lib/services/core/queue_service.dart`):
   - Local bot simulation and queue management
   - **Critical Feature**: Guarantees exactly 6 queue members (5 bots + 1 real user)
   - **User Positioning**: Real user is always placed at position 3 (index 2)
   - **World Capacity Enforcement**: Only creates queues when sufficient assigned bots are available
   - **Bug Fix**: Completely rewritten `_createInitialQueue()` method eliminates all-bot lobbies and removes fallback bot system

### Bot Assignment Logic
The `BotAssignmentService` manages bot personality assignment through a vibe check system:
- **3 A answers**: Table 1 (chaotic/edgy personalities)
- **0 A answers**: Table 2 (goofy/soft personalities)
- **1-2 A answers**: Table 3 (balanced/mixed personalities)

Assignment is persistent across sessions and tied to the current world's bot configurations.

### Critical Bug Fixes

#### World Rejection and Bot Assignment Storage Fix
**Problem**: Users rejected due to world capacity were experiencing inconsistent behavior:
- First attempt: Proper vibe check → world full popup (correct)
- On refresh: Skipped vibe check → placed in fallback world with placeholder bots (Alex, Casey, Jordan, Riley, Quinn)

**Root Cause**: Two separate issues:
1. **Data Overwrite**: `AuthService.createAccountForWorld()` was using `set()` without merge, overwriting bot assignment data stored by `BotAssignmentService`
2. **Fallback Bot System**: `QueueService` created placeholder bots when insufficient assigned bots were available

**Solution Implemented**:
1. **Authentication Flow Reordering**: Bot availability is now checked BEFORE account creation in `general_screen.dart`
2. **Data Preservation**: `AuthService._createAccountInternal()` now uses `SetOptions(merge: true)` to preserve existing bot assignments
3. **Fallback System Removal**: Completely removed fallback bot creation logic from `QueueService`
4. **Consistent Rejection Handling**: Rejected users have no persistent account and must retry vibe check on refresh

**Result**: Rejected users now consistently experience: vibe check → capacity check → Instagram modal (no bypass, no placeholder bots).

### Real-time Features
Most UI components use Firestore streams for live updates. Always dispose stream subscriptions properly in `dispose()` methods.

### World Configuration
When adding new worlds, ensure all required fields in `WorldConfig` are provided and bot tables don't contain duplicate bot IDs.

### Admin Security
Admin credentials are currently hardcoded. The system uses session-based authentication with automatic expiry and extension capabilities.

### Firebase Setup
The app requires Firebase configuration via `firebase_options.dart`. Ensure Firestore security rules allow appropriate read/write access for the collections used.