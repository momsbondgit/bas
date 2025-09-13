# View Models Directory - CLAUDE.md

This directory contains view model classes that manage UI state and business logic using the MVVM (Model-View-ViewModel) architecture pattern with Flutter's ChangeNotifier.

## Files Overview

### `admin_view_model.dart`
**Purpose**: Manages state for the admin dashboard system.

**Key Responsibilities**:
- **Session Management**: Admin authentication state, session timers, auto-logout
- **Section Navigation**: Current admin section (posts, add post, system controls)
- **Data Streams**: Real-time posts, endings, and maintenance status from Firebase
- **Authentication**: Login state checking and session extension

**State Properties**:
- `currentSection`: Active admin dashboard section
- `posts`: Real-time posts collection
- `endings`: User submissions (Instagram, phone numbers)
- `maintenanceStatus`: System maintenance state
- `remainingSessionMinutes`: Session countdown timer

**Key Methods**:
- `initialize()`: Sets up authentication, data streams, and session timer
- `logout()`: Clears session and notifies listeners
- `extendSession()`: Extends admin session duration
- `onSectionChanged()`: Handles section navigation

**Stream Management**: Properly manages multiple Firebase stream subscriptions with disposal.

### `ritual_queue_view_model.dart`
**Purpose**: Manages state for the ritual queue messaging system - the core user experience.

**Key Responsibilities**:
- **Queue State Management**: Current queue state, active users, turn rotation
- **User Context**: Current user ID, display name, active status
- **Typing Management**: Typing timers, message composition state
- **Real-time Updates**: Queue state changes via RitualQueueService streams

**State Properties**:
- `queueState`: Current RitualQueueState from service
- `currentUserId`: Local user identification
- `isActiveUser`: Whether current user has active turn
- `canType`: Permission to compose messages
- `canSubmit`: Permission to submit messages

**Key Methods**:
- `initialize()`: Sets up queue service and user context
- `joinQueue()`: Adds user to ritual queue
- `startTyping()`: Initiates typing state
- `submitMessage()`: Handles message submission and queue rotation
- `leaveQueue()`: Removes user from queue

**Real-time Integration**: Listens to RitualQueueService stream for live queue updates.

### `post_input_view_model.dart`
**Purpose**: Manages state for post composition and submission.

**Key Responsibilities**:
- **Form Validation**: Text length, content validation
- **Submission State**: Loading states, error handling
- **Local Storage**: Floor selection persistence, user data storage
- **Service Integration**: PostService for Firebase submission

**State Properties**:
- `isSubmitting`: Loading state during post submission
- `errorMessage`: Form validation and submission errors

**Key Methods**:
- `submitPost()`: Handles post validation, submission, and success callbacks
- Validates character limits (200 characters)
- Manages local storage for user preferences
- Provides user feedback for success/error states

**Validation Logic**:
- Empty text validation
- Character limit enforcement
- User ID generation and tracking

### `home_view_model.dart`
**Purpose**: Manages state for the main home screen experience.

**Key Responsibilities**:
- **Post Management**: User posts and bot post simulation
- **Queue Integration**: Queue state management and user participation
- **Viewer Simulation**: Simulated viewer count for engagement
- **Timer Management**: Reaction timers and queue timing
- **Maintenance Monitoring**: System maintenance status tracking

**State Properties**:
- `hasPosted`: User posting status
- `viewerCount`: Simulated active viewer count
- `posts`: Combined user and bot posts
- `queueState`: Current queue status
- `reactionTimeRemaining`: Timer for reaction periods

**Key Methods**:
- Post creation and management
- Queue participation logic
- Viewer count simulation
- Timer management for various features

**Multi-Service Integration**: Coordinates PostService, QueueService, MaintenanceService.

## Key Patterns

### ChangeNotifier Pattern
All view models extend `ChangeNotifier` for reactive UI updates:
```dart
class MyViewModel extends ChangeNotifier {
  void updateState() {
    // Update internal state
    notifyListeners(); // Trigger UI rebuild
  }
}
```

### Service Integration Pattern
View models act as mediators between services and UI:
- Instantiate required services
- Transform service data for UI consumption
- Handle service errors and provide user feedback
- Manage service lifecycle (initialization, disposal)

### Stream Management Pattern
Proper stream subscription handling:
```dart
StreamSubscription<DataType>? _subscription;

void _setupStream() {
  _subscription = service.getStream().listen((data) {
    // Update state
    notifyListeners();
  });
}

@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

### Error Handling Pattern
Consistent error management:
- Private error state variables
- Public error getters
- User-friendly error messages
- Error state clearing methods

### Loading State Pattern
UI loading state management:
- Boolean loading flags
- Loading state toggling around async operations
- UI feedback during operations

## Architecture Benefits

### Separation of Concerns
- **Models**: Data structure and business rules
- **Services**: Data fetching and business logic
- **ViewModels**: UI state management and service coordination
- **Views**: Pure UI components

### Testability
- ViewModels can be unit tested independently
- Service dependencies can be mocked
- State changes can be verified
- Business logic testing without UI dependencies

### Reactive UI Updates
- Automatic UI rebuilds on state changes
- Efficient widget rebuilds with ChangeNotifier
- Stream-based real-time updates
- Consistent state across multiple widgets

## Development Guidelines

### Creating New ViewModels
1. **Extend ChangeNotifier** for reactive state management
2. **Initialize required services** in constructor or init method
3. **Implement proper disposal** of resources (streams, timers)
4. **Handle errors gracefully** with user-friendly messages
5. **Use private state variables** with public getters

### State Management Best Practices
1. **Keep state immutable** where possible
2. **Call notifyListeners()** after state changes
3. **Batch related state updates** to minimize rebuilds
4. **Validate input** before state changes
5. **Provide loading states** for async operations

### Service Integration
1. **Inject services** through constructor or factory methods
2. **Handle service failures** with try-catch blocks
3. **Transform service data** for UI consumption
4. **Cache frequently accessed data** to reduce service calls
5. **Dispose service resources** properly

### Testing Approach
1. **Mock service dependencies** for isolated testing
2. **Test state transitions** and validation logic
3. **Verify notifyListeners() calls** for reactive updates
4. **Test error conditions** and edge cases
5. **Test disposal** to prevent memory leaks

### Performance Considerations
- ViewModels should be lightweight state containers
- Avoid heavy computations in getters
- Use lazy loading for expensive operations
- Consider using computed properties for derived state
- Profile memory usage with stream subscriptions