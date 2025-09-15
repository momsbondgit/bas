import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceService {
  static const String _collectionName = 'system';
  static const String _documentId = 'maintenance';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get maintenance status from Firestore
  Future<MaintenanceStatus> getMaintenanceStatus() async {
    final doc = await _firestore
        .collection(_collectionName)
        .doc(_documentId)
        .get();

    if (!doc.exists) {
      await _initializeMaintenanceDocument();
      return _getDefaultMaintenanceStatus();
    }

    final data = doc.data() as Map<String, dynamic>;
    return MaintenanceStatus.fromMap(data);
  }

  /// Get maintenance status stream for real-time updates
  Stream<MaintenanceStatus> getMaintenanceStatusStream() {
    return _firestore
        .collection(_collectionName)
        .doc(_documentId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return _getDefaultMaintenanceStatus();
      }

      final data = doc.data() as Map<String, dynamic>;
      return MaintenanceStatus.fromMap(data);
    });
  }

  /// Set maintenance mode status (Admin only)
  Future<void> setMaintenanceMode({required bool enabled}) async {
    await _updateMaintenanceField('isEnabled', enabled);
  }

  /// Set returning user blocking status (Admin only)
  Future<void> setBlockReturningUsers({required bool enabled}) async {
    await _updateMaintenanceField('blockReturningUsers', enabled);
  }

  /// Updates a maintenance field with timestamp
  Future<void> _updateMaintenanceField(String field, bool value) async {
    await _firestore
        .collection(_collectionName)
        .doc(_documentId)
        .set({
          field: value,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Returns default maintenance status
  MaintenanceStatus _getDefaultMaintenanceStatus() {
    return const MaintenanceStatus(
      isEnabled: false,
      blockReturningUsers: false,
      lastUpdated: null,
    );
  }

  /// Initialize maintenance document if it doesn't exist
  Future<void> _initializeMaintenanceDocument() async {
    const initialStatus = MaintenanceStatus(
      isEnabled: false,
      blockReturningUsers: false,
      lastUpdated: null,
    );

    await _firestore
        .collection(_collectionName)
        .doc(_documentId)
        .set(initialStatus.toMap());
  }
}

/// Data class for maintenance status
class MaintenanceStatus {
  final bool isEnabled;
  final bool blockReturningUsers;
  final DateTime? lastUpdated;

  const MaintenanceStatus({
    required this.isEnabled,
    required this.blockReturningUsers,
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'blockReturningUsers': blockReturningUsers,
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    };
  }

  factory MaintenanceStatus.fromMap(Map<String, dynamic> map) {
    return MaintenanceStatus(
      isEnabled: map['isEnabled'] ?? false,
      blockReturningUsers: map['blockReturningUsers'] ?? false,
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MaintenanceStatus &&
        other.isEnabled == isEnabled &&
        other.blockReturningUsers == blockReturningUsers &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode => isEnabled.hashCode ^ blockReturningUsers.hashCode ^ lastUpdated.hashCode;

  @override
  String toString() => 'MaintenanceStatus(isEnabled: $isEnabled, lastUpdated: $lastUpdated)';
}

