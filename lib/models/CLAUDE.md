# Models Directory - CLAUDE.md

This directory contains data models that represent the core entities and state in the BAS Rituals application.

## Directory Structure

### `data/` - Core Data Models

#### `message.dart`
**Purpose**: Represents individual messages in the ritual queue system.

**Key Features**:
- **Core Properties**: ID, user ID, display name, content, timestamp
- **Reaction System**: Map of user IDs to reaction types for each message
- **Immutable Design**: Uses `copyWith()` pattern for state updates
- **Reaction Methods**: Add/remove reactions, count reactions by type, check user reactions
- **Serialization**: Complete `toMap()`/`fromMap()` for Firebase storage

#### `reaction_type.dart`
**Purpose**: Enum defining available message reactions.

**Available Reactions**:
- Heart ❤️, Laugh 😂, Wow 😮, Sad 😢, Angry 😠, Thumbs Up 👍, Thumbs Down 👎
- Each has emoji representation and display name
- `fromString()` method for deserializing from storage

### `queue/` - Queue System Models

#### `ritual_queue_state.dart`
**Purpose**: Represents the complete state of the ritual queue system.

**Core State Management**:
- **Active User Tracking**: Current active user ID and display name
- **Phase Management**: Enum for queue phases (waiting, typing, submitted, rotating)
- **Timer Management**: Remaining time for current turn
- **Queue Management**: List of queue users with their states

**Key Enums**:
- `QueuePhase`: waiting, typing, submitted, rotating

**State Transition Methods**:
- `startTyping()`: Transition to typing phase
- `submitMessage()`: Move to submitted phase with message
- `startRotation()`: Begin rotation with banner
- `completeRotation()`: Finish rotation with new active user
- `updateReactions()`: Update message reactions

**Computed Properties**:
- `isActiveUserTyping`: Check if currently in typing phase
- `hasCurrentMessage`: Whether there's an active message
- `reactionsEnabled`: Whether reactions can be added (submitted phase)

### `user/` - User Models

#### `bot_user.dart`
**Purpose**: Simple model for bot configuration in worlds.

**Properties**:
- `botId`: Unique identifier for the bot
- `nickname`: Display name for the bot
- `quineResponse`: Predefined response the bot gives

**Usage**: Used in world configurations to define bot personalities and responses.

#### `queue_user.dart`
**Purpose**: Comprehensive model for users in the ritual queue system.

**Key Enums**:
- `QueueUserType`: real (human users) vs dummy (bots)
- `QueueUserState`: waiting, active, posted, completed
- `TypingState`: idle vs typing

**Core Properties**:
- User identification (ID, display name)
- State tracking (queue state, typing state)
- Timing data (turn start, last active, typing start times)
- Context data (floor, world)

**Computed Properties**:
- `isActive`, `hasPosted`, `isReal`, `isDummy`, `isTyping`
- `remainingTurnSeconds`: Calculates remaining time (unlimited for real users, 60s for bots)

**Integration with Queue Services**:
- Used by both `RitualQueueService` (Firebase-based) and `QueueService` (local bot simulation)
- Real users always positioned at index 2 in local queue management
- Bot users fill positions 0, 1, 3, 4, 5 with position 0 being the initial active user

## Key Patterns

### Immutable State Pattern
All models use immutable design with `copyWith()` methods for updates:
```dart
final updatedMessage = message.copyWith(content: "new content");
```

### Serialization Pattern
All models implement `toMap()` and `fromMap()` for Firebase persistence:
```dart
// Serialize for storage
final map = message.toMap();

// Deserialize from storage
final message = Message.fromMap(map);
```

### Enum-Based State Management
Heavy use of enums for type-safe state representation:
- Reaction types for message interactions
- Queue phases for system state
- User types and states for queue management

### Time-Based Logic
Models include comprehensive timestamp handling:
- Message timestamps for ordering
- Turn timing for queue rotation
- Typing state timestamps for UI feedback

## Development Guidelines

### Adding New Models
1. Follow immutable design pattern with `copyWith()`
2. Implement complete serialization (`toMap()`/`fromMap()`)
3. Add proper `==`, `hashCode`, and `toString()` overrides
4. Use enums for state representation where appropriate

### State Transitions
- Keep state transition logic in the models themselves
- Use computed properties for derived state
- Ensure all state changes are immutable

### Serialization Best Practices
- Handle null values gracefully in `fromMap()`
- Use milliseconds for DateTime serialization
- Convert enums using `.name` and reverse lookup

### Performance Considerations
- Models are designed for frequent copying (immutable pattern)
- Reaction maps use efficient key-value lookup
- Queue lists support efficient state updates