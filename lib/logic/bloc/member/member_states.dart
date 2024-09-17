import 'package:dance_club_comuna_8/logic/models/member.dart';
import 'package:equatable/equatable.dart';

abstract class MemberState extends Equatable {}

class MemberInitialState extends MemberState {
  @override
  List<Object> get props => [];
}

class MemberLoadingState extends MemberState {
  @override
  List<Object> get props => [];
}

class MemberLoadedState extends MemberState {
  final List<Member> members;

  MemberLoadedState(this.members);

  @override
  List<Object?> get props => [members];
}

class MemberErrorState extends MemberState {
  final String message;

  MemberErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class MemberAddedState extends MemberState {
  final Member member;

  MemberAddedState({required this.member});

  @override
  List<Object?> get props => [member];
}

class MemberUpdatedState extends MemberState {
  final Member member;

  MemberUpdatedState({required this.member});

  @override
  List<Object?> get props => [member];
}

class MemberDeletedState extends MemberState {
  final String id;

  MemberDeletedState({required this.id});

  @override
  List<Object?> get props => [id];
}
