import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';

class FirestoreService {
  final CollectionReference _eventCollection =
      FirebaseFirestore.instance.collection('events');

  Stream<List<Event>> getEvents() {
    return _eventCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Event(
          id: doc.id,
          date: data['date'].toDate(),
          title: data['title'],
          description: data['description'],
          instructions: data['instructions'],
          address: data['address'],
          imageUrl: data['imageUrl'],
          attendees: data['attendees'],
        );
      }).toList();
    });
  }

  Future<Event> getEventById(String id) async {
    DocumentSnapshot doc = await _eventCollection.doc(id).get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      date: data['date'].toDate(),
      title: data['title'],
      description: data['description'],
      instructions: data['instructions'],
      address: data['address'],
      imageUrl: data['imageUrl'],
      attendees: data['attendees'],
    );
  }

  Future<void> addEvent(
      {required DateTime date,
      required String title,
      required String description,
      required String instructions,
      required String address,
      required String imageUrl,
      required int attendees}) {
    return _eventCollection.add({
      'date': date.toString(),
      'title': title,
      'description': description,
      'instructions': instructions,
      'address': address,
      'imageUrl': imageUrl,
      'attendees': attendees,
    });
  }

  Future<void> updateEvent({
    required String id,
    DateTime? date,
    String? title,
    String? description,
    String? instructions,
    String? address,
    String? imageUrl,
    int? attendees,
  }) {
    return _eventCollection.doc(id).update({
      if (date != null) 'date': date.toString(),
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (instructions != null) 'instructions': instructions,
      if (address != null) 'address': address,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (attendees != null) 'attendees': attendees,
    });
  }

  Future<void> removeEvent(String id) {
    return _eventCollection.doc(id).delete();
  }
}
