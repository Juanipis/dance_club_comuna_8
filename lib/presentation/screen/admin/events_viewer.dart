import 'package:dance_club_comuna_8/logic/bloc/event/event_admin_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/models/date_helper.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/attendes_screen.dart';

import 'package:dance_club_comuna_8/presentation/screen/admin/event_form/update_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum EventFilter { today, tomorrow, thisWeek, thisMonth, all, past }

class EventsViewerScreen extends StatefulWidget {
  const EventsViewerScreen({super.key});

  @override
  State<EventsViewerScreen> createState() => _EventsViewerScreenState();
}

class _EventsViewerScreenState extends State<EventsViewerScreen> {
  EventFilter filter = EventFilter.today;
  DateTime startDate = DateHelper.startOfToday();
  DateTime endDate = DateHelper.endOfToday();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<EventAdminBloc>(context)
        .add(LoadUpcomingEventsEvent(startTime: startDate, endTime: endDate));
  }

  Future<void> _refreshEventsFromAttendesScreen(
      BuildContext context, eventId, String title) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AttendeesScreen(eventId: eventId)));
    if (!context.mounted) return;
    BlocProvider.of<EventAdminBloc>(context)
        .add(LoadUpcomingEventsEvent(startTime: startDate, endTime: endDate));
  }

  Future<void> _refreshEventsFromUpdateEventScreen(
      BuildContext context, eventId, String title) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UpdateEventScreen(
                  eventId: eventId,
                )));
    if (!context.mounted) return;
    BlocProvider.of<EventAdminBloc>(context)
        .add(LoadUpcomingEventsEvent(startTime: startDate, endTime: endDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eventos actuales"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          SegmentedButton(
              segments: const <ButtonSegment<EventFilter>>[
                ButtonSegment<EventFilter>(
                    label: Text('Hoy'),
                    icon: Icon(Icons.calendar_view_day),
                    value: EventFilter.today),
                ButtonSegment<EventFilter>(
                    label: Text('Mañana'),
                    icon: Icon(Icons.keyboard_tab),
                    value: EventFilter.tomorrow),
                ButtonSegment<EventFilter>(
                    label: Text('Esta semana'),
                    icon: Icon(Icons.calendar_view_week),
                    value: EventFilter.thisWeek),
                ButtonSegment<EventFilter>(
                    label: Text('Este mes'),
                    icon: Icon(Icons.calendar_view_month),
                    value: EventFilter.thisMonth),
                ButtonSegment<EventFilter>(
                    label: Text('Todos'),
                    icon: Icon(Icons.calendar_today),
                    value: EventFilter.all),
                ButtonSegment<EventFilter>(
                    label: Text('Pasados'),
                    icon: Icon(Icons.history),
                    value: EventFilter.past),
              ],
              selected: <EventFilter>{
                filter
              },
              onSelectionChanged: (Set<EventFilter> selected) {
                segmentedFiltrerActions(selected, context);
              }),
          Expanded(
            child: BlocBuilder<EventAdminBloc, EventState>(
              builder: (context, state) {
                if (state is EventLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is EventsLoadedState) {
                  return ListView(
                    children: [
                      for (var event in state.events)
                        ListTile(
                          title: Text(event.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                      "${event.date.day}/${event.date.month}/${event.date.year} - "),
                                  Text(
                                      "${event.date.hour}:${event.date.minute}"),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.people),
                                  Text(
                                      "${event.attendes}/${event.maxAttendees}"),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(event.id),
                              IconButton(
                                  onPressed: () async {
                                    _refreshEventsFromUpdateEventScreen(
                                        context, event.id, event.title);
                                  },
                                  icon: const Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {
                                    _refreshEventsFromAttendesScreen(
                                        context, event.id, event.title);
                                  },
                                  icon: const Icon(Icons.people)),
                              //An icon button of a trash can to delete the event, it opens an alert dialog to confirm the action
                              IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Eliminar evento"),
                                        content: const Text(
                                            "¿Está seguro que desea eliminar este evento?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              final eventAdminBloc =
                                                  BlocProvider.of<
                                                      EventAdminBloc>(context);
                                              await removeEvent(context, event);
                                              eventAdminBloc
                                                  .add(LoadUpcomingEventsEvent(
                                                startTime: startDate,
                                                endTime: endDate,
                                              ));
                                            },
                                            child: const Text("Sí"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("No"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.delete)),
                            ],
                          ),
                        )
                    ],
                  );
                } else if (state is EventErrorState) {
                  return Center(
                    child: Text(state.message),
                  );
                } else {
                  return const Center(
                    child: Text("No hay eventos"),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> removeEvent(BuildContext context, Event event) async {
    BlocProvider.of<EventAdminBloc>(context)
        .add(DeleteEventEvent(id: event.id));
    Navigator.pop(context);
    await Future.delayed(const Duration(seconds: 3));
  }

  void segmentedFiltrerActions(
      Set<EventFilter> selected, BuildContext context) {
    return setState(() {
      filter = selected.first;
      switch (filter) {
        case EventFilter.today:
          startDate = DateHelper.startOfToday();
          endDate = DateHelper.endOfToday();
          break;
        case EventFilter.tomorrow:
          startDate = DateHelper.startOfTomorrow();
          endDate = DateHelper.endOfTomorrow();
          break;
        case EventFilter.thisWeek:
          startDate = DateHelper.startOfThisWeek();
          endDate = DateHelper.endOfThisWeek();
          break;
        case EventFilter.thisMonth:
          startDate = DateHelper.startOfThisMonth();
          endDate = DateHelper.endOfThisMonth();
          break;
        case EventFilter.all:
          startDate = DateHelper.startOfAll();
          endDate = DateHelper.endOfAll();
          break;
        case EventFilter.past:
          startDate = DateHelper.past();
          endDate = DateHelper.startOfToday();
      }

      BlocProvider.of<EventAdminBloc>(context)
          .add(LoadUpcomingEventsEvent(startTime: startDate, endTime: endDate));
    });
  }
}
