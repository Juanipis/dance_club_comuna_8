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
      return BlogPost(
        id: doc.id,
        title: data['title'],
        content: data['content'],
        date: (data['date'] as Timestamp).toDate(),
      );
    }).toList();
  }

  Future<BlogPost> addBlogPost(
      String title, String content, DateTime date) async {
    final docRef = await _presentationCollection.add({
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
    });

    return BlogPost(
      id: docRef.id,
      title: title,
      content: content,
      date: date,
    );
  }
}
