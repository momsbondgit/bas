# View Models Directory - CLAUDE.md

This directory contains view model classes that implement the MVVM (Model-View-ViewModel) pattern for managing complex UI state and business logic separation in the BAS Rituals application.

## Overview

The app is transitioning to MVVM architecture for complex screens to better separate concerns and improve testability. View models act as the bridge between the UI (View) and business logic (Services/Models).

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
**Purpose**: Manages the home screen state with local bot posts and queue simulation.

**Key Features**:
- **Local Bot Post Management**: Simulates bot posts in the local feed
- **Queue State Tracking**: Manages local queue of bot users
- **Universal Reaction Timer**: 60-second countdown for reaction phase
- **Viewer Count Simulation**: Random viewer count updates

**State Properties**:
- User posts and local bot posts
- Queue state with bot users
- Reaction timer state
- Dynamic viewer count
- Post submission state

**Integration**:
- `QueueService` for local bot queue management
- `PostService` for post creation
- `LocalStorageService` for persistence
- `MaintenanceService` for system status

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

### Direct Usage (current pattern):
```dart
class _ScreenState extends State<Screen> {
  late final ViewModelName _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelName();
    _viewModel.addListener(_onViewModelChange);
    _viewModel.initialize();
  }

  void _onViewModelChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }
}
```

## Development Guidelines

### Creating New View Models
1. **Extend ChangeNotifier**: All view models should extend `ChangeNotifier`
2. **Private State**: Keep state properties private with public getters
3. **Service Injection**: Use dependency injection for services when possible
4. **Proper Cleanup**: Override `dispose()` to clean up resources
5. **Error Handling**: Include error state and messages

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

## Migration Strategy

The app is gradually migrating to MVVM pattern:
1. **Phase 1**: Complex screens (Admin, Home, Ritual Queue) - COMPLETED
2. **Phase 2**: Remaining screens as needed
3. **Phase 3**: Add Provider package for better integration
4. **Phase 4**: Unit testing infrastructure for view models

## Benefits of MVVM Pattern

1. **Separation of Concerns**: UI logic separated from business logic
2. **Testability**: View models can be unit tested without UI
3. **Reusability**: View models can be shared across different UI implementations
4. **Maintainability**: Clearer code organization and responsibility
5. **State Management**: Centralized state handling with ChangeNotifier