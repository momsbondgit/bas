# Services Directory - CLAUDE.md

This directory contains service classes that handle business logic, external integrations, and data management for the BAS Rituals application.

## Directory Structure

### `admin/` - Admin System Services

#### `admin_service.dart`
**Purpose**: Handles admin authentication and session management.

**Key Features**:
- **Authentication**: Hardcoded credentials (username: 'hap', password: 'happyman')
- **Session Management**: Uses SharedPreferences for persistent login state
- **Methods**:
  - `login()`: Authenticate with username/password
  - `logout()`: Clear admin session
  - `isLoggedIn()`: Check authentication status

**Security Note**: Credentials are hardcoded and should be externalized for production.

#### `bot_settings_service.dart`
**Purpose**: Manages dynamic bot configuration through Firebase.

**Features**:
- Stream-based bot data retrieval for real-time updates
- Bot nickname, response, and goodbye message editing
- World and table-specific bot management
- Firebase integration for persistent bot configuration

**Methods**:
- `getBotStream()`: Real-time stream of bot configurations
- `updateBot()`: Update bot properties in Firebase
- `getBots()`: Fetch current bot configurations for a world/table

#### `maintenance_service.dart`
**Purpose**: Manages system maintenance mode and global settings.

**Features**:
- Toggle maintenance mode with custom messages
- Real-time status streams for UI updates
- Firebase integration for persistent maintenance state
- Global system control

**Methods**:
- `setMaintenanceMode()`: Enable/disable with optional message
- `getMaintenanceStream()`: Real-time maintenance status
- `checkMaintenanceStatus()`: One-time status check

#### `topic_settings_service.dart`
**Purpose**: Manages world-specific daily topics.

**Features**:
- Dynamic topic management per world
- Firebase persistence for topics
- Integration with WorldService for dynamic loading

**Methods**:
- `getTopic()`: Fetch current topic for a world
- `setTopic()`: Update topic for a world
- `getTopicStream()`: Real-time topic updates

### `auth/` - Authentication Services

#### `auth_service.dart`
**Purpose**: Handles user authentication, session management, and metrics tracking.

**Features**:
- Anonymous user ID generation
- Access code validation for world entry
- Nickname management
- World authentication tracking
- Session persistence across app launches
- **Metrics Tracking**:
  - `incrementTotalSessions()`: Tracks game session starts
  - `incrementSessionsCompleted()`: Tracks session completions
  - `incrementReactionsGiven()`: Tracks reaction button clicks
  - Generic `_incrementMetric()` for code reuse
- **Firebase Optimization**: Uses `set` with `merge` to avoid reads before writes
- **Bot Assignment Preservation**: Account creation uses `SetOptions(merge: true)` to preserve existing bot assignment data

**Critical Methods**:
- `createAccountForWorld()`: Creates user account with merge option
- `checkAccessCode()`: Validates world access codes
- `getCurrentWorld()`: Gets user's current world
- `setVibeCheckAnswers()`: Stores vibe quiz responses

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
- `_startTurnTimer()`: Manage turn timing
- `_rotateQueue()`: Handle queue rotation logic

**State Management**:
- Uses `RitualQueueState` model for queue state
- StreamController for broadcasting state changes
- Timer management for turn rotation

#### `queue_service.dart`
**Purpose**: Local queue management with bot simulation and interaction.

**Key Responsibilities**:
- **Bot Queue Management**: Creates and manages local queues with bot users
- **User Positioning**: Guarantees real user is always at position 3 (index 2) in queue
- **Bot Assignment Integration**: Works with BotAssignmentService for personality-based bot selection
- **World Capacity Enforcement**: Prevents queue creation when insufficient assigned bots are available
- **Turn Management**: Handles bot turn rotation and timing
- **Response Generation**: Manages bot responses and interactions

**Critical Methods**:
- `_createInitialQueue()`: Guarantees exactly 6 queue members (5 bots + 1 real user)
- `_getBotResponse()`: Generates bot responses using only assigned bots
- `moveToNextUser()`: Rotates queue to next user's turn
- `_startTurnManagement()`: Manages turn timing
- `_startTypingSimulation()`: Simulates bot typing behavior

**Bug Fix Details**:
- Completely removed fallback bot system (no more placeholder bots)
- Only creates queues when sufficient assigned bots are available
- Deterministic queue building with real user at position 3

#### `world_service.dart`
**Purpose**: Manages world configurations and selection.

**Features**:
- World configuration loading and validation
- Dynamic bot and topic loading from Firebase
- World selection by ID or display name
- Default world handling
- World metadata and summary generation

**Methods**:
- `getWorldByIdAsync()`: Load world with dynamic data
- `getAllWorlds()`: Get list of available worlds
- `worldExists()`: Check if world exists
- `isValidWorldConfig()`: Validate world configuration

#### `ending_service.dart`
**Purpose**: Handles user submission endpoints (Instagram, phone numbers, goodbye messages).

**Features**:
- Instagram handle collection
- Phone number collection
- Goodbye message submission
- Analytics tracking for endings

**Methods**:
- `submitInstagram()`: Store Instagram handle
- `submitPhoneNumber()`: Store phone number
- `submitGoodbyeMessage()`: Store farewell message
- `getEndingsStream()`: Real-time endings updates

### `data/` - Data Management Services

#### `local_storage_service.dart`
**Purpose**: Centralized local storage management using SharedPreferences.

**Key Storage Areas**:
- **User Data**: Floor, world, table ID, vibe answers, assigned bots
- **Auth Data**: Anonymous ID, access codes, nicknames, authentication state
- **Ritual Data**: User ID and display name for ritual queue
- **Session Data**: Visit tracking, session counts

**Pattern**: All keys are static constants with descriptive names and category prefixes.

**Methods**:
- Getters/setters for all data types
- Null-safe retrieval with default values
- Async operations with proper error handling
- Clear methods for data cleanup

#### `post_service.dart`
**Purpose**: Handles post creation and management for confessions.

**Features**:
- Regular user post creation with validation
- Admin post creation with special privileges
- Post editing and deletion (admin features)
- Firestore integration with proper error handling
- World-specific post filtering

**Methods**:
- `createPost()`: Create user confession
- `createAdminPost()`: Create admin announcement
- `editPost()`: Update existing post
- `deletePost()`: Remove post
- `getPostsStream()`: Real-time post updates

### `metrics/` - Metrics and Analytics Services

#### `metrics_service.dart`
**Purpose**: Calculates and aggregates user engagement metrics for admin dashboard.

**Key Features**:
- **Real User Filtering**: Excludes bot users via `isBot` field check
- **Simplified Data Sources**: Reads from accounts collection primarily (optimized for performance)
- **Four Compass Metrics**:
  - **North (Belonging)**: Uses `worldVisitCount` field to calculate returns
  - **East (Flow)**: Reads `sessionsCompleted` and `totalSessions` fields
  - **South (Voice)**: Counts posts from posts collection
  - **West (Affection)**: Reads `reactionsGiven` field from accounts
- **Status Determination**: Assigns user status (Active/Returning/Completed)
- **Goodbye Message Tracking**: Retrieves optional farewell messages from user accounts

**Data Sources** (optimized):
- `accounts` collection: User data, visit counts, sessions, reactions (primary)
- `posts` collection: User-created posts (secondary)

**Methods**:
- `getUserCompassMetrics()`: Returns comprehensive metrics for all real users
- Performance optimized to reduce collection reads

### `simulation/` - Bot and Simulation Services

#### `bot_assignment_service.dart`
**Purpose**: Manages bot assignment and personality selection based on vibe check.

**Logic**:
- Assigns bots from world configuration bot tables based on vibe check answers:
  - **3 A answers**: Table 1 (chaotic/edgy personalities)
  - **0 A answers (3 B's)**: Table 2 (goofy/soft personalities)
  - **Mixed answers (1-2 A's)**: Table 3 (balanced personalities from both tables)
- Ensures unique bot assignments per session
- Stores assignments in local storage for persistence

**Methods**:
- `assignBotsBasedOnVibeCheck()`: Main assignment logic
- `getAssignedBots()`: Retrieve current assignments
- `clearAssignedBots()`: Reset bot assignments
- `_getBotsForTable()`: Helper for table selection

#### `reaction_simulation_service.dart`
**Purpose**: Simulates bot reactions to messages for realistic interactions.

**Features**:
- **Automatic Reaction Generation**: Creates realistic bot reactions to user messages
- **Balanced Distribution**: Ensures varied reaction types with guaranteed minimum representation
- **Content-Aware Weighting**: Adjusts reaction probabilities based on message sentiment
- **Realistic Timing**: First reaction after 6 seconds, subsequent reactions every 1.5 seconds
- **Reaction Types & Weights**:
  - "LMFAOOO 😭" (34%)
  - "so real 💅" (33%)
  - "nah that's wild 💀" (33%)

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
- Merge options to preserve existing data

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
await QueueService().initialize();
```

## Critical Service Dependencies

### Service Interaction Flow
1. **AuthService** → Manages user identity
2. **LocalStorageService** → Persists user data
3. **WorldService** → Provides world configurations
4. **BotAssignmentService** → Assigns bots based on vibe check
5. **RitualQueueService** → Orchestrates main experience
6. **QueueService** → Manages local bot queue

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
5. Consider initialization requirements

### Firebase Integration
- Always validate input before Firebase operations
- Use server timestamps for consistent timing
- Implement proper error handling
- Consider offline scenarios
- Use merge options when updating existing documents

### State Management
- Keep service state immutable where possible
- Use streams for real-time updates
- Persist critical state to local storage
- Handle service initialization properly
- Clean up resources in disposal methods

### Testing Considerations
- Services are designed for unit testing with mocking
- Use `mocktail` for service mocking (already included in dependencies)
- Test error conditions and edge cases
- Mock Firebase operations for isolated testing
- Test initialization and cleanup logic