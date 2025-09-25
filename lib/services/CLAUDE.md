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
**Purpose**: Handles user authentication, session management, and lobby coordination.

**Features**:
- Anonymous user ID generation and management
- **Lobby Management**: Real-time multi-user lobby coordination
- Nickname management and lobby integration
- Session persistence across app launches
- **Metrics Tracking**:
  - `incrementTotalSessions()`: Tracks game session starts
  - `incrementSessionsCompleted()`: Tracks session completions
  - `incrementReactionsGiven()`: Tracks reaction button clicks
  - Generic `_incrementMetric()` for code reuse
- **Firebase Optimization**: Uses `set` with `merge` to avoid reads before writes

**Critical Lobby Methods**:
- `joinLobby(worldId, username)`: Adds user to lobby with real-time coordination
- `getLobbyUsersStream(worldId)`: Stream of users in lobby with live updates
- `startLobby(worldId, userIds)`: Marks lobby as started and stores active participants
- `getLobbyStartedStream(worldId)`: Stream monitoring lobby start events
- `getActiveLobbyUsers(worldId)`: Gets participants who were present at lobby start
- `leaveLobby(worldId)`: Removes user from lobby

**Authentication Methods**:
- `createAccountForWorld()`: Creates user account with merge option
- `getOrCreateAnonId()`: Gets existing or generates new anonymous ID
- `trackWorldVisit()`: Increments user visit count for analytics

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
**Purpose**: Local queue management from lobby participants with turn-based coordination.

**Key Responsibilities**:
- **Lobby-Based Queue Creation**: Creates queues from real lobby participant data
- **Turn Management**: Handles 60-second turn rotation among lobby participants
- **Real User Integration**: Manages real users vs. dummy placeholders for other lobby participants
- **Queue State Broadcasting**: Provides real-time queue state updates via streams
- **Typing State Management**: Handles real user typing indicators
- **Post Submission**: Manages real user post submission and queue advancement

**Critical Methods**:
- `initialize(lobbyUserIds, lobbyUserNicknames)`: Creates queue from lobby participant data
- `_createInitialQueue()`: Builds queue using real lobby users with nicknames
- `canRealUserPost()`: Checks if real user can post (when it's their turn)
- `handleRealUserPost()`: Processes real user post submission and advances queue
- `moveToNextUser()`: Advances to next user in queue rotation
- `startRealUserTyping()`: Manages real user typing state

**Architecture Changes**:
- **No Bot Assignment Dependency**: Uses actual lobby participants instead of assigned bots
- **Real User Focus**: Queue built from real users who joined the lobby together
- **Simplified Queue Logic**: No complex bot personality or capacity restrictions

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
**Purpose**: Handles post creation and management with lobby nickname integration.

**Features**:
- **Custom Author Support**: Posts can display with lobby nicknames via `customAuthor` field
- Regular user post creation with validation
- World-specific post filtering and streaming
- Firestore integration with proper error handling
- **Performance Optimization**: Removed Firebase reaction writes (client-only reactions)

**Methods**:
- `addPost(text, world, userId, {customAuthor})`: Create post with optional custom author (lobby nickname)
- `getPostsStream()`: Real-time post updates for all worlds
- `getPostsStreamForWorld(world)`: Filtered post stream for specific world
- `migrateGenderToWorldSchema()`: Migration utility for schema updates

**Integration with Lobby System**:
- Posts created with lobby nicknames as `customAuthor`
- Real-time streaming enables lobby participants to see each other's posts
- World filtering ensures posts are scoped correctly

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
**Purpose**: Legacy bot assignment service (currently not used in lobby system).

**Status**: **DEPRECATED** - Not integrated with current lobby-based architecture.

**Previous Logic** (for reference):
- Assigned bots from world configuration bot tables
- Used vibe check answers to determine personality tables
- Stored assignments in local storage for persistence

**Current System**: The lobby-based architecture uses real users instead of bot assignment, making this service redundant. The service remains in the codebase but is not called by the current user flow.

**Methods** (legacy):
- `assignBots()`: Random bot assignment (bypasses vibe check)
- `getAssignedBots()`: Retrieve current assignments
- `clearAssignedBots()`: Reset bot assignments

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

### Service Instantiation Pattern
Services are instantiated directly (not singletons) for better testability:
```dart
class ServiceName {
  // Direct instantiation
  final ServiceName _service = ServiceName();
}
```

### Lobby Coordination Pattern
Real-time lobby management follows consistent Firebase patterns:
```dart
// Join lobby with real-time updates
await _authService.joinLobby(worldId, username);
// Listen to lobby changes
_authService.getLobbyUsersStream(worldId).listen((users) {
  // Update UI with lobby participants
});
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
1. **AuthService** → Manages user identity and lobby coordination
2. **LocalStorageService** → Persists user data and lobby state
3. **WorldService** → Provides world configurations
4. **QueueService** → Creates queues from lobby participants
5. **PostService** → Handles posts with lobby nickname integration
6. **HomeViewModel** → Orchestrates lobby queue and Firebase streaming

### Real-time Data Flow
- Firebase streams provide real-time updates
- Services emit state changes through StreamControllers
- UI components subscribe to service streams
- Local storage maintains offline state

## Development Guidelines

### Adding New Services
1. Use direct instantiation for better testability
2. Implement proper error handling and validation
3. Add comprehensive documentation for public methods
4. Consider lobby system integration requirements
5. Follow Firebase streaming patterns for real-time data

### Lobby-Based Service Integration
```dart
// Queue service initialized with lobby participants
await _queueService.initialize(
  lobbyUserIds: lobbyUserIds,
  lobbyUserNicknames: lobbyUserNicknames
);

// HomeViewModel with lobby integration
_viewModel = HomeViewModel(
  lobbyUserIds: widget.lobbyUserIds,
  lobbyUserNicknames: widget.lobbyUserNicknames
);
```

### Firebase Integration
- Always validate input before Firebase operations
- Use server timestamps for consistent timing
- Implement proper error handling
- Use merge options when updating existing documents
- **Lobby Pattern**: Use real-time streams for lobby coordination
- **Performance**: Minimize Firebase writes (e.g., client-only reactions)

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