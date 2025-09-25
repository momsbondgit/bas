# View Models Directory - CLAUDE.md

This directory contains view model classes that implement the MVVM (Model-View-ViewModel) pattern for managing complex UI state and business logic separation in the BAS Rituals application.

## Overview

The app uses MVVM architecture for complex screens to separate concerns and improve testability. View models act as the bridge between the UI (View) and business logic (Services/Models), with special focus on lobby coordination and real-time Firebase streaming.

## View Model Files

### `admin_view_model.dart`
**Purpose**: Manages state and business logic for the admin dashboard.

**Key Responsibilities**:
- Admin authentication state management
- Section navigation tracking (posts, system controls, metrics)
- Real-time data stream management for posts and endings
- Maintenance status monitoring
- Session timer management with automatic logout

**State Management**:
- Current admin section selection
- Posts and endings lists
- Maintenance status
- Session countdown timer
- Loading states

**Integration**:
- `AdminService` for authentication
- `MaintenanceService` for system control
- `PostService` for content management
- Firebase streams for real-time updates

### `home_view_model.dart`
**Purpose**: Manages the home screen with lobby-based queue and Firebase post streaming.

**Key Features**:
- **Lobby-Based Queue Management**: Creates and manages queue from lobby participants
- **Firebase Post Streaming**: Real-time post updates from other lobby participants
- **Multi-Source Posts**: Separates user posts, local bot posts, and Firebase posts
- **Universal Reaction Timer**: 30-second countdown after posts for reactions
- **Real User Coordination**: Handles real user posting and turn management
- **Lobby Nickname Integration**: Posts display with lobby nicknames as authors

**State Properties**:
- Three post categories: `_userPosts`, `_localBotPosts`, `_firebasePosts`
- Queue state from lobby participants
- Reaction timer state (30 seconds)
- Static viewer count (set to 6)
- Real user posting capabilities

**Constructor Integration**:
```dart
HomeViewModel({this.lobbyUserIds, this.lobbyUserNicknames})
```

**Integration**:
- `QueueService` initialized with lobby participant data
- `PostService` for post creation with custom authors (lobby nicknames)
- Firebase post streaming filtered by world
- Real-time queue state management from lobby users

### `ritual_queue_view_model.dart`
**Purpose**: Manages the ritual queue experience and real-time messaging state.

**Key Responsibilities**:
- Ritual queue initialization and state management
- User typing and message submission
- Turn-based timer management
- Real-time queue state synchronization
- Error handling and recovery

**State Management**:
- Current queue state
- User identification (ID and display name)
- Active user status
- Typing and submission capabilities
- Error messages

**Methods**:
- `initialize()`: Set up service connections
- `handleTyping()`: Manage typing state
- `submitMessage()`: Submit user messages
- `cleanup()`: Dispose resources properly

**Integration**:
- `RitualQueueService` for queue operations
- `LocalStorageService` for user data
- Stream subscriptions for real-time updates

## Key Patterns

### ChangeNotifier Pattern
All view models extend `ChangeNotifier` from Flutter's foundation library:
```dart
class ViewModelName extends ChangeNotifier {
  // State properties

  // Call notifyListeners() when state changes
  void updateState() {
    _state = newState;
    notifyListeners();
  }
}
```

### Service Integration
View models integrate with services but don't directly access Firebase:
```dart
final ServiceName _service = ServiceName();

// Use service methods
await _service.performAction();
```

### Stream Management
Proper subscription handling with cleanup:
```dart
StreamSubscription? _subscription;

void initialize() {
  _subscription = _service.stream.listen((data) {
    _updateState(data);
    notifyListeners();
  });
}

@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

### Timer Management
Timers are properly managed and disposed:
```dart
Timer? _timer;

void startTimer() {
  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    _updateCountdown();
    notifyListeners();
  });
}

@override
void dispose() {
  _timer?.cancel();
  super.dispose();
}
```

## Usage in UI

View models are typically used with `ChangeNotifierProvider` or direct instantiation:

### With Provider Package (if added):
```dart
ChangeNotifierProvider(
  create: (_) => ViewModelName(),
  child: Consumer<ViewModelName>(
    builder: (context, viewModel, child) {
      return Widget();
    },
  ),
)
```

### Direct Usage with Lobby Integration (current pattern):
```dart
class _GameExperienceScreenState extends State<GameExperienceScreen> {
  late HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Initialize with lobby data
    _viewModel = HomeViewModel(
      lobbyUserIds: widget.lobbyUserIds,
      lobbyUserNicknames: widget.lobbyUserNicknames
    );
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.initialize();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }
}
```

## Development Guidelines

### Creating New View Models
1. **Extend ChangeNotifier**: All view models should extend `ChangeNotifier`
2. **Lobby Integration**: Accept lobby data via constructor parameters
3. **Private State**: Keep state properties private with public getters
4. **Service Initialization**: Initialize services with lobby participant data
5. **Firebase Streaming**: Implement real-time Firebase streams for coordination
6. **Proper Cleanup**: Override `dispose()` to clean up resources and streams
7. **Error Handling**: Include error state and messages

**Lobby Integration Pattern**:
```dart
class CustomViewModel extends ChangeNotifier {
  final List<String>? lobbyUserIds;
  final Map<String, String>? lobbyUserNicknames;

  CustomViewModel({this.lobbyUserIds, this.lobbyUserNicknames});

  void initialize() {
    // Use lobby data to initialize services
    _service.initialize(
      lobbyUserIds: lobbyUserIds,
      lobbyUserNicknames: lobbyUserNicknames
    );
  }
}
```

### State Updates
1. **Always call notifyListeners()** after state changes
2. **Batch updates** when possible to reduce rebuilds
3. **Use computed getters** for derived state
4. **Avoid direct Firebase access** - use services instead

### Testing Considerations
1. **Mock Services**: View models should accept service instances for testing
2. **Test State Changes**: Verify notifyListeners() is called appropriately
3. **Test Cleanup**: Ensure dispose() properly cleans up resources
4. **Test Error Cases**: Verify error handling behavior

### Performance Best Practices
1. **Minimize notifyListeners() calls**: Batch state updates
2. **Use selective rebuilds**: Consider using `Selector` widgets if using Provider
3. **Dispose properly**: Always clean up subscriptions and timers
4. **Lazy initialization**: Initialize expensive operations only when needed

## Current Implementation Status

MVVM pattern is fully implemented for core screens:
1. **HomeViewModel**: Lobby-based queue management and Firebase post streaming - ACTIVE
2. **AdminViewModel**: Admin dashboard with real-time data streams - ACTIVE
3. **RitualQueueViewModel**: Legacy ritual queue (may not be used in current lobby system)

**Lobby System Integration**:
- View models receive lobby participant data via constructor
- Real-time Firebase streams for post coordination
- Queue management based on actual lobby participants
- Nickname integration throughout the data flow

## Benefits of MVVM Pattern in Lobby System

1. **Separation of Concerns**: UI logic separated from lobby coordination and Firebase streaming
2. **Real-time Coordination**: View models handle Firebase streams for lobby synchronization
3. **Testability**: View models can be unit tested with mock lobby data
4. **Lobby State Management**: Centralized handling of lobby participants and queue states
5. **Multi-source Data**: Clean separation of user posts, Firebase posts, and local bot posts
6. **Reusability**: Lobby integration patterns can be shared across screens
7. **State Management**: Centralized state handling with ChangeNotifier and Firebase streams