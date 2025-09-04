import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<void> addPost(String text, int floor, String world) async {
    // Validate required parameters to prevent null Firebase errors
    if (text.isEmpty) {
      throw ArgumentError('Post text cannot be empty');
    }
    
    await _firestore.collection('posts').add({
      'confession': text,
      'floor': floor,
      'world': world,
      'createdAt': FieldValue.serverTimestamp(),
      'isEdited': false,
      'editCount': 0,
    });
  }

  /// Admin post creation with unrestricted privileges
  Future<void> addAdminPost({
    required String text,
    required int floor,
    required String world,
    String? customAuthor,
    bool? isAnnouncement,
  }) async {
    // Validate required parameters to prevent null Firebase errors
    if (text.isEmpty) {
      throw ArgumentError('Post text cannot be empty');
    }
    if (world.isEmpty) {
      throw ArgumentError('World cannot be empty');
    }
    
    final postData = <String, dynamic>{
      'confession': text,
      'floor': floor,
      'world': world,
      'createdAt': FieldValue.serverTimestamp(),
      'isEdited': false,
      'editCount': 0,
      'isAdminPost': true,
      'createdBy': 'admin',
    };

    // Optional custom author override
    if (customAuthor != null && customAuthor.isNotEmpty) {
      postData['customAuthor'] = customAuthor;
    }

    // Mark as announcement for special handling
    if (isAnnouncement == true) {
      postData['isAnnouncement'] = true;
      postData['priority'] = 'high';
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
  
  /// Edit a post's text content (simplified)
  Future<void> editPost(String postId, String newText) async {
    await _firestore.collection('posts').doc(postId).update({
      'confession': newText,
      'isEdited': true,
      'lastEditedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get a specific post by ID
  Future<DocumentSnapshot?> getPost(String postId) async {
    final doc = await _firestore.collection('posts').doc(postId).get();
    return doc.exists ? doc : null;
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

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