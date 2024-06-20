import 'package:dance_club_comuna_8/logic/bloc/event/event_admin_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/bloc/images/image_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/images/image_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/images/image_states.dart';
import 'package:dance_club_comuna_8/logic/models/image_bucket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController maxAttendeesController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime? selectedEndDate;
  TimeOfDay? selectedEndTime;

  List<ImageBucket> images = [];

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

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedEndDate) {
      setState(() {
        selectedEndDate = picked;
      });
    }
  }

  Future<void> selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedEndTime) {
      setState(() {
        selectedEndTime = picked;
      });
    }
  }

  bool checkDates() {
    if (selectedDate == null ||
        selectedTime == null ||
        selectedEndDate == null ||
        selectedEndTime == null) {
      return false;
    }
    final startDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );
    final endDateTime = DateTime(
      selectedEndDate!.year,
      selectedEndDate!.month,
      selectedEndDate!.day,
      selectedEndTime!.hour,
      selectedEndTime!.minute,
    );
    return startDateTime.isBefore(endDateTime);
  }

  void saveEvent(BuildContext context) {
    final eventBloc = BlocProvider.of<EventAdminBloc>(context);
    final title = titleController.text;
    final maxAttendeesText = maxAttendeesController.text;
    final int? maxAttendees = int.tryParse(maxAttendeesText);

    if (title.isEmpty ||
        maxAttendees == null ||
        maxAttendees <= 0 ||
        !checkDates()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Por favor complete todos los campos obligatorios correctamente')),
      );
      return;
    }

    eventBloc.add(InserEventEvent(
      date: DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      ),
      endDate: DateTime(
        selectedEndDate!.year,
        selectedEndDate!.month,
        selectedEndDate!.day,
        selectedEndTime!.hour,
        selectedEndTime!.minute,
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
    // with the bloc provider  get the images paths, this will be used to show the images in the dropdown
    BlocProvider.of<ImageBloc>(context)
        .add(const GetImagesPathsEvent(path: 'images'));

    BlocProvider.of<ImageBloc>(context).stream.listen((state) {
      if (state is ImagesPathsLoadedState) {
        setState(() {
          images = state.images;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventBloc = BlocProvider.of<EventAdminBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Evento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.pop(context);
            await Future.delayed(const Duration(seconds: 1));
            eventBloc.add(const ResetEventState());
          },
        ),
      ),
      body: BlocBuilder<EventAdminBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EventErrorState) {
            return Center(
              child: Text(state.message),
            );
          } else if (state is EventInsertedState) {
            return const Center(
              child: Text('Evento guardado 🎉'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
                Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: TextField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL de la imagen del Evento',
                        ),
                      ),
                    ),
                    DropdownButton<ImageBucket>(
                      value: images.isNotEmpty ? images[0] : null,
                      onChanged: (ImageBucket? value) {
                        setState(() {
                          imageUrlController.text = value!.imagePath;
                        });
                      },
                      dropdownColor: Colors.white,
                      iconSize: 20,
                      items: images
                          .map((image) => DropdownMenuItem<ImageBucket>(
                                value: image,
                                child: Text(image.imageName),
                              ))
                          .toList(),
                    ),
                  ],
                ),
                TextField(
                  controller: maxAttendeesController,
                  decoration: const InputDecoration(
                    labelText: 'Máximo de asistentes (obligatorio)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => selectDate(context),
                      child: const Text('Seleccionar fecha'),
                    ),
                    Text(selectedDate != null
                        ? 'Fecha seleccionada: ${selectedDate!.toLocal()}'
                        : 'No se ha seleccionado fecha'),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => selectTime(context),
                      child: const Text('Seleccionar hora'),
                    ),
                    Text(selectedTime != null
                        ? 'Hora seleccionada: ${selectedTime!.format(context)}'
                        : 'No se ha seleccionado hora'),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => selectEndDate(context),
                      child: const Text('Seleccionar fecha de fin'),
                    ),
                    Text(selectedEndDate != null
                        ? 'Fecha de fin seleccionada: ${selectedEndDate!.toLocal()}'
                        : 'No se ha seleccionado fecha de fin'),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => selectEndTime(context),
                      child: const Text('Seleccionar hora de fin'),
                    ),
                    Text(selectedEndTime != null
                        ? 'Hora de fin seleccionada: ${selectedEndTime!.format(context)}'
                        : 'No se ha seleccionado hora de fin'),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => saveEvent(context),
                  child: const Text('Guardar Evento'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
