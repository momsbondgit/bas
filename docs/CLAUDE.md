# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Flutter Commands
- `flutter run` - Run the app in development
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter test` - Run Flutter tests
- `flutter analyze` - Run static analysis

### Firebase/Backend Testing
- `npm test` - Run Firebase security rules tests
- `npm run emulators:start` - Start Firebase emulators
- `npm run emulators:test` - Run tests against emulators

## Architecture Overview

This is a Flutter app called "BAS Rituals" - a social experience app with two college-themed worlds where users participate in ritual-based interactions.

### Core Architecture Pattern
- **MVVM Pattern**: Uses ViewModels extensively (`lib/view_models/`) 
- **Service Layer**: Services handle business logic (`lib/services/`)
- **Firebase Backend**: Uses Firestore for data persistence and Firebase Auth

### Key Directory Structure
```
lib/
├── config/          # World configurations and bot pools
├── models/          # Data models (user, message, queue state)
├── services/        # Business logic services
│   ├── auth/        # Authentication services
│   ├── core/        # Core app services (queue, world, ending)
│   ├── data/        # Data persistence services
│   ├── admin/       # Admin functionality
│   └── simulation/  # Bot simulation services
├── ui/
│   ├── screens/     # Main application screens
│   └── widgets/     # Reusable UI components
├── view_models/     # MVVM ViewModels
└── utils/          # Utility functions
```

### Key Components

**World System**: Two worlds configured in `lib/config/worlds/`
- Girl Meets College (`girl-meets-college`) - Access code: 789
- Guy Meets College (`guy-meets-college`) - Access code: 456
- World-specific authentication and bot pools
- Unique vibe sections and topic text per world

**Queue System**: Core feature managing user interactions through queues
- `QueueService` handles main queue logic and user positioning
- `RitualQueueService` handles ritual-specific message queuing
- Real users randomly positioned 3rd-6th in queue (never 1st/2nd)
- Queue prevents duplicate user entries
- Session timing based on 20-second universal reaction timer completion
- Session ends when 6th user posts and their 20-second reaction timer expires

**User Flow**:
1. `GeneralScreen` - World selection with access code authentication
2. `GameExperienceScreen` - Main ritual experience with queue interactions
3. `SessionEndScreen` - Contact collection (phone/Instagram individually)

**Admin System**: Complete admin interface accessible via `/admin` routes
- Authentication-protected admin screens
- System controls, post management, maintenance mode

**Recent Key Fixes**:
- Fixed session end timing to wait for reaction timer completion
- Implemented individual phone/Instagram submission to Firebase
- Fixed duplicate user queue entries
- Enhanced mobile keyboard handling
- Improved reaction system for real users
- Simplified timer system by removing 60-second individual reaction timers
- Updated session end logic to use single 20-second universal reaction timer
- Fixed session end detection for 6th user completion

### Development Principles

**Simplicity First**: 
- Bare minimum implementations only
- No unnecessary abstractions or third-party dependencies
- Aggressive simplification - delete redundant/complex code

**Confirmation Protocol**:
- State implementation plan before coding each step
- Wait for explicit "Approved" confirmation
- Include files, functions, exclusions, and test cases in plan
- Question unclear requirements rather than making assumptions

**MVVM Compliance**:
- Follow existing MVVM pattern
- ViewModels handle business logic
- Services handle data operations
- UI components stay simple

### Firebase Integration
- Uses Firebase Core, Firestore, and Authentication
- Security rules testing framework included
- Local emulator support for development

### Key Services
- `AuthService` - User authentication and world-specific account creation
- `WorldService` - World configuration management and access validation
- `QueueService` - Main queue logic, user positioning, and state management
- `RitualQueueService` - Ritual-specific message queue management
- `PostService` - Message/post operations and content management
- `LocalStorageService` - Device storage for user preferences
- `EndingService` - Session end contact collection (now optional gender data)
- `ReactionSimulationService` - Bot reaction simulation with realistic delays

### UI/UX Features
- Clean slide transition animations for session end screen
- Mobile-responsive keyboard handling with proper scrolling
- Individual contact method submission (phone vs Instagram)
- Non-breaking spaces to prevent text wrapping in vibe rules
- Immediate reaction feedback for real users vs delayed for bots
- Responsive spacing adjustments for better visual hierarchy

### Testing
- Flutter test framework for unit tests
- Mocktail for service mocking
- Firebase rules unit testing setup
- Queue logic testing for user positioning and duplicate prevention