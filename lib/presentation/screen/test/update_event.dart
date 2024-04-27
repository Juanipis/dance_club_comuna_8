import 'package:dance_club_comuna_8/logic/bloc/auth/auth_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/auth/auth_states.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateEventPage extends StatefulWidget {
  const UpdateEventPage({super.key});

  @override
  State<StatefulWidget> createState() => _UpdateEventPageState();
}

class _UpdateEventPageState extends State<UpdateEventPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is Authenticated) {
        return buildUpdateEventForm(context);
      } else {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Actualizar Evento'),
          ),
          body: const Center(
            child: Text('No tienes permiso para ver este contenido.'),
          ),
        );
      }
    });
  }

  final TextEditingController _eventIdController = TextEditingController();
  final TextEditingController eventTitleController = TextEditingController();
  final TextEditingController eventDescriptionController =
      TextEditingController();
  final TextEditingController eventInstructionsController =
      TextEditingController();
  final TextEditingController eventAddressController = TextEditingController();
  final TextEditingController eventImageUrlController = TextEditingController();
  final TextEditingController eventMaxAttendeesController =
      TextEditingController();

  Widget buildUpdateEventForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar Evento'),
      ),
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
                  onPressed: () => BlocProvider.of<EventBloc>(context).add(
                    LoadEventEventById(id: _eventIdController.text),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
              child: BlocConsumer<EventBloc, EventState>(
            listener: (BuildContext context, EventState state) {
              if (state is EventErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
              if (state is EventUpdatedState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
              if (state is EventDosentExistState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
              if (state is EventCannotUpdateMaxAttendeesState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
              if (state is EventUpdateErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (BuildContext context, EventState state) {
              if (state is EventLoadingState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is LoadEventByIdState) {
                final event = state.event;
                // set the text controllers
                eventTitleController.text = event.title;
                eventDescriptionController.text = event.description;
                eventInstructionsController.text = event.instructions;
                eventAddressController.text = event.address;
                eventImageUrlController.text = event.imageUrl;
                eventMaxAttendeesController.text =
                    event.maxAttendees.toString();
                DateTime selectedDate = event.date;
                TimeOfDay selectedTime = TimeOfDay.fromDateTime(event.date);

                Future<void> selectDate(BuildContext context) async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate:
                        selectedDate, // event.date is the current event DateTime
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                }

                Future<void> selectTime(BuildContext context) async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime, // Use current event time
                  );
                  if (picked != null && picked != selectedTime) {
                    setState(() {
                      selectedTime = picked;
                    });
                  }
                }

                // event.date is the DateTime of the event
                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Event ID: ${event.id}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: eventTitleController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Event Title',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: eventDescriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Event Description',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: eventInstructionsController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Event Instructions',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: eventAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Event Address',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: eventImageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Event Image URL',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: eventMaxAttendeesController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Event Max Attendees',
                        ),
                      ),
                    ),

                    // Display selected date
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => selectDate(context),
                          child: const Text('Select Date'),
                        ),
                        Text(
                            'Selected date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                      ],
                    ),

                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => selectTime(context),
                          child: const Text('Select Time'),
                        ),

                        // Display selected time

                        Text('Selected time: ${selectedTime.format(context)}'),
                      ],
                    ),

                    // only show the date, dd/mm/yyyy

                    ElevatedButton(
                      onPressed: () {
                        final eventBloc = BlocProvider.of<EventBloc>(context);
                        DateTime eventDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );

                        eventBloc.add(UpdateEventEvent(
                          id: event.id,
                          date: eventDateTime,
                          title: eventTitleController.text,
                          description: eventDescriptionController.text,
                          instructions: eventInstructionsController.text,
                          address: eventAddressController.text,
                          imageUrl: eventImageUrlController.text,
                          maxAttendees:
                              int.parse(eventMaxAttendeesController.text),
                        ));
                      },
                      child: const Text('Update Event'),
                    ),
                  ],
                );
              } else if (state is EventInsertedState) {
                return const Center(
                  child: Text('Evento actualizado'),
                );
              } else if (state is EventErrorState) {
                return Center(
                  child: Text('Error: ${state.message}'),
                );
              } else {
                return const Center(
                  child: Text('No hay eventos para mostrar'),
                );
              }
            },
          )),
        ],
      ),
    );
  }
}
