import 'package:equatable/equatable.dart';

abstract class PresentationsEvent extends Equatable {
  const PresentationsEvent();
}

class GetPresentationsEvent extends PresentationsEvent {
  @override
  List<Object> get props => [];
}

class AddPresentationEvent extends PresentationsEvent {
  final String title;
  final String content;
  final DateTime date;
  final String imageUrl;

  const AddPresentationEvent(
      {required this.title,
      required this.content,
      required this.date,
      required this.imageUrl});

  @override
  List<Object?> get props => [title, content, date];
}

class RefreshPresentationsEvent extends PresentationsEvent {
  @override
  List<Object> get props => [];
}

class UpdatePresentationEvent extends PresentationsEvent {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String imageUrl;

  const UpdatePresentationEvent(
      {required this.id,
      required this.title,
      required this.content,
      required this.date,
      required this.imageUrl});

  @override
  List<Object?> get props => [id, title, content, date];
}

class DeletePresentationEvent extends PresentationsEvent {
  final String id;

  const DeletePresentationEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
