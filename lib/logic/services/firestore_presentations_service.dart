import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dance_club_comuna_8/logic/models/blog_post.dart';

class FirestorePresentationsService {
  final CollectionReference _presentationCollection =
      FirebaseFirestore.instance.collection('presentations');

  Future<List<BlogPost>> getPosts(
      {int limit = 10, DocumentSnapshot? startAfter}) async {
    Query query =
        _presentationCollection.orderBy('date', descending: true).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final querySnapshot = await query.get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return BlogPost.fromJson(data, doc.id);
    }).toList();
  }

  Future<BlogPost> addBlogPost(String title, String content, DateTime date,
      String imageUrl, List<String> videoUrls) async {
    final docRef = await _presentationCollection.add({
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'videoUrls': videoUrls,
    });

    return BlogPost(
      id: docRef.id,
      title: title,
      content: content,
      date: date,
      imageUrl: imageUrl,
      videoUrls: videoUrls,
    );
  }

  Future<BlogPost> updateBlogPost(String id, String title, String content,
      DateTime date, String imageUrl, List<String> videoUrls) async {
    await _presentationCollection.doc(id).update({
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'videoUrls': videoUrls,
    });

    return BlogPost(
      id: id,
      title: title,
      content: content,
      date: date,
      imageUrl: imageUrl,
      videoUrls: videoUrls,
    );
  }

  Future<void> deleteBlogPost(String id) async {
    await _presentationCollection.doc(id).delete();
  }

  Future<int> getPostCount() async {
    final querySnapshot = await _presentationCollection.get();
    return querySnapshot.size;
  }
}
