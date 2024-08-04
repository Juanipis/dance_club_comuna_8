import 'package:dance_club_comuna_8/logic/bloc/event/event_admin_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/models/event_attend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendesScreen extends StatefulWidget {
  final String eventId;
  const AttendesScreen({super.key, required this.eventId});

  @override
  State<AttendesScreen> createState() => _AttendesScreenState();
}

class _AttendesScreenState extends State<AttendesScreen> {
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocBuilder<EventAdminBloc, EventState>(
        builder: (context, state) {
          if (state is EventAttendeesLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EventAttendeesLoadedState) {
            attendees = state.attendees;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: attendees.length,
                    itemBuilder: (context, index) {
                      final attendee = attendees[index];
                      return ListTile(
                        title: Text(attendee.name),
                        subtitle: Text(attendee.phoneNumber),
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
                                removeAttendAlertDialog(context, attendee);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    eventBloc.add(SaveAttendeesAttendanceEvent(
                      eventId: widget.eventId,
                      attendees: attendees,
                    ));
                  },
                  child: const Text('Guardar Asistencia'),
                ),
              ],
            );
          } else if (state is EventAttendeesErrorState) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          } else if (state is EventAttendRemovedLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EventInsertedState) {
            eventBloc.add(LoadEventAttendeesEvent(eventId: widget.eventId));
            return const Center(child: Text('User removed successfully'));
          } else if (state is AttendanceUpdatedState) {
            return const Center(child: Text('Attendance updated successfully'));
          }
          return const Center(child: Text('No Attendes'));
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
