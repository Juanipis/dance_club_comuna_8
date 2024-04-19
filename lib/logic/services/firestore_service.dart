import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:logger/logger.dart';

class FirestoreService {
  final logger = Logger();
  final CollectionReference _eventCollection =
      FirebaseFirestore.instance.collection('events');

  Stream<List<Event>> getEvents() {
    logger.d('Getting events from firstore');
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
          maxAttendees: data['maxAttendees'],
        );
      }).toList();
    });
  }

  Future<Event> getEventById(String id) async {
    logger.d('Getting event by $id from firestore');
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
      maxAttendees: data['maxAttendees'],
    );
  }

  Future<void> addEvent(
      {required DateTime date,
      required String title,
      required String description,
      required String instructions,
      required String address,
      required String imageUrl,
      required int attendees,
      required int maxAttendees}) {
    logger.d('Adding event to firestore');
    return _eventCollection.add({
      'date': date.toString(),
      'title': title,
      'description': description,
      'instructions': instructions,
      'address': address,
      'imageUrl': imageUrl,
      'attendees': attendees,
      'maxAttendees': maxAttendees,
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
    int? maxAttendees,
  }) {
    logger.d('Updating event by $id from firestore');
    return _eventCollection.doc(id).update({
      if (date != null) 'date': date.toString(),
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (instructions != null) 'instructions': instructions,
      if (address != null) 'address': address,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (attendees != null) 'attendees': attendees,
      if (maxAttendees != null) 'maxAttendees': maxAttendees,
    });
  }

  Future<void> removeEvent(String id) {
    logger.d('Removing event by $id from firestore');
    return _eventCollection.doc(id).delete();
  }
}
