class EventAttend {
  String name;
  String phoneNumber;
  DateTime timestamp;
  bool attended;

  EventAttend({
    required this.phoneNumber,
    required this.timestamp,
    required this.name,
    this.attended = false,
  });

  EventAttend copyWith({
    String? phoneNumber,
    DateTime? timestamp,
    String? name,
    bool? attended,
  }) {
    return EventAttend(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      timestamp: timestamp ?? this.timestamp,
      name: name ?? this.name,
      attended: attended ?? this.attended,
    );
  }
}
