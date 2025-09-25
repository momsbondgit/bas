# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter web application called "BAS Rituals" - a social interaction platform featuring a real-time lobby system where users coordinate and participate in confession-style messaging experiences together. The app includes a comprehensive admin system for content management and focuses on authentic user interactions through lobby-based coordination.

## Directory Structure

```
lib/
├── config/           # Configuration files and world definitions
├── models/           # Data models and entities
├── services/         # Business logic and external integrations
├── ui/              # User interface components
│   ├── screens/     # Full screen components
│   └── widgets/     # Reusable UI components
├── utils/           # Utility classes and helpers
├── view_models/     # MVVM pattern view models
└── main.dart        # Application entry point
```

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
- **AuthService**: Lobby management, user coordination, and authentication
- **WorldService**: Manages world configuration (focused on Girl Meets College)
- **QueueService**: Local queue management from lobby participants
- **PostService**: Real-time post streaming with lobby nickname integration
- **HomeViewModel**: Manages lobby-based queue state and Firebase post streaming
- **AdminService**: Authentication and session management for admin features
- **LocalStorageService**: Persistent storage using SharedPreferences

### World System Architecture

The app uses a single-world system focused on "Girl Meets College":
- **WorldConfig**: Configuration including UI theming, character limits, entry images
- **Simplified World Selection**: Only Girl Meets College world is active
- **World-specific**: Topic of day, modal copy, background colors
- **Lobby Integration**: World access directly launches lobby system

**World Files**:
- `lib/config/world_config.dart` - Base configuration model
- `lib/config/worlds/girl_meets_college_world.dart` - Active world config
- `lib/services/core/world_service.dart` - World management service

### Real-time Lobby and Messaging System

**Lobby System** (`lib/services/auth/auth_service.dart`):
- Multi-user real-time lobby coordination via Firebase
- Users join lobbies with nicknames and wait for others
- Real-time user list updates and lobby synchronization
- Lobby starter triggers game launch for all participants
- Firebase collections: `lobbies/{worldId}` with users, isStarted, activeUserIds

**Queue System** (`lib/services/core/queue_service.dart`):
- Creates local queues from lobby participant lists
- Turn-based rotation with 60-second turns
- Real-time queue state management and user coordination
- No bot assignment dependency - uses real lobby users only

**Message Flow**:
- Users enter lobby → wait for others → start together
- Local queue created from lobby participants
- Turn rotation system with real-time coordination
- Posts display with lobby nicknames as authors

### Admin System

**Comprehensive admin dashboard** with three main sections:

1. **Authentication** (`lib/services/admin/admin_service.dart`):
   - Session-based auth with 24-hour expiry
   - Credentials: username `hap`, password `happyman`
   - Persistent login state with session extension

2. **Content Management**:
   - **Posts Section** (`lib/ui/widgets/admin/admin_posts_section.dart`): Real-time post management
   - **Bot Settings** (`lib/ui/widgets/admin/admin_bot_settings_section.dart`): Dynamic bot configuration
   - **Topic Settings** (`lib/ui/widgets/admin/admin_topic_settings_section.dart`): World topic management
   - Admin post creation with world/floor selection
   - Announcement system with custom authors

3. **System Controls** (`lib/ui/widgets/admin/admin_system_controls_section.dart`):
   - Maintenance mode toggle with custom messages
   - Session timer controls
   - User analytics (Instagram IDs, phone numbers, returning users)
   - Data reset capabilities

### Firebase Integration

**Collections Used**:
- `lobbies/{worldId}` - Real-time lobby state with users and coordination
- `posts` - User posts with customAuthor field for lobby nicknames
- `accounts` - User metrics, session tracking, and analytics
- `endings` - User submissions (analytics)
- `system/maintenance` - Maintenance mode status
- `topics` - Dynamic topic settings per world
- `bots` - Dynamic bot configurations (for admin management)

**Real-time Streams**:
- Lobby user updates and synchronization
- Post streaming with world filtering
- Maintenance status monitoring
- Admin dashboard data streams

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

**Lobby UI Components**:
- **World Access Modal**: Real-time lobby system with user list and coordination
- **Lobby User List**: Live updates showing joined participants with nicknames
- **Synchronized Start Button**: Launches game experience for all lobby participants
- **Real-time Lobby Streams**: Firebase-powered user coordination and state synchronization

### State Management

**Approach**: Combination of:
- Flutter's built-in `setState` for local UI state
- Firestore streams for real-time data synchronization
- SharedPreferences for persistent local data
- StreamController for custom event management
- **View Models**: MVVM pattern implementation with ChangeNotifier for complex screens
  - `AdminViewModel` - Admin dashboard state management
  - `HomeViewModel` - Lobby-based queue management and Firebase post streaming
  - `RitualQueueViewModel` - Ritual queue experience state management (if used)

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
The application uses a simplified lobby-based queue system:

1. **QueueService** (`lib/services/core/queue_service.dart`):
   - Creates local queues from lobby participant lists
   - Turn-based rotation with 60-second turns per user
   - Uses real lobby users with their chosen nicknames
   - **Queue Initialization**: `initialize(lobbyUserIds, lobbyUserNicknames)` creates queue from lobby data
   - **Real User Integration**: Displays real users vs. dummy placeholders for lobby participants
   - **No Bot Dependency**: Queue creation based on actual lobby participants, not bot assignment

2. **HomeViewModel Queue Integration**:
   - Manages queue state updates and turn management
   - Handles real user posting and queue advancement
   - Universal reaction timer (30 seconds) after posts
   - Stream-based real-time queue state synchronization

### Post System with Lobby Integration
The `PostService` manages real user posts with lobby nickname integration:
- **Custom Author Support**: Posts display with lobby nicknames instead of generic user IDs
- **Firebase Posts Streaming**: Real-time post updates from other lobby participants
- **Local + Firebase Integration**: User posts stored locally and Firebase simultaneously
- **Reaction System**: Client-only reactions (no Firebase writes for performance)

**HomeViewModel Integration**:
- Separates user posts, local bot posts, and Firebase posts from other users
- Real-time lobby nickname display for post authors
- Stream-based Firebase post integration with world filtering

### Critical Bug Fixes

#### Lobby System Implementation
**Architecture**: Real-time multi-user coordination system replacing vibe check workflow:
- **Firebase Lobbies**: Collection `lobbies/{worldId}` stores active users and lobby state
- **Real-time Coordination**: Users join lobbies, see other participants in real-time
- **Synchronized Launch**: When one user clicks "Start", all lobby participants navigate together
- **Nickname Integration**: Lobby nicknames carry through to post authoring system

**Key Collections**:
1. **lobbies/{worldId}**: Contains `users` map (userId→nickname), `isStarted` boolean, `activeUserIds` array
2. **posts**: Enhanced with `customAuthor` field for lobby nicknames
3. **accounts**: User metrics and session tracking (no bot assignment data)

**Flow**: World selection → lobby join → wait for users → synchronized start → game experience with lobby participants

**Removed Systems**: Vibe check quiz, bot assignment service integration, world capacity restrictions

### Real-time Features
Most UI components use Firestore streams for live updates. Always dispose stream subscriptions properly in `dispose()` methods.

### World Configuration
When adding new worlds, ensure all required fields in `WorldConfig` are provided and bot tables don't contain duplicate bot IDs.

### Admin Security
Admin credentials are currently hardcoded. The system uses session-based authentication with automatic expiry and extension capabilities.

### Firebase Setup
The app requires Firebase configuration via `firebase_options.dart`. Ensure Firestore security rules allow appropriate read/write access for the collections used.

### View Model Pattern
The app uses MVVM architecture for complex screens:
- **HomeViewModel**: Manages lobby-based queue, local/Firebase posts, reaction timers
- **AdminViewModel**: Handles admin dashboard state and real-time data streams
- **RitualQueueViewModel**: Manages ritual queue experience (if still used)
- View models extend `ChangeNotifier` for state management
- Stream-based real-time updates with proper resource cleanup
- Integration with lobby system and Firebase post streaming

### Key Architectural Changes

#### Major Changes from Previous Implementation:
1. **Lobby System**: Replaced vibe check quiz with real-time multi-user lobbies
2. **Real User Focus**: Shifted from bot-heavy queues to real user coordination
3. **Firebase Streaming**: Enhanced post streaming with lobby nickname integration
4. **Simplified World System**: Focus on single world (Girl Meets College)
5. **MVVM Architecture**: Full implementation with HomeViewModel managing complex state

#### Removed/Deprecated Systems:
- Vibe check quiz and bot personality assignment
- Multi-world selection (Guy Meets College disabled)
- Bot-heavy queue systems with guaranteed positioning
- World capacity restrictions and rejection flows
- Instagram collection for rejected users

#### Current Service Architecture:
- **AuthService**: Core lobby management and user coordination
- **PostService**: Enhanced with customAuthor for lobby nicknames
- **HomeViewModel**: Central state management for lobby queues and posts
- **QueueService**: Simplified to handle lobby participant queues only