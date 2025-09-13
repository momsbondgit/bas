import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/local_storage_service.dart';

class SimpleAdminService {
  static const String _collectionName = 'system';
  static const String _settingsDocumentId = 'admin_settings';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get admin settings from Firestore
  Future<AdminSettings> getAdminSettings() async {
    final doc = await _firestore
        .collection(_collectionName)
        .doc(_settingsDocumentId)
        .get();

    if (!doc.exists) {
      await _initializeAdminSettings();
      return AdminSettings(
        allowReturningUsers: true,
        lastUpdated: DateTime.now(),
      );
    }

    final data = doc.data() as Map<String, dynamic>;
    return AdminSettings.fromMap(data);
  }

  /// Get admin settings stream for real-time updates
  Stream<AdminSettings> getAdminSettingsStream() {
    return _firestore
        .collection(_collectionName)
        .doc(_settingsDocumentId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return AdminSettings(
          allowReturningUsers: true,
          lastUpdated: DateTime.now(),
        );
      }

      final data = doc.data() as Map<String, dynamic>;
      return AdminSettings.fromMap(data);
    });
  }

  /// Set returning users access toggle
  Future<void> setReturningUsersAccess({required bool allowed}) async {
    final settings = AdminSettings(
      allowReturningUsers: allowed,
      lastUpdated: DateTime.now(),
    );

    await _firestore
        .collection(_collectionName)
        .doc(_settingsDocumentId)
        .set(settings.toMap(), SetOptions(merge: true));
  }

  /// Initialize admin settings document if it doesn't exist
  Future<void> _initializeAdminSettings() async {
    final initialSettings = AdminSettings(
      allowReturningUsers: true,
      lastUpdated: DateTime.now(),
    );

    await _firestore
        .collection(_collectionName)
        .doc(_settingsDocumentId)
        .set(initialSettings.toMap());
  }

  /// Get bot table statistics
  Future<Map<String, int>> getBotTableStats() async {
    // This is a local storage based implementation since we don't track users centrally
    // In a real implementation, you'd query a users collection in Firestore

    // For now, return mock data or implement based on your needs
    return {
      'table1Count': 0, // Would need to implement proper user tracking
      'table2Count': 0, // Would need to implement proper user tracking
      'totalUsers': 0,
    };
  }

  /// Get vibe check completion stats
  Future<Map<String, dynamic>> getVibeCheckStats() async {
    // Mock implementation - would need proper user tracking
    return {
      'completedCount': 0,
      'totalAttempts': 0,
      'completionRate': 0.0,
    };
  }

  /// Check if returning users are allowed to enter worlds
  Future<bool> areReturningUsersAllowed() async {
    try {
      final settings = await getAdminSettings();
      return settings.allowReturningUsers;
    } catch (e) {
      // Default to allow if there's an error
      return true;
    }
  }
}

/// Data class for admin settings
class AdminSettings {
  final bool allowReturningUsers;
  final DateTime lastUpdated;

  const AdminSettings({
    required this.allowReturningUsers,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'allowReturningUsers': allowReturningUsers,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  factory AdminSettings.fromMap(Map<String, dynamic> map) {
    return AdminSettings(
      allowReturningUsers: map['allowReturningUsers'] ?? true,
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AdminSettings &&
        other.allowReturningUsers == allowReturningUsers &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode => allowReturningUsers.hashCode ^ lastUpdated.hashCode;

  @override
  String toString() => 'AdminSettings(allowReturningUsers: $allowReturningUsers, lastUpdated: $lastUpdated)';
}