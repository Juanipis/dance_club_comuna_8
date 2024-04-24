import 'package:equatable/equatable.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();
}

class LoadEventEventById extends EventEvent {
  final String id;

  const LoadEventEventById({required this.id});

  @override
  List<Object?> get props => [id];
}

class InserEventEvent extends EventEvent {
  final DateTime date;
  final String title;
  final String description;
  final String instructions;
  final String address;
  final String imageUrl;
  final int maxAttendees;

  const InserEventEvent(
      {required this.date,
      required this.title,
      required this.description,
      required this.instructions,
      required this.address,
      required this.imageUrl,
      required this.maxAttendees});

  @override
  List<Object> get props =>
      [date, title, description, instructions, address, imageUrl];
}

class UpdateEventEvent extends EventEvent {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final String instructions;
  final String address;
  final String imageUrl;
  final int maxAttendees;

  const UpdateEventEvent(
      {required this.id,
      required this.date,
      required this.title,
      required this.description,
      required this.instructions,
      required this.address,
      required this.imageUrl,
      required this.maxAttendees});

  @override
  List<Object> get props =>
      [id, date, title, description, instructions, address, imageUrl];
}

class DeleteEventEvent extends EventEvent {
  final String id;

  const DeleteEventEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class LoadUpcomingEventsEvent extends EventEvent {
  final DateTime endTime;

  const LoadUpcomingEventsEvent({required this.endTime});

  @override
  List<Object> get props => [];
}

class RegisterUserEvent extends EventEvent {
  final String eventId;
  final String phoneNumber;
  const RegisterUserEvent({required this.eventId, required this.phoneNumber});
  @override
  List<Object?> get props => [eventId, phoneNumber];
}

// For event attendees
class LoadEventAttendeesEvent extends EventEvent {
  final String eventId;

  const LoadEventAttendeesEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}
