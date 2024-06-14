import 'package:dance_club_comuna_8/logic/bloc/event/event_admin_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/attendes_screen.dart';
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //Date in format dd/mm/yyyy
                        Row(
                          children: [
                            Text(
                                "${event.date.day}/${event.date.month}/${event.date.year} - "),
                            // Hour
                            Text("${event.date.hour}:${event.date.minute}"),
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
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AttendesScreen(eventId: event.id)));
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
                                            BlocProvider.of<EventAdminBloc>(
                                                context);
                                        await removeEvent(context, event);
                                        eventAdminBloc
                                            .add(LoadUpcomingEventsEvent(
                                          endTime: DateTime.now()
                                              .add(const Duration(days: 100)),
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
    );
  }

  Future<void> removeEvent(BuildContext context, Event event) async {
    BlocProvider.of<EventAdminBloc>(context)
        .add(DeleteEventEvent(id: event.id));
    Navigator.pop(context);
    await Future.delayed(const Duration(seconds: 3));
  }
}
