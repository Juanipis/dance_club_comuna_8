import 'package:dance_club_comuna_8/logic/bloc/event/event_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/models/date_helper.dart';
import 'package:dance_club_comuna_8/presentation/screen/events/expanded_event.dart';
import 'package:dance_club_comuna_8/presentation/widgets/circular_progress.dart';
import 'package:dance_club_comuna_8/presentation/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

enum EventFilter { today, tomorrow, thisWeek, thisMonth, all }

class BuildEventsScreen extends StatefulWidget {
  const BuildEventsScreen({super.key});

  @override
  State<BuildEventsScreen> createState() => BuildEventsScreenState();
}

class BuildEventsScreenState extends State<BuildEventsScreen> {
  EventFilter filter = EventFilter.today;
  DateTime startDate = DateHelper.startOfToday();
  DateTime endDate = DateHelper.endOfToday();

  Logger logger = Logger();
  @override
  void initState() {
    super.initState();
    BlocProvider.of<EventBloc>(context, listen: false)
        .add(LoadUpcomingEventsEvent(startTime: startDate, endTime: endDate));
  }

  Future<void> _refreshEvents(
      BuildContext context, eventId, String title) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ExpandedEvent(eventId: eventId, title: title)));
    if (!context.mounted) return;
    logger.d('Returned from expanded event');
    BlocProvider.of<EventBloc>(context)
        .add(LoadUpcomingEventsEvent(startTime: startDate, endTime: endDate));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                foregroundColor: filter == eventFilter ? Colors.grey : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(
          height: 10,
        ),
        BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            if (state is EventLoadingState) {
              return circularProgressIndicator();
            } else if (state is EventsLoadedState) {
              return Column(
                children: [
                  Center(
                    child: Wrap(
                      spacing: 10.0, // Espacio horizontal entre tarjetas
                      runSpacing: 10.0, // Espacio vertical entre filas
                      children: [
                        for (var event in state.events)
                          eventCard(
                              event: event,
                              context: context,
                              refreshEvents: _refreshEvents)
                      ],
                    ),
                  ),
                ],
              );
            } else if (state is EventErrorState) {
              return Center(
                child: Text(state.message),
              );
            }
            return const Center(
              child: Text("No hay eventos"),
            );
          },
        ),
      ],
    );
  }

  void segmentedFilterActions(Set<EventFilter> selected, BuildContext context) {
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
      }

      BlocProvider.of<EventBloc>(context)
          .add(LoadUpcomingEventsEvent(startTime: startDate, endTime: endDate));
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
    }
  }
}
