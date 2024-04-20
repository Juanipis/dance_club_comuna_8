import 'package:dance_club_comuna_8/logic/models/event.dart';
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
