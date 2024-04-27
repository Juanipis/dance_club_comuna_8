import 'package:dance_club_comuna_8/logic/bloc/event/event_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/auth/auth_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/auth/auth_states.dart';

class EventAttendeesWidget extends StatefulWidget {
  const EventAttendeesWidget({super.key});

  @override
  _EventAttendeesWidgetState createState() => _EventAttendeesWidgetState();
}

class _EventAttendeesWidgetState extends State<EventAttendeesWidget> {
  final TextEditingController _eventIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is Authenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text("Event Attendees")),
            body: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _eventIdController,
                    decoration: InputDecoration(
                      labelText: 'Enter Event ID',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () =>
                            BlocProvider.of<EventBloc>(context).add(
                          LoadEventAttendeesEvent(
                              eventId: _eventIdController.text),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: BlocConsumer<EventBloc, EventState>(
                    listener: (context, state) {
                      if (state is EventAttendeesErrorState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${state.message}')),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is EventAttendeesLoadingState) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is EventAttendeesLoadedState) {
                        return ListView.builder(
                          itemCount: state.attendees.length,
                          itemBuilder: (context, index) {
                            final attendee = state.attendees[index];
                            return ListTile(
                              title: Text(attendee.phoneNumber),
                              subtitle: Text('${attendee.timestamp}'),
                              trailing: GestureDetector(
                                onTap: () => _showRemoveAttendDialog(
                                    context,
                                    _eventIdController.text,
                                    attendee.phoneNumber),
                                child: const Icon(Icons.delete),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                            child: Text('Enter an event ID to start.'));
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Scaffold(
            body:
                Center(child: Text('You must be logged in to view this page.')),
          );
        }
      },
    );
  }

  void _showRemoveAttendDialog(
      BuildContext context, String eventId, String phoneNumber) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Attendee'),
        content: const Text('Enter the phone number of the attendee to remove:'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<EventBloc>(context).add(
                RemoveAttendeFromEvent(
                  eventId: eventId,
                  phoneNumber: phoneNumber,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
