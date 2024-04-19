import 'package:bloc/bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_service.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final FirestoreService _firestoreService;

  EventBloc(this._firestoreService) : super(EventLoadingState()) {
    on<LoadEventEventById>((eventInfo, emit) async {
      emit(EventLoadingState());
      try {
        final event = await _firestoreService.getEventById(eventInfo.id);
        emit(LoadEventByIdState(event: event));
      } catch (e) {
        emit(EventErrorState(message: e.toString()));
      }
    });

    on<InserEventEvent>((eventInfo, emit) async {
      emit(EventLoadingState());
      try {
        await _firestoreService.addEvent(
          date: eventInfo.date,
          title: eventInfo.title,
          description: eventInfo.description,
          instructions: eventInfo.instructions,
          address: eventInfo.address,
          imageUrl: eventInfo.imageUrl,
          attendees: eventInfo.attendees,
        );
        emit(EventInsertedState());
      } catch (e) {
        emit(EventErrorState(message: e.toString()));
      }
    });

    on<UpdateEventEvent>((event, emit) async {
      emit(EventLoadingState());
      try {
        await _firestoreService.updateEvent(
          id: event.id,
          date: event.date,
          title: event.title,
          description: event.description,
          instructions: event.instructions,
          address: event.address,
          imageUrl: event.imageUrl,
          attendees: event.attendees,
        );
        emit(EventInsertedState());
      } catch (e) {
        emit(EventErrorState(message: e.toString()));
      }
    });
  }
}
