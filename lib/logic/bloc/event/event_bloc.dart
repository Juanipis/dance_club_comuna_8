import 'package:bloc/bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_events_service.dart';
import 'package:logger/logger.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final FirestoreEventsService _firestoreService;
  Logger logger = Logger();

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

    on<LoadUpcomingEventsEvent>((eventInfo, emit) async {
      logger.d('Loading upcoming events');
      emit(EventLoadingState());
      try {
        DateTime now = eventInfo.startTime;
        DateTime end = eventInfo.endTime;
        List<Event> events =
            await _firestoreService.getUpcomingEventsWithAttendees(now, end);
        emit(EventsLoadedState(events));
      } catch (e) {
        emit(EventErrorState(message: e.toString()));
      }
    });

    on<RegisterUserEvent>((eventInfo, emit) async {
      emit(EventLoadingState());
      try {
        bool success = await _firestoreService.registerUser(
            eventInfo.eventId, eventInfo.phoneNumber, eventInfo.name);
        if (success) {
          emit(UserRegisteredState());
        } else {
          emit(EventErrorState(
              message: 'Event is full or user already registered'));
        }
      } catch (e) {
        emit(EventErrorState(message: e.toString()));
      }
    });

    on<LoadEventAttendeesEvent>((eventInfo, emit) async {
      emit(EventAttendeesLoadingState());
      try {
        final attendees =
            await _firestoreService.getEventAttendees(eventInfo.eventId);
        emit(EventAttendeesLoadedState(attendees));
      } catch (e) {
        emit(EventAttendeesErrorState(message: e.toString()));
      }
    });
  }
}
