import 'package:dance_club_comuna_8/logic/bloc/member/member_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/member/member_states.dart';
import 'package:dance_club_comuna_8/logic/models/member.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_member_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final FirestoreMemberService _firestoreService;
  final Logger logger = Logger();

  // Reference to the members stream subscription
  Stream<List<Member>>? _membersStream;

  MemberBloc(this._firestoreService) : super(MemberLoadingState()) {
    on<LoadMembersEvent>(_onLoadMembers);

    on<AddMemberEvent>((event, emit) async {
      try {
        Member member = Member(
          name: event.name,
          role: event.role,
          imageUrl: event.imageUrl,
          birthDate: event.birthDate,
          about: event.about,
        );
        await _firestoreService.addMember(member);

        // No need to manually update the cache or emit MemberLoadedState
        // Firestore stream will handle it
      } catch (e) {
        logger.e('Error adding member: $e');
        emit(MemberErrorState(message: e.toString()));
      }
    });

    on<UpdateMemberEvent>((event, emit) async {
      try {
        Member member = Member(
          id: event.id, // Ensure the ID is set
          name: event.name,
          role: event.role,
          imageUrl: event.imageUrl,
          birthDate: event.birthDate,
          about: event.about,
        );
        await _firestoreService.updateMember(event.id, member);

        // No need to manually update the cache or emit MemberLoadedState
        // Firestore stream will handle it
      } catch (e) {
        logger.e('Error updating member: $e');
        emit(MemberErrorState(message: e.toString()));
      }
    });

    on<DeleteMemberEvent>((event, emit) async {
      try {
        await _firestoreService.deleteMember(event.id);

        // No need to manually update the cache or emit MemberLoadedState
        // Firestore stream will handle it
      } catch (e) {
        logger.e('Error deleting member: $e');
        emit(MemberErrorState(message: e.toString()));
      }
    });
  }

  Future<void> _onLoadMembers(
      LoadMembersEvent event, Emitter<MemberState> emit) async {
    emit(MemberLoadingState());

    try {
      _membersStream = _firestoreService.getMembers();
      await emit.forEach<List<Member>>(
        _membersStream!,
        onData: (members) {
          return MemberLoadedState(members);
        },
        onError: (error, stackTrace) {
          logger.e('Error loading members: $error');
          return MemberErrorState(message: error.toString());
        },
      );
    } catch (e) {
      logger.e('Error setting up member stream: $e');
      emit(MemberErrorState(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    // No need to cancel the stream subscription manually as emit.forEach handles it
    return super.close();
  }
}
