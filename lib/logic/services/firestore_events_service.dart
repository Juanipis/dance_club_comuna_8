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
      required int maxAttendees}) {
    logger.d('Adding event to firestore');
    return _eventCollection.add({
      'date': Timestamp.fromDate(date),
      'title': title,
      'description': description,
      'instructions': instructions,
      'address': address,
      'imageUrl': imageUrl,
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
    CollectionReference usersRef = eventDocRef.collection('registered_users');

    // Verificar que el evento exista
    DocumentSnapshot eventDoc = await eventDocRef.get();
    if (!eventDoc.exists) {
      logger.d('Event does not exist.');
      return false;
    }

    // Contar el número de asistentes registrados de forma más eficiente
    try {
      QuerySnapshot snapshot = await usersRef.get();
      int currentAttendees = snapshot.docs.length;

      int maxAttendees =
          (eventDoc.data() as Map<String, dynamic>)['maxAttendees'] as int;
      if (currentAttendees >= maxAttendees) {
        logger.d('Event is full.');
        return false;
      }

      // Intentar registrar al usuario
      DocumentReference userDocRef = usersRef.doc(phoneNumber);
      await userDocRef.set({
        'phone_number': phoneNumber,
        'timestamp': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
      logger.d('User registered successfully.');
      return true;
    } catch (e) {
      logger.e('Error during registration: $e');
      return false;
    }
  }
}
