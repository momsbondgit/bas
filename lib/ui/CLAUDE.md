# UI Directory - CLAUDE.md

This directory contains all user interface components for the BAS Rituals application, organized into screens and reusable widgets.

## Directory Structure

### `screens/` - Full Screen Components

#### Core Application Screens

**`general_screen.dart`**
- **Purpose**: Main landing screen with world selection
- **Features**: World tiles, authentication flow integration, returning user handling
- **Navigation**: Entry point that routes users to game experiences

**`game_experience_screen.dart`**
- **Purpose**: Main game interface for ritual queue participation
- **Features**: Real-time messaging, queue management, bot interactions, metrics tracking
- **Integration**: Heavy integration with RitualQueueService and messaging system
- **Queue Display**: Shows queue state with guaranteed real user positioning at slot 3
- **Metrics Tracking**:
  - Session start tracking in `initState()` (fire-and-forget)
  - Session completion tracking on navigation to session end
  - Reaction click tracking when users click reaction buttons
- **Firebase Optimization**: Simplified async calls, removed unnecessary try-catch blocks

**`world_experience_screen.dart`**
- **Purpose**: World-specific experience interface
- **Features**: World-themed UI, custom backgrounds, world-specific interactions

#### Admin Screens

**`admin_screen.dart`**
- **Purpose**: Main admin dashboard with comprehensive management tools
- **Features**: Sidebar navigation, posts management, system controls, analytics
- **Security**: Session-based authentication with automatic expiry checks

**`admin_login_screen.dart`**
- **Purpose**: Admin authentication interface
- **Features**: Credential validation, session creation, responsive design

**`simple_admin_screen.dart`**
- **Purpose**: Simplified admin interface for basic operations

#### System Screens

**`maintenance_screen.dart`**
- **Purpose**: Displayed during system maintenance mode
- **Features**: Custom maintenance messages, admin override options

**`session_end_screen.dart`**
- **Purpose**: Shown when ritual sessions complete
- **Features**: Session summary, next steps, return navigation

### `widgets/` - Reusable Components

#### `admin/` - Admin-Specific Components

**`admin_sidebar.dart`**
- **Purpose**: Navigation sidebar for admin dashboard
- **Features**: Collapsible design, session timer, quick actions
- **Responsive**: Adapts to different screen sizes

**`admin_metrics_section.dart`**
- **Purpose**: Compass metrics dashboard for real user engagement tracking
- **Features**:
  - Collapsible user list with click-to-expand functionality
  - Real users only (filters out bots)
  - Four compass directions with full detail display
  - Visual status indicators (Active/Returning/Completed)
- **Compass Points (Expanded View)**:
  - North: Belonging Proof - Return count tracking
  - East: Flow Working - Session completion rates
  - South: Voice/Recognition - Post creation metrics
  - West: Affection/Resonance - Reaction engagement
- **Display Details**: Each metric shows Question, Metric, Indicator, and Meaning
- **Code Optimization**: Extracted common UI patterns into helper methods
  - `_buildMetricHeader()`: Reusable header component
  - `_buildMetricRow()`: Generic metric row with customizable styling
  - `_buildIndicatorRow()`: Standardized indicator display
  - Reduced repetitive code by ~50%

**`admin_posts_section.dart`**
- **Purpose**: Posts management interface
- **Features**: Real-time post viewing, inline editing, deletion with confirmation
- **Stream Integration**: Live updates via Firestore streams

**`admin_system_controls_section.dart`**
- **Purpose**: System administration controls
- **Features**: Maintenance mode toggle, timer controls, analytics viewing, data reset

**`admin_add_post_section.dart`**
- **Purpose**: Admin post creation interface
- **Features**: Post composition, world/floor selection, announcement system

#### `cards/` - Content Display Components

**`confession_card.dart`**
- **Purpose**: Displays individual confession posts
- **Features**: Formatted text, metadata display, interaction buttons

**`ritual_message_card.dart`**
- **Purpose**: Message display in ritual queue system
- **Features**: User identification, timestamp, reaction system integration

#### `forms/` - Input Components

**`post_input.dart`**
- **Purpose**: Main post composition interface
- **Features**: Character limit enforcement, validation, submission handling

**`world_access_modal.dart`**
- **Purpose**: Multi-step world authentication modal
- **Features**: Access code input, nickname setup, vibe quiz, vibe matching animation, world-specific styling
- **Flow**: 3-step process (authentication → vibe questions → vibe matching → world entry)

#### `indicators/` - Status and Feedback Components

**Real-time Counters:**
- `instagram_counter.dart` - Instagram submission counter
- `phone_numbers_counter.dart` - Phone number submission counter
- `returning_users_counter.dart` - Returning user analytics counter

**Activity Indicators:**
- `typing_indicator.dart` - Shows when users are typing
- `typing_animation_widget.dart` - Animated typing dots
- `message_area_typing_indicator.dart` - Message area specific typing feedback
- `status_indicator.dart` - General status display

#### `animations/` - Animation Components

**`vibe_matching_animation.dart`**
- **Purpose**: Pinterest-inspired card shuffling animation for vibe matching
- **Features**: 3-card centered animation showing user's quiz answers, 8-second duration, truly continuous shuffling, progress indicator
- **Integration**: Used in world access modal after vibe quiz completion
- **Animation Sequence**: Cards appear immediately → continuous shuffling (never stops) → progress updates modal's progress bar → auto-complete after 8 seconds
- **Layout**: Cards are perfectly centered in popup with smooth, never-ending motion at reduced speed
- **Progress Integration**: Reports progress to parent modal, which updates the main "Step 5 of 5" progress bar

#### `layout/` - Structural Components

**`app_initialization_wrapper.dart`**
- **Purpose**: Handles app initialization and routing logic
- **Features**: Maintenance mode checking, Firebase initialization, loading states

**`global_maintenance_listener.dart`**
- **Purpose**: Global maintenance mode monitoring
- **Features**: Real-time maintenance status updates, automatic redirects

**`active_user_feed_widget.dart`**
- **Purpose**: Displays active users in the system
- **Features**: Real-time user activity, presence indicators

**`floor_button.dart`**
- **Purpose**: Floor selection interface
- **Features**: Interactive floor selection, visual feedback

**`queue_rotation_banner.dart`**
- **Purpose**: Displays queue rotation notifications
- **Features**: Animated transitions, user turn notifications

## Key UI Patterns

### Stream-Based Real-time Updates
Most UI components use Firestore streams for live data updates:
```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('posts').snapshots(),
  builder: (context, snapshot) {
    // UI updates automatically when data changes
  },
)
```

### Responsive Design Pattern
Components adapt to different screen sizes:
- Mobile-first design with desktop enhancements
- Flexible layouts using `MediaQuery.of(context).size`
- Collapsible UI elements for space optimization

### State Management Pattern
- Local state with `setState()` for UI-specific state
- Service integration for business logic state
- Stream subscriptions for real-time updates

### Modal and Navigation Pattern
- Consistent modal styling and behavior
- Route-based navigation with named routes
- Context-aware navigation with authentication checks

### Loading and Error States
All components handle:
- Loading states with progress indicators
- Error states with user-friendly messages
- Empty states with appropriate messaging

## Component Integration Patterns

### Service Integration
UI components integrate with services through:
- Direct service instantiation for simple operations
- Stream subscriptions for real-time data
- Future builders for async operations
- **Queue Services**: Components display queue state from both RitualQueueService and QueueService
- **Real User Positioning**: UI reflects guaranteed user placement at queue position 3

### Theme and Styling
- World-specific theming based on configuration
- Consistent color schemes and typography
- Google Fonts integration (Noto Sans)

### Animation and Transitions
- Smooth page transitions
- Loading animations and micro-interactions
- Banner animations for user feedback

## Development Guidelines

### Creating New Screens
1. Follow the stateful widget pattern
2. Implement proper lifecycle management (initState, dispose)
3. Handle loading, error, and empty states
4. Integrate with appropriate services
5. Implement responsive design considerations

### Creating New Widgets
1. Make components reusable and configurable
2. Use const constructors where possible
3. Implement proper key handling for list items
4. Handle edge cases gracefully
5. Follow the existing styling patterns

### Real-time Integration
1. Always dispose stream subscriptions in `dispose()`
2. Handle connection errors gracefully
3. Implement loading states for stream data
4. Use `StreamBuilder` for automatic UI updates

### Accessibility Considerations
- Semantic widgets for screen readers
- Proper contrast ratios for text
- Touch target sizes for mobile interaction
- Keyboard navigation support where applicable

### Performance Optimization
- Use `const` constructors for static widgets
- Implement efficient list rendering for large datasets
- Optimize image loading and caching
- Minimize widget rebuilds with proper state management