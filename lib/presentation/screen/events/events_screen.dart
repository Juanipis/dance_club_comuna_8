import 'package:dance_club_comuna_8/logic/bloc/event/event_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/presentation/screen/events/expanded_event.dart';
import 'package:dance_club_comuna_8/presentation/widgets/circular_progress.dart';
import 'package:dance_club_comuna_8/presentation/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class BuildEventsScreen extends StatefulWidget {
  const BuildEventsScreen({super.key});

  @override
  State<BuildEventsScreen> createState() => BuildEventsScreenState();
}

class BuildEventsScreenState extends State<BuildEventsScreen> {
  Logger logger = Logger();
  @override
  void initState() {
    super.initState();
    BlocProvider.of<EventBloc>(context, listen: false).add(
        LoadUpcomingEventsEvent(
            endTime: DateTime.now().add(const Duration(days: 31))));
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
    BlocProvider.of<EventBloc>(context).add(LoadUpcomingEventsEvent(
        endTime: DateTime.now().add(const Duration(days: 31))));
  }

  @override
  Widget build(BuildContext context) {
    //var events = [testEvent, testEvent];
    // using  eventCard(event: event, context: context) to build the cards
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        if (state is EventLoadingState) {
          return circularProgressIndicator();
        } else if (state is EventsLoadedState) {
          return Center(
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
    );
  }
}
