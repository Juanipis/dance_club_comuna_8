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
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadEvents();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreEvents();
    }
  }

  void _loadEvents() {
    BlocProvider.of<EventAdminBloc>(context).add(
      LoadUpcomingEventsEvent(startTime: startDate, endTime: endDate),
    );
  }

  void _loadMoreEvents() {
    final state = BlocProvider.of<EventAdminBloc>(context).state;
    if (state is EventsLoadedState && !_isLoading && state.hasMore) {
      setState(() => _isLoading = true);
      BlocProvider.of<EventAdminBloc>(context).add(
        LoadUpcomingEventsEvent(
          startTime: startDate,
          endTime: endDate,
          lastDocument: state.lastDocument,
        ),
      );
    }
  }

  Future<void> _refreshEventsFromAttendesScreen(
      BuildContext context, eventId, String title) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendeesScreen(eventId: eventId),
      ),
    ).then((_) {
      // Ejecuta la función _loadEvents() cuando regrese de la pantalla AttendeesScreen
      _loadEvents();
    });
  }

  Future<void> _refreshEventsFromUpdateEventScreen(
      BuildContext context, eventId, String title) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateEventScreen(
          eventId: eventId,
        ),
      ),
    ).then((_) {
      _loadEvents();
    });
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
          const SizedBox(
            height: 10,
          ),
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: EventFilter.values.map((eventFilter) {
              return ElevatedButton.icon(
                onPressed: filter == eventFilter
                    ? null
                    : () {
                        segmentedFilterActions({eventFilter}, context);
                      },
                icon: Icon(_getIconForFilter(eventFilter)),
                label: Text(_getLabelForFilter(eventFilter)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: filter == eventFilter ? Colors.grey : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: BlocBuilder<EventAdminBloc, EventState>(
              builder: (context, state) {
                if (state is EventLoadingState &&
                    BlocProvider.of<EventAdminBloc>(context)
                        .allEvents
                        .isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is EventsLoadedState) {
                  _isLoading = false;
                  return tileBuilder(state);
                } else if (state is EventErrorState) {
                  return Center(child: Text(state.message));
                } else if (_isLoading || state is EventLoadingState) {
                  return const Column(
                    children: [
                      Text("Cargando más eventos..."),
                      Center(child: CircularProgressIndicator()),
                    ],
                  );
                } else {
                  return const Center(child: Text("No hay eventos"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget tileBuilder(EventsLoadedState state) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: state.events.length,
      itemBuilder: (context, index) {
        final event = state.events[index];
        return ListTile(
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
                      "${event.date.hour.toString().padLeft(2, '0')}:${event.date.minute.toString().padLeft(2, '0')}"),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.people),
                  Text("${event.attendes}/${event.maxAttendees}"),
                ],
              ),
            ],
          ),
          trailing: SizedBox(
            width: 120, // Ajusta este valor según necesites
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    child: Text(event.id, overflow: TextOverflow.ellipsis)),
                IconButton(
                  onPressed: () async {
                    _refreshEventsFromUpdateEventScreen(
                        context, event.id, event.title);
                  },
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () {
                    _refreshEventsFromAttendesScreen(
                        context, event.id, event.title);
                  },
                  icon: const Icon(Icons.people),
                ),
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
                                  BlocProvider.of<EventAdminBloc>(context);
                              await removeEvent(context, event);
                              eventAdminBloc.add(LoadUpcomingEventsEvent(
                                startTime: startDate,
                                endTime: endDate,
                              ));
                              Navigator.pop(context); // Cerrar el diálogo
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
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> removeEvent(BuildContext context, Event event) async {
    BlocProvider.of<EventAdminBloc>(context)
        .add(DeleteEventEvent(id: event.id));
    Navigator.pop(context);
    await Future.delayed(const Duration(seconds: 3));
  }

  void segmentedFilterActions(
    Set<EventFilter> selected,
    BuildContext context,
  ) {
    setState(() {
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
          break;
      }
      _loadEvents();
    });
  }

  IconData _getIconForFilter(EventFilter filter) {
    switch (filter) {
      case EventFilter.today:
        return Icons.calendar_view_day;
      case EventFilter.tomorrow:
        return Icons.keyboard_tab;
      case EventFilter.thisWeek:
        return Icons.calendar_view_week;
      case EventFilter.thisMonth:
        return Icons.calendar_view_month;
      case EventFilter.all:
        return Icons.calendar_today;
      case EventFilter.past:
        return Icons.history;
      default:
        return Icons.calendar_today; // Valor predeterminado
    }
  }

  String _getLabelForFilter(EventFilter filter) {
    switch (filter) {
      case EventFilter.today:
        return 'Hoy';
      case EventFilter.tomorrow:
        return 'Mañana';
      case EventFilter.thisWeek:
        return 'Esta semana';
      case EventFilter.thisMonth:
        return 'Este mes';
      case EventFilter.all:
        return 'Todos';
      case EventFilter.past:
        return 'Pasados';
      default:
        return ''; // Valor predeterminado
    }
  }
}
