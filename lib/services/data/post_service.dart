import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<void> addPost(String text, String world, String userId, {String? customAuthor}) async {
    // Validate required parameters to prevent null Firebase errors
    if (text.isEmpty) {
      throw ArgumentError('Post text cannot be empty');
    }

    final postData = {
      'confession': text,
      'world': world,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'isEdited': false,
      'editCount': 0,
    };

    // Add custom author if provided (for lobby nicknames)
    if (customAuthor != null && customAuthor.isNotEmpty) {
      postData['customAuthor'] = customAuthor;
    }

    await _firestore.collection('posts').add(postData);
  }


  Stream<QuerySnapshot> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // DEBUG: addReaction() method was REMOVED during Firebase optimization
  // This eliminates Firebase writes for reactions - reactions are now client-only

  /// Migration method: Update posts from gender-based to world-based schema
  Future<void> migrateGenderToWorldSchema() async {
    final batch = _firestore.batch();
    
    // Get all posts that still use the gender field
    final postsQuery = await _firestore
        .collection('posts')
        .where('gender', isEqualTo: 'girl')
        .get();

    for (var doc in postsQuery.docs) {
      final postRef = _firestore.collection('posts').doc(doc.id);
      batch.update(postRef, {
        'world': 'Girl Meets College',
        'gender': FieldValue.delete(), // Remove the old gender field
      });
    }

    // Also migrate any 'boy' posts if they exist (though unlikely in current system)
    final boyPostsQuery = await _firestore
        .collection('posts')
        .where('gender', isEqualTo: 'boy')
        .get();

    for (var doc in boyPostsQuery.docs) {
      final postRef = _firestore.collection('posts').doc(doc.id);
      batch.update(postRef, {
        'world': 'Guy Meets College',
        'gender': FieldValue.delete(), // Remove the old gender field
      });
    }

    // Execute the batch update
    await batch.commit();
  }

  /// Get posts for a specific world
  Stream<QuerySnapshot> getPostsStreamForWorld(String world) {
    return _firestore
        .collection('posts')
        .where('world', isEqualTo: world)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

}