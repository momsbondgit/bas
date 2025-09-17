import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user/bot_user.dart';

class BotSettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _worldsCollection = 'worlds';

  Stream<List<BotUser>> getBotStream(String worldId, int tableNumber) {
    return _firestore
        .collection(_worldsCollection)
        .doc(worldId)
        .collection('botTable$tableNumber')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BotUser.fromMap(doc.data());
      }).toList();
    });
  }

  Future<void> updateBot(String worldId, int tableNumber, BotUser bot) async {
    await _firestore
        .collection(_worldsCollection)
        .doc(worldId)
        .collection('botTable$tableNumber')
        .doc(bot.botId)
        .set(bot.toMap());
  }


  Future<List<BotUser>> getBots(String worldId, int tableNumber) async {
    final snapshot = await _firestore
        .collection(_worldsCollection)
        .doc(worldId)
        .collection('botTable$tableNumber')
        .get();

    return snapshot.docs.map((doc) => BotUser.fromMap(doc.data())).toList();
  }
}