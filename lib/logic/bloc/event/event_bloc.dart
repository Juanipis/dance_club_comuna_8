import 'package:bloc/bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_events_service.dart';
import 'package:logger/logger.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final FirestoreEventsService _firestoreService;
  List<Event> allEvents = [];

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
          maxAttendees: eventInfo.maxAttendees,
        );
        emit(EventInsertedState());
      } catch (e) {
        emit(EventErrorState(message: e.toString()));
      }
    });

    on<UpdateEventEvent>((eventInfo, emit) async {
      emit(EventLoadingState());
      try {
        bool isUpdated = await _firestoreService.updateEvent(
          id: eventInfo.id,
          date: eventInfo.date,
          title: eventInfo.title,
          description: eventInfo.description,
          instructions: eventInfo.instructions,
          address: eventInfo.address,
          imageUrl: eventInfo.imageUrl,
          maxAttendees: eventInfo.maxAttendees,
        );
        if (isUpdated) {
          emit(EventInsertedState());
        } else {
          emit(EventErrorState(message: 'Event not updated'));
        }
      } catch (e) {
        emit(EventErrorState(message: e.toString()));
      }
    });

    on<LoadUpcomingEventsEvent>((eventInfo, emit) async {
      logger.d('Loading upcoming events');
      emit(EventLoadingState());
      try {
        DateTime now = DateTime.now();
        DateTime end = eventInfo.endTime;
        allEvents = await _firestoreService.getUpcomingEvents(now, end);
        emit(EventsLoadedState(allEvents));
      } catch (e) {
        emit(EventErrorState(message: e.toString()));
      }
    });

    on<RegisterUserEvent>((eventInfo, emit) async {
      emit(EventLoadingState());
      try {
        bool success = await _firestoreService.registerUser(
            eventInfo.eventId, eventInfo.phoneNumber);
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

    on<RemoveAttendeFromEvent>((eventInfo, emit) async {
      logger.d('Removing attendee');
      emit(EventAttendRemovedLoadingState());
      try {
        await _firestoreService.removeAttendee(
            eventInfo.eventId, eventInfo.phoneNumber);
        emit(EventInsertedState(succesMessage: 'User removed successfully'));
      } catch (e) {
        emit(EventErrorState(message: e.toString()));
      }
    });
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<Event> filterEventsForToday() {
    DateTime now = DateTime.now();
    return allEvents.where((event) => isSameDay(event.date, now)).toList();
  }

  List<Event> filterEventsForTomorrow() {
    DateTime now = DateTime.now();
    DateTime tomorrow =
        DateTime(now.year, now.month, now.day + 1, 23, 59, 59, 999);
    return allEvents.where((event) => isSameDay(event.date, tomorrow)).toList();
  }

  List<Event> filterEventsForThisWeek() {
    DateTime now = DateTime.now();
    DateTime endOfWeek = now.add(Duration(days: 7 - now.weekday));
    endOfWeek = DateTime(
        endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59, 999);
    return allEvents
        .where((event) =>
            event.date.isAfter(now) && event.date.isBefore(endOfWeek))
        .toList();
  }

  List<Event> filterUpcomingEvents() {
    DateTime now = DateTime.now();
    return allEvents.where((event) => event.date.isAfter(now)).toList();
  }
}
