# PRP: Ritual Queue Active User Feed Enhancement

## 📋 Product Requirements Document

### Feature Overview
Transform the ritual queue system to display only the active user's content with real-time typing indicators, controlled interaction states, and smooth user rotation with notification banners.

### User Stories
- **As a participant**, I want to see only the active user's content so I can focus on their message
- **As a participant**, I want to see when someone is typing with a beautiful animation
- **As the active user**, I want clear indication that it's my turn to participate
- **As a participant**, I want to react to messages but only hold one reaction per message
- **As a participant**, I want to know when the queue rotates to the next person

## 🎯 Technical Requirements

### Core Functionality

#### 1. Feed Display Control
- **Active State**: Only active user's turn content visible in feed
- **Typing State**: Single typing indicator line replaces all feed content
- **Submission State**: Active user's message card appears, reactions enabled
- **Rotation State**: Brief notification banner, then return to typing state

#### 2. Typing Indicator System
```dart
class TypingIndicator {
  final String displayName;
  final bool isVisible;
  final AnimationController dotBounceController;
  final AnimationController shimmerController;
}
```

**Animation Specifications:**
- Three-dot bounce animation (60fps)
- Subtle shimmer effect overlay
- Theme-aware colors (light/dark mode)
- Respects system reduced-motion preferences
- Text: "{displayName} is typing…"

#### 3. Queue Rotation & Notifications
```dart
class QueueRotationState {
  final String newActiveUserId;
  final String newActiveDisplayName;
  final bool showRotationBanner;
  final Duration bannerDisplayTime; // 3-5 seconds
}
```

**Banner Messages:**
- General participants: "New turn: {displayName}"
- Active user: "It's your turn."
- Style: Light, non-blocking, auto-dismiss

#### 4. Reaction System Enhancement
```dart
class UserReaction {
  final String userId;
  final String messageId;
  final ReactionType currentReaction;
  final DateTime lastUpdated;
}

enum ReactionState {
  disabled, // During typing state
  enabled,  // During submission state
}
```

**Reaction Rules:**
- One active reaction per user per message
- New reaction replaces previous reaction
- Reactions disabled during typing state
- Reactions enabled when message card appears

#### 5. Timer Configuration
```dart
class RitualQueueConfig {
  final Duration turnDuration; // Default: 60 seconds
  final bool autoRotateEnabled;
  final Duration notificationDuration; // Banner display time
}
```

## 🏗️ Data Models

### Core Models
```dart
class RitualQueueState {
  const RitualQueueState({
    required this.activeUserId,
    required this.activeDisplayName,
    required this.isActiveUserTyping,
    required this.remainingTime,
    required this.userQueue,
    required this.currentMessage,
    this.showRotationBanner = false,
  });

  final String activeUserId;
  final String activeDisplayName;
  final bool isActiveUserTyping;
  final Duration remainingTime;
  final List<QueueUser> userQueue;
  final Message? currentMessage;
  final bool showRotationBanner;
}

class Message {
  const Message({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
    required this.reactions,
  });

  final String id;
  final String userId;
  final String content;
  final DateTime timestamp;
  final Map<String, ReactionType> reactions; // userId -> ReactionType
}

class QueueUser {
  const QueueUser({
    required this.userId,
    required this.displayName,
    required this.isActive,
    required this.position,
  });

  final String userId;
  final String displayName;
  final bool isActive;
  final int position;
}
```

## 🎨 UI/UX Components

### 1. TypingAnimationWidget
```dart
class TypingAnimationWidget extends StatefulWidget {
  const TypingAnimationWidget({
    super.key,
    required this.displayName,
    required this.theme,
  });

  final String displayName;
  final ThemeData theme;
}
```

**Features:**
- Three animated dots with staggered bounce
- Shimmer overlay effect
- Theme-aware styling
- Reduced motion support
- 60fps performance target

### 2. ActiveUserFeedWidget
```dart
class ActiveUserFeedWidget extends StatelessWidget {
  const ActiveUserFeedWidget({
    super.key,
    required this.queueState,
    required this.onReactionTap,
  });

  final RitualQueueState queueState;
  final Function(String messageId, ReactionType reaction) onReactionTap;
}
```

**Rendering Logic:**
- Typing state: Show only TypingAnimationWidget
- Message state: Show message card with enabled reactions
- Empty state: Show placeholder or minimal UI

### 3. QueueRotationBanner
```dart
class QueueRotationBanner extends StatefulWidget {
  const QueueRotationBanner({
    super.key,
    required this.displayName,
    required this.isActiveUser,
    required this.onDismiss,
  });

  final String displayName;
  final bool isActiveUser;
  final VoidCallback onDismiss;
}
```

**Features:**
- Auto-dismiss after 3-5 seconds
- Slide-in animation from top
- Different messages for active vs. other users
- Non-blocking overlay style

### 4. ReactionControlWidget
```dart
class ReactionControlWidget extends StatelessWidget {
  const ReactionControlWidget({
    super.key,
    required this.messageId,
    required this.currentUserReaction,
    required this.isEnabled,
    required this.onReactionTap,
  });

  final String messageId;
  final ReactionType? currentUserReaction;
  final bool isEnabled;
  final Function(ReactionType) onReactionTap;
}
```

## 🔧 Services & Business Logic

### 1. RitualQueueService
```dart
class RitualQueueService {
  Stream<RitualQueueState> get queueStateStream;
  
  Future<void> startTyping(String userId);
  Future<void> stopTyping(String userId);
  Future<void> submitMessage(String userId, String content);
  Future<void> addReaction(String messageId, String userId, ReactionType reaction);
  Future<void> removeReaction(String messageId, String userId);
  Future<void> rotateQueue();
  
  void startTimer(Duration duration);
  void pauseTimer();
  void resetTimer();
}
```

### 2. TypingIndicatorService
```dart
class TypingIndicatorService {
  Stream<Map<String, bool>> get typingUsersStream;
  
  Future<void> setUserTyping(String userId, bool isTyping);
  Future<void> broadcastTypingState(String userId, bool isTyping);
}
```

### 3. AnimationControllerService
```dart
class AnimationControllerService {
  late final AnimationController dotBounceController;
  late final AnimationController shimmerController;
  late final Animation<double> dotBounceAnimation;
  late final Animation<double> shimmerAnimation;
  
  void startAnimations();
  void stopAnimations();
  void dispose();
}
```

## 📁 Implementation Plan

### File Structure
```
lib/
├── models/
│   ├── ritual_queue_state.dart
│   ├── message.dart
│   ├── queue_user.dart
│   └── reaction_type.dart
├── services/
│   ├── ritual_queue_service.dart
│   ├── typing_indicator_service.dart
│   └── animation_controller_service.dart
├── widgets/
│   ├── typing_animation_widget.dart
│   ├── active_user_feed_widget.dart
│   ├── queue_rotation_banner.dart
│   └── reaction_control_widget.dart
├── screens/
│   └── ritual_feed_screen.dart
└── utils/
    ├── animation_utils.dart
    └── accessibility_utils.dart
```

### Dependencies Required
```yaml
# pubspec.yaml additions
dependencies:
  stream_transform: ^2.1.0  # For stream manipulation
  
dev_dependencies:
  mocktail: ^1.0.0  # For service mocking in tests
```

### Configuration Files
```dart
// lib/config/ritual_config.dart
class RitualConfig {
  static const Duration defaultTurnDuration = Duration(seconds: 60);
  static const Duration bannerDisplayDuration = Duration(seconds: 4);
  static const Duration typingDebounceDelay = Duration(milliseconds: 500);
  
  // Animation settings
  static const int targetFPS = 60;
  static const Duration dotBounceDuration = Duration(milliseconds: 600);
  static const Duration shimmerDuration = Duration(seconds: 2);
}
```

## 🧪 Testing Strategy

### Unit Tests
```dart
// test/services/ritual_queue_service_test.dart
group('RitualQueueService', () {
  test('should rotate to next user when timer expires', () async {
    // Given
    final service = RitualQueueService();
    final initialState = createMockQueueState();
    
    // When
    await service.rotateQueue();
    
    // Then
    expect(service.queueStateStream, emits(isA<RitualQueueState>()
      .having((state) => state.activeUserId, 'activeUserId', isNot(initialState.activeUserId))));
  });

  test('should replace existing reaction when user reacts again', () async {
    // Test reaction replacement logic
  });

  test('should disable reactions during typing state', () async {
    // Test reaction state management
  });
});
```

### Widget Tests
```dart
// test/widgets/typing_animation_widget_test.dart
group('TypingAnimationWidget', () {
  testWidgets('should display typing text with user display name', (tester) async {
    // Given
    const displayName = 'Alice';
    
    // When
    await tester.pumpWidget(TypingAnimationWidget(
      displayName: displayName,
      theme: ThemeData.light(),
    ));
    
    // Then
    expect(find.text('$displayName is typing…'), findsOneWidget);
  });

  testWidgets('should respect reduced motion preferences', (tester) async {
    // Test accessibility compliance
  });

  testWidgets('should animate at 60fps when possible', (tester) async {
    // Test animation performance
  });
});
```

### Integration Tests
```dart
// integration_test/ritual_queue_flow_test.dart
group('Ritual Queue Flow', () {
  testWidgets('complete user turn cycle', (tester) async {
    // Test: typing → submit → reactions → timer → next user
  });

  testWidgets('multiple users typing state handling', (tester) async {
    // Test edge cases with multiple users
  });
});
```

### Performance Tests
- Animation frame rate monitoring
- Memory usage during long sessions
- Stream subscription cleanup verification

## ✅ Acceptance Criteria

### Functional Requirements
- [ ] Only active user content visible in feed during their turn
- [ ] Typing indicator shows with correct display name and animations
- [ ] Three-dot bounce animation runs at 60fps
- [ ] Subtle shimmer effect overlays typing indicator
- [ ] All message cards and reactions hidden during typing state
- [ ] Message card appears immediately after submission
- [ ] Reactions become available after message submission
- [ ] Each user can hold only one reaction per message
- [ ] New reactions replace previous reactions from same user
- [ ] Queue rotates automatically after 60-second timer (configurable)
- [ ] Rotation banner shows appropriate message for each user type
- [ ] Banner auto-dismisses after 4 seconds

### Technical Requirements
- [ ] Theme-aware animations (light/dark mode support)
- [ ] Reduced motion accessibility compliance
- [ ] Real-time updates via streams
- [ ] Proper timer management and cleanup
- [ ] Memory efficient animation controllers
- [ ] Smooth state transitions without flicker

### Performance Requirements
- [ ] Animations maintain 60fps on target devices
- [ ] No memory leaks during extended usage
- [ ] Fast state transitions (<100ms)
- [ ] Efficient stream subscription management

### Testing Requirements
- [ ] Unit tests for all business logic (>80% coverage)
- [ ] Widget tests for all UI components
- [ ] Integration tests for complete user flows
- [ ] Performance tests for animation smoothness
- [ ] Accessibility tests for reduced motion support

### Code Quality Requirements
- [ ] Follows Dart/Flutter style guidelines
- [ ] Proper null safety implementation
- [ ] Comprehensive error handling
- [ ] Clear separation of concerns
- [ ] Documented public APIs
- [ ] Code review completed

---

## 🚀 Implementation Priority

### Phase 1: Core Infrastructure
1. Data models and state management
2. Basic queue service with timer
3. Typing indicator service

### Phase 2: UI Components
1. Typing animation widget
2. Active user feed widget
3. Reaction control system

### Phase 3: Advanced Features
1. Queue rotation banners
2. Accessibility enhancements
3. Performance optimizations

### Phase 4: Testing & Polish
1. Comprehensive test suite
2. Performance tuning
3. Documentation and code review

**Estimated Timeline:** 2-3 weeks for full implementation
**Priority Level:** High
**Technical Complexity:** Medium-High (Animation + Real-time state management)