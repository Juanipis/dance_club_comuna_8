import 'package:dance_club_comuna_8/logic/bloc/event/event_admin_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/update_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventsViewerScreen extends StatefulWidget {
  const EventsViewerScreen({super.key});

  @override
  State<EventsViewerScreen> createState() => _EventsViewerScreenState();
}

class _EventsViewerScreenState extends State<EventsViewerScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<EventAdminBloc>(context).add(LoadUpcomingEventsEvent(
        endTime: DateTime.now().add(const Duration(days: 100))));
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
      body: BlocBuilder<EventAdminBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EventsLoadedState) {
            return ListView(
              children: [
                for (var event in state.events)
                  ListTile(
                    title: Text(event.title),
                    subtitle: Text(event.date.toString()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(event.id),
                        IconButton(
                            onPressed: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UpdateEventScreen(
                                            eventId: event.id,
                                          )));
                            },
                            icon: const Icon(Icons.edit)),
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
    );
  }
}
