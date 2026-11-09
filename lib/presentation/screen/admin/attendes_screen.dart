import 'package:dance_club_comuna_8/logic/bloc/event/event_admin_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/models/event_attend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendeesScreen extends StatefulWidget {
  final String eventId;
  const AttendeesScreen({super.key, required this.eventId});

  @override
  State<AttendeesScreen> createState() => _AttendeesScreenState();
}

class _AttendeesScreenState extends State<AttendeesScreen> {
  late EventAdminBloc eventBloc;
  List<EventAttend> attendees = [];

  @override
  void initState() {
    super.initState();
    eventBloc = BlocProvider.of<EventAdminBloc>(context);
    eventBloc.add(LoadEventAttendeesEvent(eventId: widget.eventId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asistentes del evento ${widget.eventId}'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<EventAdminBloc, EventState>(
        builder: (context, state) {
          if (state is EventAttendeesLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EventAttendeesLoadedState) {
            attendees = state.attendees;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: attendees.length,
                        itemBuilder: (context, index) {
                          final attendee = attendees[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Text(
                                  attendee.name[0],
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                              ),
                              title: Text(attendee.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              subtitle: Text(attendee.phoneNumber,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: attendee.attended,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        attendees[index] =
                                            attendee.copyWith(attended: value);
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      removeAttendAlertDialog(
                                          context, attendee);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          eventBloc.add(SaveAttendeesAttendanceEvent(
                            eventId: widget.eventId,
                            attendees: attendees,
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        icon: const Icon(
                          Icons.save,
                          size: 28,
                        ),
                        label: const Text('Guardar Asistencia'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is EventAttendeesErrorState) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          } else if (state is EventAttendRemovedLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EventInsertedState) {
            eventBloc.add(LoadEventAttendeesEvent(eventId: widget.eventId));
            return const Center(
                child: Text('Asistente eliminado exitosamente'));
          } else if (state is AttendanceUpdatedState) {
            return const Center(
                child: Text('Asistencia actualizada exitosamente'));
          }
          // Return a circular progress indicator if the state is not any of the above
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<dynamic> removeAttendAlertDialog(
      BuildContext context, EventAttend attendee) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Eliminar asistente'),
            content: const Text('¿Está seguro de eliminar este asistente?'),
            actions: [
              TextButton(
                onPressed: () {
                  eventBloc.add(RemoveAttendeFromEvent(
                    eventId: widget.eventId,
                    phoneNumber: attendee.phoneNumber,
                  ));
                  Navigator.pop(context);
                },
                child: const Text('Sí'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('No'),
              ),
            ],
          );
        });
  }
}
