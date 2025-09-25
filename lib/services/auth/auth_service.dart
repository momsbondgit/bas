import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/local_storage_service.dart';

class AuthService {
  final LocalStorageService _localStorage = LocalStorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _accountsCollection = 'accounts';
  
  // World-specific access codes
  static const Map<String, String> _worldAccessCodes = {
    'girl-meets-college': '789',
    'guy-meets-college': '456',
  };

  /// Get existing anon ID or create a new one
  Future<String> getOrCreateAnonId() async {
    String? existingId = await _localStorage.getAnonId();
    
    if (existingId != null) {
      return existingId;
    }
    
    // Generate new anon ID
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = random.nextInt(999999).toString().padLeft(6, '0');
    final anonId = 'anon_${timestamp}_$randomSuffix';
    
    await _localStorage.setAnonId(anonId);
    return anonId;
  }

  /// Check if user has a persisted account locally
  Future<bool> isLoggedIn() async {
    final hasAccount = await _localStorage.getHasAccount();
    return hasAccount;
  }

  /// Check if user is authenticated for a specific world
  Future<bool> isLoggedInForWorld(String worldId) async {
    final hasAccount = await _localStorage.getHasAccount();
    if (!hasAccount) return false;
    
    final authenticatedWorldId = await _localStorage.getAuthenticatedWorldId();
    return authenticatedWorldId == worldId;
  }

  /// Get stored account data from localStorage
  Future<Map<String, String>?> getStoredAccount() async {
    final hasAccount = await _localStorage.getHasAccount();
    if (!hasAccount) return null;
    
    final accessCode = await _localStorage.getAccessCode();
    final nickname = await _localStorage.getNickname();
    final anonId = await _localStorage.getAnonId();
    
    if (accessCode != null && nickname != null && anonId != null) {
      return {
        'anonId': anonId,
        'accessCode': accessCode,
        'nickname': nickname,
      };
    }
    
    return null;
  }

  /// Create account with access code and nickname
  Future<bool> createAccount(String accessCode, String nickname) async {
    return _createAccountInternal(accessCode, nickname, null);
  }

  /// Create account with world-specific access code and nickname
  Future<bool> createAccountForWorld(String accessCode, String nickname, String worldId) async {
    // Validate access code for the specific world
    final correctCode = _worldAccessCodes[worldId];
    if (correctCode == null || accessCode != correctCode) {
      return false;
    }

    return _createAccountInternal(accessCode, nickname, worldId);
  }

  /// Internal method to create account with optional world ID
  Future<bool> _createAccountInternal(String accessCode, String nickname, String? worldId) async {
    try {
      final anonId = await getOrCreateAnonId();


      // Check if document already exists (e.g., from bot assignment)
      final existingDoc = await _firestore.collection(_accountsCollection).doc(anonId).get();
      if (existingDoc.exists) {
      } else {
      }

      // Build Firebase data
      final firebaseData = {
        'anonId': anonId,
        'accessCode': accessCode,
        'nickname': nickname,
        'worldVisitCount': 1,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (worldId != null) {
        firebaseData['worldId'] = worldId;
      }

      // Store in Firebase with MERGE to preserve existing bot assignment data
      await _firestore.collection(_accountsCollection).doc(anonId).set(firebaseData, SetOptions(merge: true));

      // Store locally
      await _localStorage.setAccessCode(accessCode);
      await _localStorage.setNickname(nickname);
      await _localStorage.setHasAccount(true);

      if (worldId != null) {
        await _localStorage.setAuthenticatedWorldId(worldId);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear local account data (logout)
  Future<void> clearAccount() async {
    await _localStorage.setAccessCode('');
    await _localStorage.setNickname('');
    await _localStorage.setHasAccount(false);
    await _localStorage.setAuthenticatedWorldId('');
  }

  /// Generic method to increment any metric field
  Future<void> _incrementMetric(String userId, String fieldName) async {
    await _firestore.collection(_accountsCollection).doc(userId).set({
      fieldName: FieldValue.increment(1),
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Increment total sessions when user starts a game
  Future<void> incrementTotalSessions(String userId) async {
    await _incrementMetric(userId, 'totalSessions');
  }

  /// Increment completed sessions when user reaches session end
  Future<void> incrementSessionsCompleted(String userId) async {
    await _incrementMetric(userId, 'sessionsCompleted');
  }

  /// Increment reactions given when user clicks a reaction button
  Future<void> incrementReactionsGiven(String userId) async {
    await _incrementMetric(userId, 'reactionsGiven');
  }
  
  /// Track when a user visits a world and increment their return count
  Future<void> trackWorldVisit(String anonId, String worldId) async {
    try {
      final docRef = _firestore.collection(_accountsCollection).doc(anonId);

      // Increment the worldVisitCount field and update lastVisitDate
      await docRef.update({
        'worldVisitCount': FieldValue.increment(1),
        'lastVisitDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // If document doesn't exist or field doesn't exist, create/set it
      try {
        await _firestore.collection(_accountsCollection).doc(anonId).set({
          'worldVisitCount': 1,
          'lastVisitDate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e2) {
        // Silently fail if unable to track
      }
    }
  }

  /// Check if user has visited today (same calendar day)
  Future<bool> hasVisitedToday(String anonId, String worldId) async {
    try {
      final doc = await _firestore.collection(_accountsCollection).doc(anonId).get();
      if (!doc.exists) {
        return false;
      }

      final data = doc.data();
      final lastVisitTimestamp = data?['lastVisitDate'] as Timestamp?;

      if (lastVisitTimestamp == null) {
        return false;
      }

      final lastVisitDate = lastVisitTimestamp.toDate();
      final now = DateTime.now();

      // Check if it's the same calendar day
      return lastVisitDate.year == now.year &&
             lastVisitDate.month == now.month &&
             lastVisitDate.day == now.day;
    } catch (e) {
      // If any error occurs, allow access (fail open)
      return false;
    }
  }

  /// Get user's world visit count
  Future<int> getUserWorldVisitCount(String anonId) async {
    try {
      final doc = await _firestore.collection(_accountsCollection).doc(anonId).get();
      if (doc.exists) {
        final data = doc.data();
        return (data?['worldVisitCount'] ?? 0) as int;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Store goodbye message when user submits one
  Future<void> storeGoodbyeMessage(String anonId, String message) async {
    try {
      await _firestore.collection(_accountsCollection).doc(anonId).set({
        'goodbyeMessage': message,
        'goodbyeMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Silently fail - don't disrupt user experience
    }
  }

  // ============= LOBBY MANAGEMENT METHODS =============

  /// Join a lobby for a specific world
  Future<void> joinLobby(String worldId, String username) async {
    final userId = await getOrCreateAnonId();

    print('[AUTH DEBUG] User $userId joining lobby $worldId with username: $username');

    try {
      // Get the current lobby state
      final lobbyDoc = await _firestore.collection('lobbies').doc(worldId).get();

      if (lobbyDoc.exists) {
        final data = lobbyDoc.data();
        final isStarted = data?['isStarted'] ?? false;
        final existingUsers = data?['users'] as Map<String, dynamic>? ?? {};

        print('[AUTH DEBUG] Existing lobby found with users: $existingUsers, isStarted: $isStarted');

        if (isStarted) {
          // Reset lobby if it was started
          print('[AUTH DEBUG] Resetting started lobby');
          await _firestore.collection('lobbies').doc(worldId).set({
            'users': {userId: username},
            'isStarted': false,
            'lastActivity': FieldValue.serverTimestamp(),
          });
        } else {
          // Add user to existing lobby
          existingUsers[userId] = username;
          print('[AUTH DEBUG] Adding user to existing lobby, new users: $existingUsers');
          await _firestore.collection('lobbies').doc(worldId).set({
            'users': existingUsers,
            'isStarted': false,
            'lastActivity': FieldValue.serverTimestamp(),
          });
        }
      } else {
        // Create new lobby
        print('[AUTH DEBUG] Creating new lobby with user $userId');
        await _firestore.collection('lobbies').doc(worldId).set({
          'users': {userId: username},
          'isStarted': false,
          'lastActivity': FieldValue.serverTimestamp(),
        });
      }
      print('[AUTH DEBUG] User $userId successfully added to lobby $worldId in Firebase');
    } catch (e) {
      print('[AUTH DEBUG] Error joining lobby: $e');
      throw e;
    }

    // Store username locally
    await _localStorage.setNickname(username);
    print('[AUTH DEBUG] Username stored locally for user $userId');
  }

  /// Get stream of users in lobby
  Stream<Map<String, String>> getLobbyUsersStream(String worldId) {
    print('[AUTH DEBUG] Creating lobby users stream for world: $worldId');
    return _firestore
        .collection('lobbies')
        .doc(worldId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        print('[AUTH DEBUG] Lobby users stream - document does not exist for world: $worldId');
        return {};
      }
      final data = snapshot.data();
      final users = data?['users'] as Map<String, dynamic>? ?? {};
      print('[AUTH DEBUG] Lobby users stream update for world $worldId: users = $users');
      return users.cast<String, String>();
    });
  }

  /// Start the lobby and mark it as started
  Future<void> startLobby(String worldId, List<String> userIds) async {
    print('[AUTH DEBUG] Starting lobby $worldId with active users: $userIds');
    await _firestore.collection('lobbies').doc(worldId).update({
      'isStarted': true,
      'startedAt': FieldValue.serverTimestamp(),
      'activeUserIds': userIds,
    });
    print('[AUTH DEBUG] Lobby $worldId marked as started in Firebase successfully');
  }

  /// Leave the lobby
  Future<void> leaveLobby(String worldId) async {
    final userId = await getOrCreateAnonId();

    await _firestore.collection('lobbies').doc(worldId).update({
      'users.$userId': FieldValue.delete(),
    });
  }

  /// Check if lobby is started
  Stream<bool> getLobbyStartedStream(String worldId) {
    print('[AUTH DEBUG] Creating lobby started stream for world: $worldId');
    return _firestore
        .collection('lobbies')
        .doc(worldId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        print('[AUTH DEBUG] Lobby started stream - document does not exist for world: $worldId');
        return false;
      }
      final data = snapshot.data();
      final isStarted = data?['isStarted'] ?? false;
      print('[AUTH DEBUG] Lobby started stream update for world $worldId: isStarted = $isStarted');
      return isStarted;
    });
  }

  /// Get active user IDs from lobby (those who were there when Start was pressed)
  Future<List<String>> getActiveLobbyUsers(String worldId) async {
    print('[AUTH DEBUG] Getting active lobby users for world: $worldId');
    final doc = await _firestore.collection('lobbies').doc(worldId).get();
    if (!doc.exists) {
      print('[AUTH DEBUG] Lobby document does not exist for world: $worldId');
      return [];
    }
    final data = doc.data();
    final activeUserIds = data?['activeUserIds'] as List<dynamic>? ?? [];
    print('[AUTH DEBUG] Found active lobby users: $activeUserIds');
    return activeUserIds.cast<String>();
  }
}