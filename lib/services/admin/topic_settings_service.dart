import 'package:cloud_firestore/cloud_firestore.dart';

class TopicSettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _worldsCollection = 'worlds';

  String? _extractTopic(DocumentSnapshot snapshot) {
    return (snapshot.exists && snapshot.data() != null)
        ? (snapshot.data()! as Map<String, dynamic>)['topicOfDay'] as String?
        : null;
  }

  Stream<String?> getTopicStream(String worldId) {
    return _firestore
        .collection(_worldsCollection)
        .doc(worldId)
        .snapshots()
        .map(_extractTopic);
  }

  Future<void> updateTopic(String worldId, String topic) async {
    await _firestore
        .collection(_worldsCollection)
        .doc(worldId)
        .set({'topicOfDay': topic}, SetOptions(merge: true));
  }

  Future<String?> getTopic(String worldId) async {
    final snapshot = await _firestore
        .collection(_worldsCollection)
        .doc(worldId)
        .get();
    return _extractTopic(snapshot);
  }
}