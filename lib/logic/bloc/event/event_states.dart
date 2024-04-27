import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:dance_club_comuna_8/logic/models/event_attend.dart';
import 'package:equatable/equatable.dart';

abstract class EventState extends Equatable {}

class EventLoadingState extends EventState {
  @override
  List<Object> get props => [];
}

class EventLoadedState extends EventState {
  final List<Event> events;

  EventLoadedState(List<Event> allEvents, {required this.events});

  @override
  List<Object> get props => [events];
}

class EventsLoadedState extends EventState {
  final List<Event> events;

  EventsLoadedState(this.events);

  @override
  List<Object?> get props => [events];
}

class EventErrorState extends EventState {
  final String message;

  EventErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class LoadEventByIdState extends EventState {
  final Event event;

  LoadEventByIdState({required this.event});

  @override
  List<Object> get props => [event];
}

class EventInsertedState extends EventState {
  final String succesMessage;

  EventInsertedState({this.succesMessage = "Evento creado exitosamente"});

  @override
  List<Object?> get props => [succesMessage];
}

class UserRegisteredState extends EventState {
  @override
  List<Object?> get props => [];
}

// ----------------- Event Attendees -----------------
class EventAttendeesLoadingState extends EventState {
  @override
  List<Object> get props => [];
}

class EventAttendeesErrorState extends EventState {
  final String message;

  EventAttendeesErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class EventAttendeesLoadedState extends EventState {
  final List<EventAttend> attendees;

  EventAttendeesLoadedState(this.attendees);

  @override
  List<Object?> get props => [attendees];
}

// ----------------- Event Attendees Remove States -----------------
class EventAttendRemovedState extends EventState {
  final String message;

  EventAttendRemovedState({this.message = "Asistente eliminado exitosamente"});

  @override
  List<Object?> get props => [message];
}

class EventAttedRemovedErrorState extends EventState {
  final String message;

  EventAttedRemovedErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class EventAttendRemovedLoadingState extends EventState {
  @override
  List<Object?> get props => [];
}

// --- Event Update States

class EventUpdatedState extends EventState {
  final String message = "Evento actualizado exitosamente";

  EventUpdatedState();

  @override
  List<Object?> get props => [message];
}

class EventDosentExistState extends EventState {
  final String message = "El evento no existe";

  EventDosentExistState();

  @override
  List<Object?> get props => [message];
}

class EventCannotUpdateMaxAttendeesState extends EventState {
  final String message =
      "No se puede actualizar el número máximo de asistentes, ya que la cantidad de asistentes actuales es mayor a la nueva capacidad máxima, si desea actualizar la capacidad máxima, elimine asistentes primero.";

  EventCannotUpdateMaxAttendeesState();

  @override
  List<Object?> get props => [message];
}

class EventUpdateErrorState extends EventState {
  final String message;

  EventUpdateErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
