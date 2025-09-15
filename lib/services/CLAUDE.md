# Services Directory - CLAUDE.md

This directory contains service classes that handle business logic, external integrations, and data management for the BAS Rituals application.

## Directory Structure

### `admin/` - Admin System Services

#### `admin_service.dart`
**Purpose**: Handles admin authentication and session management.

**Key Features**:
- **Authentication**: Hardcoded credentials (username: 'hap', password: 'happyman')
- **Session Management**: 24-hour session duration with automatic expiry
- **Persistence**: Uses SharedPreferences for session state
- **Methods**: `login()`, `logout()`, `isLoggedIn()`, `extendSession()`, `getRemainingSessionMinutes()`

**Security Note**: Credentials are hardcoded and should be externalized for production.

#### `maintenance_service.dart`
**Purpose**: Manages system maintenance mode and session timers.

**Features**:
- Toggle maintenance mode with custom messages
- Session timer management (start, extend, check remaining time)
- Real-time status streams for UI updates
- Firebase integration for persistent maintenance state



### `auth/` - Authentication Services

#### `auth_service.dart`
**Purpose**: Handles user authentication and session management.

**Features**:
- Anonymous user ID generation
- Access code validation for world entry
- Nickname management
- World authentication tracking
- Session persistence across app launches

### `core/` - Core Business Logic Services

#### `ritual_queue_service.dart`
**Purpose**: Main service for the ritual queue system - the heart of the messaging experience.

**Key Responsibilities**:
- **Queue Management**: User queue creation, rotation, and state management
- **Turn Management**: Timer-based turn rotation with 60-second turns
- **Message Handling**: Message submission, storage, and retrieval
- **Real-time Updates**: Firestore streams for live queue state updates
- **User Integration**: Local storage for user persistence

**Critical Methods**:
- `initialize()`: Set up queue service and user ID
- `joinQueue()`: Add user to ritual queue
- `submitMessage()`: Handle message submission and queue rotation
- `leaveQueue()`: Remove user from queue

#### `queue_service.dart`
**Purpose**: Local queue management with bot simulation and interaction.

**Key Responsibilities**:
- **Bot Queue Management**: Creates and manages local queues with bot users
- **User Positioning**: Guarantees real user is always at position 3 (index 2) in queue
- **Bot Assignment Integration**: Works with BotAssignmentService for personality-based bot selection
- **Fallback System**: Creates fallback bots when insufficient assigned bots are available
- **Turn Management**: Handles bot turn rotation and timing
- **Response Generation**: Manages bot responses and interactions

**Critical Methods**:
- `_createInitialQueue()`: **Recently fixed** - Guarantees exactly 6 queue members (5 bots + 1 real user)
- `_createFallbackBot()`: Creates generic bots when needed to fill queue
- `_getBotResponse()`: Generates bot responses including fallback bot handling
- `moveToNextUser()`: Rotates queue to next user's turn

**Bug Fix Details**:
The `_createInitialQueue()` method was completely rewritten to eliminate the bug where users could get all-bot lobbies. The new implementation:
- Deterministically builds a 6-person queue
- Places real user at exactly position 3 (index 2)
- Fills remaining positions with bots (assigned or fallback)
- Ensures first person (index 0) is always active
- Handles edge cases with insufficient bot assignments

#### `world_service.dart`
**Purpose**: Manages world configurations and selection.

**Features**:
- World configuration loading and validation
- World selection by ID or display name
- Default world handling
- World metadata and summary generation

#### `ending_service.dart`
**Purpose**: Handles user submission endpoints (Instagram, phone numbers).

### `data/` - Data Management Services

#### `local_storage_service.dart`
**Purpose**: Centralized local storage management using SharedPreferences.

**Key Storage Areas**:
- **User Data**: Floor, world, table ID, vibe answers, assigned bots
- **Auth Data**: Anonymous ID, access codes, nicknames, authentication state
- **Ritual Data**: User ID and display name for ritual queue
- **Session Data**: Visit tracking, session counts

**Pattern**: All keys are static constants with descriptive names and category prefixes.

#### `post_service.dart`
**Purpose**: Handles post creation and management for confessions.

**Features**:
- Regular user post creation with validation
- Admin post creation with special privileges
- Post editing and deletion (admin features)
- Firestore integration with proper error handling

### `simulation/` - Bot and Simulation Services

#### `bot_assignment_service.dart`
**Purpose**: Manages bot assignment and personality selection.

**Logic**:
- Assigns bots from world configuration bot tables based on vibe check answers
- **Pure A answers (3 A's)**: Table 1 (chaotic/edgy personalities)
- **Pure B answers (3 B's)**: Table 2 (goofy/soft personalities)
- **Mixed answers (1A/2B or 2A/1B)**: Table 3 (balanced/mixed personalities)
- Ensures unique bot assignments per session

#### `reaction_simulation_service.dart`
**Purpose**: Simulates bot reactions to messages for realistic interactions.

**Features**:
- **Automatic Reaction Generation**: Creates realistic bot reactions to user messages
- **Balanced Distribution**: Ensures varied reaction types with guaranteed minimum representation
- **Content-Aware Weighting**: Adjusts reaction probabilities based on message sentiment
- **Realistic Timing**: First reaction after 6 seconds, subsequent reactions every 1.5 seconds
- **Reaction Weights**: LMFAOOO 😭 (34%), so real 💅 (33%), nah that's wild 💀 (33%)

**Key Methods**:
- `simulateReactionsForPost()`: Main method to trigger reaction simulation
- `_generateDistributedReactions()`: Ensures each reaction type appears at least once for 3+ reactions
- `_selectWeightedReaction()`: Content-based reaction selection with sentiment analysis
- `stopSimulationForPost()`: Cancels ongoing reaction timers for specific posts

## Key Patterns

### Singleton Pattern
Most services use singleton pattern for global access:
```dart
class ServiceName {
  static final ServiceName _instance = ServiceName._internal();
  factory ServiceName() => _instance;
  ServiceName._internal();
}
```

### Firebase Integration Pattern
Services that interact with Firebase follow consistent patterns:
- Error handling with try-catch blocks
- Validation before Firebase operations
- Server timestamps for consistent timing
- Stream-based real-time updates

### Local Storage Pattern
All local storage goes through `LocalStorageService`:
- Static key constants with descriptive names
- Category prefixes (auth., user., ritual., session.)
- Null-safe retrieval with default values
- Async operations with proper error handling

### Service Initialization Pattern
Core services require initialization:
```dart
await RitualQueueService().initialize();
```

## Critical Service Dependencies

### Service Interaction Flow
1. **AuthService** → Manages user identity
2. **LocalStorageService** → Persists user data
3. **WorldService** → Provides world configurations
4. **RitualQueueService** → Orchestrates main experience
5. **BotAssignmentService** → Enhances with bot interactions

### Real-time Data Flow
- Firebase streams provide real-time updates
- Services emit state changes through StreamControllers
- UI components subscribe to service streams
- Local storage maintains offline state

## Development Guidelines

### Adding New Services
1. Follow singleton pattern for global services
2. Use dependency injection for testable services
3. Implement proper error handling and validation
4. Add comprehensive documentation for public methods

### Firebase Integration
- Always validate input before Firebase operations
- Use server timestamps for consistent timing
- Implement proper error handling
- Consider offline scenarios

### State Management
- Keep service state immutable where possible
- Use streams for real-time updates
- Persist critical state to local storage
- Handle service initialization properly

### Testing Considerations
- Services are designed for unit testing with mocking
- Use `mocktail` for service mocking (already included in dependencies)
- Test error conditions and edge cases
- Mock Firebase operations for isolated testing