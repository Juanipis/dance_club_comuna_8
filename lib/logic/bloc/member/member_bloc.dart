import 'package:dance_club_comuna_8/logic/bloc/member/member_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/member/member_states.dart';
import 'package:dance_club_comuna_8/logic/models/member.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_member_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final FirestoreMemberService _firestoreService;
  Logger logger = Logger();

  // Almacenar los miembros cargados
  List<Member> _cachedMembers = [];

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

        // Actualizar la caché local después de agregar
        _cachedMembers.add(member);

        emit(MemberAddedState(member: member));
        emit(MemberLoadedState(_cachedMembers)); // Emitir estado actualizado
      } catch (e) {
        logger.e('Error adding member: $e');
        emit(MemberErrorState(message: e.toString()));
      }
    });

    on<UpdateMemberEvent>((event, emit) async {
      try {
        Member member = Member(
          id: event.id, // Aseguramos que el id se pase
          name: event.name,
          role: event.role,
          imageUrl: event.imageUrl,
          birthDate: event.birthDate,
          about: event.about,
        );
        await _firestoreService.updateMember(event.id, member);

        // Actualizar la caché local después de la actualización
        int index = _cachedMembers.indexWhere((m) => m.id == event.id);
        if (index != -1) {
          _cachedMembers[index] = member;
        }

        emit(MemberUpdatedState(member: member));
        emit(MemberLoadedState(_cachedMembers)); // Emitir estado actualizado
      } catch (e) {
        logger.e('Error updating member: $e');
        emit(MemberErrorState(message: e.toString()));
      }
    });

    on<DeleteMemberEvent>((event, emit) async {
      try {
        await _firestoreService.deleteMember(event.id);

        // Actualizar la caché local después de eliminar
        _cachedMembers.removeWhere((m) => m.id == event.id);

        emit(MemberDeletedState(id: event.id));
        emit(MemberLoadedState(_cachedMembers)); // Emitir estado actualizado
      } catch (e) {
        logger.e('Error deleting member: $e');
        emit(MemberErrorState(message: e.toString()));
      }
    });
  }

  Future<void> _onLoadMembers(
      LoadMembersEvent event, Emitter<MemberState> emit) async {
    // Si los miembros ya están en caché, simplemente emite el estado almacenado
    if (_cachedMembers.isNotEmpty) {
      emit(MemberLoadedState(_cachedMembers));
      return;
    }

    emit(MemberLoadingState());

    try {
      // Obtener miembros de Firestore y almacenarlos en caché
      await emit.forEach<List<Member>>(
        _firestoreService.getMembers(),
        onData: (members) {
          _cachedMembers = members; // Guardar en caché los miembros cargados
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
}
