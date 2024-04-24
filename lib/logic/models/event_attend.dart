class EventAttend {
  String phoneNumber;
  DateTime timestamp;

  EventAttend({
    required this.phoneNumber,
    required this.timestamp,
  });

  EventAttend copyWith({
    String? phoneNumber,
    DateTime? timestamp,
  }) {
    return EventAttend(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
