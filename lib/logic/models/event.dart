import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String id;
  DateTime date;
  String title;
  String description;
  String instructions;
  String address;
  String imageUrl;
  int maxAttendees;
  int attendes = 0;

  Event({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.instructions,
    required this.address,
    required this.imageUrl,
    required this.maxAttendees,
  });

  Event copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? description,
    String? instructions,
    String? address,
    String? imageUrl,
    int? attendees,
    int? maxAttendees,
  }) {
    return Event(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      maxAttendees: maxAttendees ?? this.maxAttendees,
    );
  }

  Map<String, dynamic> toJsonNoId() {
    return {
      'date': Timestamp.now(),
      'title': title,
      'description': description,
      'instructions': instructions,
      'address': address,
      'imageUrl': imageUrl,
      'maxAttendees': maxAttendees,
    };
  }
}
