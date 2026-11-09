import 'package:equatable/equatable.dart';

abstract class MemberEvent extends Equatable {
  const MemberEvent();
}

class LoadMembersEvent extends MemberEvent {
  const LoadMembersEvent();

  @override
  List<Object> get props => [];
}

class AddMemberEvent extends MemberEvent {
  final String name;
  final String role;
  final String imageUrl;
  final DateTime birthDate;
  final String about;

  const AddMemberEvent({
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.birthDate,
    required this.about,
  });

  @override
  List<Object?> get props => [name, role, imageUrl, birthDate, about];
}

class UpdateMemberEvent extends MemberEvent {
  final String id;
  final String name;
  final String role;
  final String imageUrl;
  final DateTime birthDate;
  final String about;

  const UpdateMemberEvent({
    required this.id,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.birthDate,
    required this.about,
  });

  @override
  List<Object?> get props => [id, name, role, imageUrl, birthDate, about];
}

class DeleteMemberEvent extends MemberEvent {
  final String id;

  const DeleteMemberEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class GetMembersEvent extends MemberEvent {
  const GetMembersEvent();

  @override
  List<Object> get props => [];
}
