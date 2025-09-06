# Admin System Documentation

## Overview
The admin system provides a comprehensive management interface for controlling the application, managing posts, monitoring user analytics, and handling system maintenance. The admin panel is accessible through a secure authentication system with session management.

## Architecture

### Core Components

#### 1. Authentication System (`AdminService`)
**Location:** `/lib/services/admin/admin_service.dart`

- **Credentials:** 
  - Username: `hap`
  - Password: `happyman`
- **Session Management:**
  - 24-hour session duration
  - Automatic session expiry checking
  - Session extension capability
  - Persistent login state using SharedPreferences

**Key Methods:**
- `login(username, password)`: Authenticates admin user
- `logout()`: Clears admin session
- `isLoggedIn()`: Checks if admin session is valid
- `extendSession()`: Extends current session by 24 hours
- `getRemainingSessionMinutes()`: Returns remaining session time

#### 2. Admin Screens

##### Admin Login Screen
**Location:** `/lib/ui/screens/admin_login_screen.dart`

- Responsive design for desktop/tablet/mobile
- Password visibility toggle
- Error handling and validation
- Auto-redirects to dashboard if already logged in
- "Back to App" navigation option

##### Admin Dashboard Screen
**Location:** `/lib/ui/screens/admin_screen.dart`

**Features:**
- Three main sections accessible via sidebar:
  1. Posts Management
  2. Add Post
  3. System Controls
- Real-time data streams for posts, endings, and maintenance status
- Quick stats display (returning users, Instagram IDs, phone numbers, home presence)
- Session timer with extension option

#### 3. Admin UI Components

##### Admin Sidebar
**Location:** `/lib/ui/widgets/admin/admin_sidebar.dart`

- Collapsible/expandable sidebar
- Navigation between admin sections
- Session timer display
- Quick actions (extend session, logout)
- Animated transitions

##### Posts Management Section
**Location:** `/lib/ui/widgets/admin/admin_posts_section.dart`

**Capabilities:**
- View all posts with metadata (floor, gender, reactions)
- Edit post content inline
- Delete posts with confirmation
- Real-time updates via Firestore streams
- Empty state handling

##### Add Post Section
**Location:** `/lib/ui/widgets/admin/admin_add_post_section.dart`

**Features:**
- Create posts as admin
- Select floor (1-10) and world (Girl/Guy Meets College)
- Mark posts as announcements
- Custom author for announcements
- Form validation
- Success/error feedback

##### System Controls Section
**Location:** `/lib/ui/widgets/admin/admin_system_controls_section.dart`

**Controls:**
1. **Maintenance Mode**
   - Toggle system maintenance on/off
   - Custom maintenance messages
   - Real-time status updates

2. **Timer Controls**
   - Start fresh session timer
   - Extend current timer
   - Configurable duration in minutes

3. **Instagram Submissions View**
   - List all Instagram IDs submitted
   - Shows associated gender and floor
   - Total count display

4. **Phone Number Submissions View**
   - List all phone numbers submitted
   - Shows associated metadata
   - Total count display

5. **Returning User Analytics**
   - Track returning users count
   - Reset analytics data option
   - Confirmation dialog for data reset

### Services

#### Maintenance Service
**Location:** `/lib/services/admin/maintenance_service.dart`

**Responsibilities:**
- Manage maintenance mode state in Firestore
- Handle session timers
- Provide real-time maintenance status stream
- Initialize default maintenance document

**Key Methods:**
- `setMaintenanceMode(enabled, customMessage)`: Toggle maintenance
- `startFreshSession(minutes)`: Start new timer
- `extendSessionTimer(additionalMinutes)`: Extend existing timer
- `getMaintenanceStatusStream()`: Real-time status updates

**Data Model (`MaintenanceStatus`):**
```dart
{
  isEnabled: bool,
  message: String,
  lastUpdated: DateTime,
  sessionEndTime: DateTime?,
  defaultSessionMinutes: int
}
```

#### Post Service Integration
The admin system integrates with the existing `PostService` to:
- Add admin posts with special metadata
- Edit existing posts
- Delete posts
- Mark posts as announcements

### Navigation

#### Admin Navigation Utility
**Location:** `/lib/utils/admin_navigation.dart`

**Features:**
- Centralized navigation logic
- Authentication checks before navigation
- Logout and redirect functionality
- `AdminAccessMixin` for adding admin access to any screen

**Key Methods:**
- `navigateToLogin(context)`: Navigate to admin login
- `navigateToDashboard(context)`: Navigate to admin dashboard
- `canAccessAdmin()`: Check admin access permission
- `logoutAndNavigateToLogin(context)`: Logout and redirect

### Analytics Counters

The admin panel includes several real-time counters:

1. **Home Presence Counter** - Active users on home screen
2. **Returning Users Counter** - Users who have visited multiple times
3. **Instagram Counter** - Total Instagram IDs collected
4. **Phone Numbers Counter** - Total phone numbers collected

These counters are displayed in the admin header and update in real-time.

## Database Structure

### Firestore Collections Used

1. **`system/maintenance`**
   - Stores maintenance mode status
   - Session timer information
   - Default session duration

2. **`posts`**
   - Admin posts include `isAdmin: true` flag
   - Announcement posts include `isAnnouncement: true`
   - Custom author field for announcements

3. **`endings`**
   - Stores user submissions (Instagram, phone)
   - Used for analytics displays

4. **`returning_users`**
   - Tracks returning user analytics
   - Can be reset from admin panel

## Security Features

1. **Authentication:**
   - Hardcoded credentials (should be moved to environment variables in production)
   - Session-based authentication
   - Automatic session expiry

2. **Session Management:**
   - 24-hour default session duration
   - Session persistence across app restarts
   - Manual session extension capability

3. **Access Control:**
   - All admin routes check authentication status
   - Automatic redirect to login if session expired
   - Admin-only Firestore operations

## UI/UX Features

1. **Responsive Design:**
   - Adapts to desktop, tablet, and mobile screens
   - Dynamic font sizes and spacing
   - Collapsible sidebar for space optimization

2. **Real-time Updates:**
   - Live data streams for all displayed information
   - Instant feedback for admin actions
   - Status indicators for system state

3. **User Feedback:**
   - Success/error snackbars for all actions
   - Confirmation dialogs for destructive actions
   - Loading states for async operations

4. **Accessibility:**
   - Proper color contrast ratios
   - Clear typography hierarchy
   - Intuitive navigation structure

## Admin Workflow

### Initial Access
1. Navigate to admin login screen
2. Enter credentials (username: `hap`, password: `happyman`)
3. System creates 24-hour session
4. Redirect to admin dashboard

### Managing Posts
1. Navigate to "Posts" section via sidebar
2. View all posts with metadata
3. Click edit icon to modify post content
4. Click delete icon to remove post (with confirmation)
5. Changes reflect immediately in the app

### Adding Admin Posts
1. Navigate to "Add Post" section
2. Enter post content
3. Select floor and world
4. Optionally mark as announcement
5. Add custom author for announcements
6. Submit post

### System Maintenance
1. Navigate to "System Controls" section
2. Toggle maintenance mode switch
3. System prevents user access when enabled
4. Custom maintenance message displayed to users

### Session Management
1. Monitor remaining session time in sidebar
2. Click "Extend" to add 24 hours
3. Click "Logout" to end session
4. System auto-logs out on expiry

### Analytics Monitoring
1. View real-time counters in header
2. Check Instagram/phone submissions in System Controls
3. Monitor returning users count
4. Reset analytics data when needed

## Implementation Notes

### State Management
- Uses Flutter's `setState` for local UI state
- Firestore streams for real-time data
- SharedPreferences for session persistence

### Error Handling
- Try-catch blocks for all async operations
- User-friendly error messages
- Graceful degradation on failures

### Performance Optimizations
- Stream subscriptions properly disposed
- Lazy loading of data where appropriate
- Efficient widget rebuilds with proper state management

## Future Enhancements

### Recommended Improvements
1. **Security:**
   - Move credentials to secure environment variables
   - Implement proper role-based access control
   - Add two-factor authentication

2. **Features:**
   - Export functionality for analytics data
   - Bulk operations for posts
   - Admin activity logging
   - Customizable session durations

3. **UI/UX:**
   - Dark mode support
   - Keyboard shortcuts for common actions
   - Advanced filtering and search for posts
   - Data visualization for analytics

4. **Technical:**
   - Unit and integration tests
   - Error tracking and monitoring
   - Performance metrics
   - Offline capability with sync

## Testing Checklist

### Authentication
- [ ] Login with correct credentials
- [ ] Login with incorrect credentials
- [ ] Session expiry after 24 hours
- [ ] Session extension functionality
- [ ] Logout functionality
- [ ] Persistent login across app restarts

### Posts Management
- [ ] View all posts
- [ ] Edit post content
- [ ] Delete post with confirmation
- [ ] Real-time updates when posts change

### Add Post
- [ ] Create regular post
- [ ] Create announcement post
- [ ] Custom author for announcements
- [ ] Form validation
- [ ] Success/error feedback

### System Controls
- [ ] Toggle maintenance mode
- [ ] Start fresh timer
- [ ] Extend timer
- [ ] View Instagram submissions
- [ ] View phone submissions
- [ ] Reset returning user data

### UI/UX
- [ ] Responsive design on all screen sizes
- [ ] Sidebar collapse/expand
- [ ] Navigation between sections
- [ ] Real-time counter updates
- [ ] Error handling and user feedback

## Deployment Considerations

1. **Environment Variables:**
   - Admin credentials should be externalized
   - Firebase configuration should be environment-specific

2. **Security Rules:**
   - Firestore security rules should restrict admin operations
   - Implement proper authentication checks

3. **Monitoring:**
   - Set up logging for admin actions
   - Monitor session usage patterns
   - Track error rates

4. **Backup:**
   - Regular backups of admin-modified data
   - Audit trail for admin actions
   - Recovery procedures for accidental deletions