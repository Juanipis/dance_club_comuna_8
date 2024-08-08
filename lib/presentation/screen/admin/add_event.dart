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
  int selectedImageIndex = 0;
  bool isImageLoading = false;

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
    BlocProvider.of<ImageBloc>(context)
        .add(const GetImagesPathsEvent(path: ''));

    BlocProvider.of<ImageBloc>(context).stream.listen((state) {
      if (state is ImagesPathsLoadedState) {
        setState(() {
          images = state.images;
        });
      }
    });

    imageUrlController.addListener(() {
      setState(() {
        isImageLoading = true;
      });
      // Simulate network image loading
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isImageLoading = false;
        });
      });
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título del Evento (obligatorio)',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción del Evento',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: instructionsController,
                  decoration: const InputDecoration(
                    labelText: 'Instrucciones del Evento',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección del Evento',
                  ),
                ),
                const SizedBox(height: 16),
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
                    const SizedBox(width: 16),
                    DropdownButton<ImageBucket>(
                      value:
                          images.isNotEmpty ? images[selectedImageIndex] : null,
                      onChanged: (ImageBucket? value) {
                        setState(() {
                          imageUrlController.text = value!.imagePath;
                          selectedImageIndex = images.indexOf(value);
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
                const SizedBox(height: 16),
                isImageLoading
                    ? const Center(child: CircularProgressIndicator())
                    : imageUrlController.text.isNotEmpty
                        ? Image.network(
                            imageUrlController.text,
                            height: 150,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text('No se pudo cargar la imagen');
                            },
                          )
                        : const SizedBox.shrink(),
                const SizedBox(height: 16),
                TextField(
                  controller: maxAttendeesController,
                  decoration: const InputDecoration(
                    labelText: 'Máximo de asistentes (obligatorio)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => selectDate(context),
                      child: const Text('Seleccionar fecha'),
                    ),
                    const SizedBox(width: 16),
                    Text(selectedDate != null
                        ? 'Fecha seleccionada: ${selectedDate!.toLocal()}'
                        : 'No se ha seleccionado fecha'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => selectTime(context),
                      child: const Text('Seleccionar hora'),
                    ),
                    const SizedBox(width: 16),
                    Text(selectedTime != null
                        ? 'Hora seleccionada: ${selectedTime!.format(context)}'
                        : 'No se ha seleccionado hora'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => selectEndDate(context),
                      child: const Text('Seleccionar fecha de fin'),
                    ),
                    const SizedBox(width: 16),
                    Text(selectedEndDate != null
                        ? 'Fecha de fin seleccionada: ${selectedEndDate!.toLocal()}'
                        : 'No se ha seleccionado fecha de fin'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => selectEndTime(context),
                      child: const Text('Seleccionar hora de fin'),
                    ),
                    const SizedBox(width: 16),
                    Text(selectedEndTime != null
                        ? 'Hora de fin seleccionada: ${selectedEndTime!.format(context)}'
                        : 'No se ha seleccionado hora de fin'),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => saveEvent(context),
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar Evento'),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
