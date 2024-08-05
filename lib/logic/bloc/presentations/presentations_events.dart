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

  const AddPresentationEvent(
      {required this.title, required this.content, required this.date});

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

  const UpdatePresentationEvent(
      {required this.id,
      required this.title,
      required this.content,
      required this.date});

  @override
  List<Object?> get props => [id, title, content, date];
}
