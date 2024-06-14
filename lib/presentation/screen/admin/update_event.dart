import 'package:dance_club_comuna_8/logic/bloc/event/event_admin_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateEventScreen extends StatefulWidget {
  final String eventId;
  const UpdateEventScreen({super.key, required this.eventId});

  @override
  State<UpdateEventScreen> createState() => _UpdateEventScreenState();
}

class _UpdateEventScreenState extends State<UpdateEventScreen> {
  Event? eventData;
  final TextEditingController idController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController maxAttendeesController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2025),
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
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void saveEvent(BuildContext context) {
    final eventBloc = BlocProvider.of<EventAdminBloc>(context);
    final title = titleController.text;
    final maxAttendeesText = maxAttendeesController.text;
    final int? maxAttendees = int.tryParse(maxAttendeesText);

    if (title.isEmpty ||
        maxAttendees == null ||
        maxAttendees <= 0 ||
        selectedDate == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Por favor complete todos los campos obligatorios correctamente')),
      );
      return;
    }

    eventBloc.add(UpdateEventEvent(
      id: widget.eventId,
      date: DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      ),
      title: title,
      description: descriptionController.text,
      instructions: instructionsController.text,
      address: addressController.text,
      imageUrl: imageUrlController.text,
      maxAttendees: maxAttendees,
    ));
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<EventAdminBloc>(context)
        .add(LoadEventEventById(id: widget.eventId));
  }

  @override
  Widget build(BuildContext context) {
    final eventBloc = BlocProvider.of<EventAdminBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Evento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.pop(context);
            eventBloc.add(LoadUpcomingEventsEvent(
                endTime: DateTime.now().add(const Duration(days: 100))));
          },
        ),
      ),
      body: BlocBuilder<EventAdminBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EventDosentExistState) {
            return const Center(
              child: Column(
                children: [
                  Text('El evento no existe'),
                  Text('Por favor verifique el ID del evento'),
                ],
              ),
            );
          } else if (state is EventCannotUpdateMaxAttendeesState) {
            return const Center(
              child: Text(
                  'No se puede actualizar el número máximo de asistentes, remueva asistentes primero'),
            );
          } else if (state is EventErrorState) {
            return Center(
                child: Column(
              children: [
                Text(state.message),
                const Text(
                    "Pongase en contacto con el administrador y muestrele este mensaje de error.")
              ],
            ));
          } else if (state is EventUpdatedState) {
            return const Center(
              child: Text('Evento actualizado 🎊'),
            );
          }
          if (state is LoadEventByIdState) {
            eventData = state.event;
            idController.text = widget.eventId;
            titleController.text = eventData!.title;
            descriptionController.text = eventData!.description;
            instructionsController.text = eventData!.instructions;
            addressController.text = eventData!.address;
            imageUrlController.text = eventData!.imageUrl;
            maxAttendeesController.text = eventData!.maxAttendees.toString();

            // set the date and time to the event date and time
            selectedDate = eventData!.date;
            selectedTime = TimeOfDay.fromDateTime(eventData!.date);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    enabled: false,
                    controller: idController,
                    decoration: const InputDecoration(
                      labelText: 'ID del Evento',
                    ),
                  ),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título del Evento (obligatorio)',
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción del Evento',
                    ),
                  ),
                  TextField(
                    controller: instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Instrucciones del Evento',
                    ),
                  ),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección del Evento',
                    ),
                  ),
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL de la imagen del Evento',
                    ),
                  ),
                  TextField(
                    controller: maxAttendeesController,
                    decoration: const InputDecoration(
                      labelText: 'Máximo de asistentes (obligatorio)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  ElevatedButton(
                    onPressed: () => selectDate(context),
                    child: const Text('Seleccionar fecha'),
                  ),
                  Text(selectedDate != null
                      ? 'Fecha seleccionada: ${selectedDate!.toLocal()}'
                      : 'No se ha seleccionado fecha'),
                  ElevatedButton(
                    onPressed: () => selectTime(context),
                    child: const Text('Seleccionar hora'),
                  ),
                  Text(selectedTime != null
                      ? 'Hora seleccionada: ${selectedTime!.format(context)}'
                      : 'No se ha seleccionado hora'),
                  ElevatedButton(
                    onPressed: () => saveEvent(context),
                    child: const Text('Guardar Evento'),
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: Text('Error al cargar el evento'),
          );
        },
      ),
    );
  }
}