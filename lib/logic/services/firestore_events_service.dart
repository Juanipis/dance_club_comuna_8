import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:logger/logger.dart';

class FirestoreEventsService {
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

  Future<List<Event>> getUpcomingEvents(
      DateTime startDate, DateTime endDate) async {
    logger.d('Getting upcoming events from firestore');
    List<Event> events = [];

    QuerySnapshot querySnapshot = await _eventCollection
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .get();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      events.add(Event(
        id: doc.id,
        date: data['date'].toDate(),
        title: data['title'],
        description: data['description'],
        instructions: data['instructions'],
        address: data['address'],
        imageUrl: data['imageUrl'],
        attendees: data['attendees'],
        maxAttendees: data['maxAttendees'],
      ));
    }

    logger.d('Upcoming events: $events');
    return events;
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
      'date': Timestamp.fromDate(date),
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
      if (date != null) 'date': Timestamp.fromDate(date),
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

  Future<bool> registerUser(String eventId, String phoneNumber) async {
    logger.d('Registering user $phoneNumber to event $eventId');
    DocumentReference eventDocRef = _eventCollection.doc(eventId);
    DocumentSnapshot eventDoc = await eventDocRef.get();

    // Check if the document exists
    if (!eventDoc.exists) {
      logger.d('Event does not exist.');
      return false;
    }

    Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;
    if (eventData['attendees'] >= eventData['maxAttendees']) {
      logger.d('Event is full.');
      return false;
    }

    // Check if the user is already registered
    DocumentSnapshot userDoc =
        await eventDocRef.collection('registered_users').doc(phoneNumber).get();
    if (userDoc.exists) {
      logger.d('User already registered.');
      return false;
    }

    // Register the user if not already registered
    await eventDocRef.collection('registered_users').doc(phoneNumber).set({
      'phoneNumber': phoneNumber,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await eventDocRef.update({'attendees': FieldValue.increment(1)});
    logger.d('User registered successfully.');
    return true;
  }
}
