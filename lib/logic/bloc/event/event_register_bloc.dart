import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_events_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class EventRegisterBloc extends Bloc<EventEvent, EventState> {
  final FirestoreEventsService _firestoreService;
  Logger logger = Logger();

  EventRegisterBloc(this._firestoreService) : super(EventLoadingState()) {
    on<RegisterUserEvent>((eventInfo, emit) async {
      emit(EventLoadingState());
      try {
        bool success = await _firestoreService.registerUser(
            eventInfo.eventId, eventInfo.phoneNumber, eventInfo.name);
        if (success) {
          emit(UserRegisteredState());
        } else {
          emit(EventErrorState(
              message: 'El evento está lleno o ya te encuentras registrado'));
        }
      } catch (e) {
        emit(EventErrorState(message: e.toString()));
      }
    });
  }
}
