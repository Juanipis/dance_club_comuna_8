import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:dance_club_comuna_8/logic/models/event_attend.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          endDate: data['endDate'].toDate(),
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
    // get attendees count
    CollectionReference usersRef = doc.reference.collection('registered_users');
    QuerySnapshot snapshot = await usersRef.get();
    int attendeesCount = snapshot.docs.length;
    return Event(
      id: doc.id,
      attendes: attendeesCount,
      date: data['date'].toDate(),
      endDate: data['endDate'].toDate(),
      title: data['title'],
      description: data['description'],
      instructions: data['instructions'],
      address: data['address'],
      imageUrl: data['imageUrl'],
      maxAttendees: data['maxAttendees'],
    );
  }

  Future<(List<Event>, DocumentSnapshot?, bool)> getUpcomingEventsWithAttendees(
    DateTime startDate,
    DateTime endDate,
    int limit,
    DocumentSnapshot? lastDocument,
  ) async {
    Query query = _eventCollection
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .orderBy('date')
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    QuerySnapshot querySnapshot = await query.get();
    List<Event> events = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Get the registered_users collection reference
      CollectionReference registeredUsersCollection =
          doc.reference.collection('registered_users');

      // Get the number of attendees
      QuerySnapshot registeredUsersSnapshot =
          await registeredUsersCollection.get();
      int attendeesCount = registeredUsersSnapshot.docs.length;

      events.add(Event(
        id: doc.id,
        date: data['date'].toDate(),
        endDate: data['endDate'].toDate(),
        title: data['title'],
        description: data['description'],
        instructions: data['instructions'],
        address: data['address'],
        imageUrl: data['imageUrl'],
        maxAttendees: data['maxAttendees'],
        attendes: attendeesCount,
      ));
    }

    logger.d('Upcoming events: $events');
    bool hasMore = querySnapshot.docs.length == limit;
    DocumentSnapshot? lastVisibleDocument =
        querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;

    return (events, lastVisibleDocument, hasMore);
  }

  Future<void> addEvent(
      {required DateTime date,
      required DateTime endDate,
      required String title,
      required String description,
      required String instructions,
      required String address,
      required String imageUrl,
      required int maxAttendees}) async {
    logger.d('Adding event to firestore');
    try {
      await _eventCollection.add({
        'date': Timestamp.fromDate(date),
        'endDate': Timestamp.fromDate(endDate),
        'title': title,
        'description': description,
        'instructions': instructions,
        'address': address,
        'imageUrl': imageUrl,
        'maxAttendees': maxAttendees,
      });
      logger.d('Event added successfully');
    } catch (e) {
      logger.e('Error adding event: $e');
    }
  }

  Future<(bool, int)> updateEvent({
    required String id,
    DateTime? date,
    DateTime? endDate,
    String? title,
    String? description,
    String? instructions,
    String? address,
    String? imageUrl,
    int? maxAttendees,
  }) async {
    logger.d('Updating event by $id from firestore');
    // Error int instruction
    // 0: Event successfully updated
    // 1: Event does not exist
    // 2: Cannot update max attendees: There are already $currentAttendees attendees.
    // 3: Error updating event: $e

    // Verificar que el evento exista
    DocumentSnapshot doc = await _eventCollection.doc(id).get();
    if (!doc.exists) {
      logger.d('Event does not exist.');
      return (false, 1);
    }

    // Verificar la capacidad máxima de asistentes
    // Si el número de asistentes registrados es mayor a la nueva capacidad máxima, no se permite la actualización
    if (maxAttendees != null) {
      CollectionReference usersRef =
          _eventCollection.doc(id).collection('registered_users');
      QuerySnapshot snapshot = await usersRef.get();
      int currentAttendees = snapshot.docs.length;
      if (currentAttendees > maxAttendees) {
        logger.d(
            'Cannot update max attendees: There are already $currentAttendees attendees.');
        return (false, 2);
      }
    }
    try {
      Map<String, dynamic> data = {};
      if (date != null) data['date'] = Timestamp.fromDate(date);
      if (endDate != null) data['endDate'] = Timestamp.fromDate(endDate);
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (instructions != null) data['instructions'] = instructions;
      if (address != null) data['address'] = address;
      if (imageUrl != null) data['imageUrl'] = imageUrl;
      if (maxAttendees != null) data['maxAttendees'] = maxAttendees;

      await _eventCollection.doc(id).update(data);
      logger.d('Event updated successfully');
      return (true, 0);
    } catch (e) {
      logger.e('Error updating event: $e');
      return (false, 3);
    }
  }

  Future<void> removeEvent(String id) {
    logger.d('Removing event by $id from firestore');
    return _eventCollection.doc(id).delete();
  }

  Future<bool> registerUser(
      String eventId, String phoneNumber, String name) async {
    logger.d('Registering user $phoneNumber to event $eventId');
    DocumentReference eventDocRef = _eventCollection.doc(eventId);
    CollectionReference usersRef = eventDocRef.collection('registered_users');
    // get the ip of the user

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
        'timestamp': FieldValue.serverTimestamp(),
        'name': name,
        'attended': false,
      }, SetOptions(merge: true));
      logger.d('User registered successfully.');
      return true;
    } catch (e) {
      logger.e('Error during registration: $e');
      return false;
    }
  }

  Future<void> saveAttendeesAttendance(
      String eventId, List<EventAttend> attendees) async {
    logger.d('Saving attendees attendance for event $eventId');
    CollectionReference usersRef =
        _eventCollection.doc(eventId).collection('registered_users');

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (var attendee in attendees) {
      DocumentReference userDocRef = usersRef.doc(attendee.phoneNumber);
      batch.update(userDocRef, {'attended': attendee.attended});
    }

    try {
      await batch.commit();
      logger.d('Attendance saved successfully.');
    } catch (e) {
      logger.e('Error saving attendance: $e');
      rethrow;
    }
  }

  Future<List<EventAttend>> getEventAttendees(String eventId) async {
    logger.d('Getting attendees for event $eventId');
    List<EventAttend> attendees = [];
    CollectionReference usersRef =
        _eventCollection.doc(eventId).collection('registered_users');

    QuerySnapshot querySnapshot = await usersRef.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      attendees.add(EventAttend(
        phoneNumber: doc.id,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        name: data['name'],
        attended: data['attended'] ?? false,
      ));
    }

    logger.d('Attendees: $attendees');
    return attendees;
  }

  Future<bool> removeAttendee(String eventId, String phoneNumber) async {
    logger.d('Removing attendee $phoneNumber from event $eventId');
    CollectionReference usersRef =
        _eventCollection.doc(eventId).collection('registered_users');
    DocumentReference userDocRef = usersRef.doc(phoneNumber);

    try {
      await userDocRef.delete();
      logger.d('Attendee removed successfully.');
      return true;
    } catch (e) {
      logger.e('Error removing attendee: $e');
      // Aquí puedes manejar específicamente el error de autenticación si es necesario
      if (e is FirebaseAuthException && e.code == 'permission-denied') {
        logger.e(
            'Permission Denied: The user is not allowed to perform this operation.');
      }
      return false;
    }
  }

  Future<int> getEventAttendeesCount(String eventId) async {
    logger.d('Getting attendees count for event $eventId');
    CollectionReference usersRef =
        _eventCollection.doc(eventId).collection('registered_users');
    QuerySnapshot snapshot = await usersRef.get();
    return snapshot.docs.length;
  }
}
