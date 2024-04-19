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
  final int attendees;

  const InserEventEvent(
      {required this.date,
      required this.title,
      required this.description,
      required this.instructions,
      required this.address,
      required this.imageUrl,
      required this.attendees});

  @override
  List<Object> get props =>
      [date, title, description, instructions, address, imageUrl, attendees];
}

class UpdateEventEvent extends EventEvent {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final String instructions;
  final String address;
  final String imageUrl;
  final int attendees;

  const UpdateEventEvent(
      {required this.id,
      required this.date,
      required this.title,
      required this.description,
      required this.instructions,
      required this.address,
      required this.imageUrl,
      required this.attendees});

  @override
  List<Object> get props => [
        id,
        date,
        title,
        description,
        instructions,
        address,
        imageUrl,
        attendees
      ];
}

class DeleteEventEvent extends EventEvent {
  final String id;

  const DeleteEventEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
