class EventAttend {
  String name;
  String phoneNumber;
  DateTime timestamp;

  EventAttend({
    required this.phoneNumber,
    required this.timestamp,
    required this.name,
  });

  EventAttend copyWith({
    String? phoneNumber,
    DateTime? timestamp,
    String? name,
  }) {
    return EventAttend(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      timestamp: timestamp ?? this.timestamp,
      name: name ?? this.name,
    );
  }
}
