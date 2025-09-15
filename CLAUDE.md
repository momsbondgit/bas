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

### Bot Assignment Logic
The `BotAssignmentService` manages bot personality assignment through a vibe check system:
- **3 A answers**: Table 1 (chaotic/edgy personalities)
- **0 A answers**: Table 2 (goofy/soft personalities)
- **1-2 A answers**: Table 3 (balanced/mixed personalities)

Assignment is persistent across sessions and tied to the current world's bot configurations.

### Real-time Features
Most UI components use Firestore streams for live updates. Always dispose stream subscriptions properly in `dispose()` methods.

### World Configuration
When adding new worlds, ensure all required fields in `WorldConfig` are provided and bot tables don't contain duplicate bot IDs.

### Admin Security
Admin credentials are currently hardcoded. The system uses session-based authentication with automatic expiry and extension capabilities.

### Firebase Setup
The app requires Firebase configuration via `firebase_options.dart`. Ensure Firestore security rules allow appropriate read/write access for the collections used.