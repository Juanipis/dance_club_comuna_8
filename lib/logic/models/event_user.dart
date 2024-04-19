class EventUsers {
  String id;
  String eventId;
  List<String> userPhones;

  EventUsers({
    required this.id,
    required this.eventId,
    required this.userPhones,
  });

  EventUsers copyWith({
    String? id,
    String? eventId,
    List<String>? userPhones,
  }) {
    return EventUsers(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userPhones: userPhones ?? this.userPhones,
    );
  }
}
