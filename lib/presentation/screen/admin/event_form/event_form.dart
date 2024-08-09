import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_admin_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/presentation/widgets/image_selection.dart';

class EventForm extends StatefulWidget {
  final bool isUpdate;
  final Event? existingEvent;

  const EventForm({super.key, this.isUpdate = false, this.existingEvent});

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController instructionsController;
  late TextEditingController addressController;
  late TextEditingController imageUrlController;
  late TextEditingController maxAttendeesController;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime? selectedEndDate;
  TimeOfDay? selectedEndTime;

  @override
  void initState() {
    super.initState();
    final event = widget.existingEvent;
    titleController = TextEditingController(text: event?.title ?? '');
    descriptionController =
        TextEditingController(text: event?.description ?? '');
    instructionsController =
        TextEditingController(text: event?.instructions ?? '');
    addressController = TextEditingController(text: event?.address ?? '');
    imageUrlController = TextEditingController(text: event?.imageUrl ?? '');
    maxAttendeesController =
        TextEditingController(text: event?.maxAttendees.toString() ?? '');
    selectedDate = event?.date;
    selectedTime = event != null
        ? TimeOfDay(hour: event.date.hour, minute: event.date.minute)
        : null;
    selectedEndDate = event?.endDate;
    selectedEndTime = event != null
        ? TimeOfDay(hour: event.endDate.hour, minute: event.endDate.minute)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          buildTextField(titleController, 'Título del Evento (obligatorio)'),
          const SizedBox(height: 16),
          buildTextField(descriptionController, 'Descripción del Evento'),
          const SizedBox(height: 16),
          buildTextField(instructionsController, 'Instrucciones del Evento'),
          const SizedBox(height: 16),
          buildTextField(addressController, 'Dirección del Evento'),
          const SizedBox(height: 16),
          buildImagePicker(),
          const SizedBox(height: 16),
          buildTextField(
              maxAttendeesController, 'Máximo de asistentes (obligatorio)',
              numeric: true),
          const SizedBox(height: 16),
          buildDateTimePicker('Fecha y Hora de Inicio', selectStartDate),
          const SizedBox(height: 16),
          buildDateTimePicker('Fecha y Hora de Fin', selectEndDate),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: saveEvent,
            icon: const Icon(Icons.save),
            label: const Text('Guardar Evento'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {bool numeric = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
    );
  }

  Widget buildImagePicker() {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: TextField(
            enabled: false,
            controller: imageUrlController,
            decoration:
                const InputDecoration(labelText: 'URL de la imagen del Evento'),
          ),
        ),
        const SizedBox(width: 16),
        imageSelectionButton(context, imageUrlController)
      ],
    );
  }

  Widget buildDateTimePicker(String label, Function() onTap) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(label),
    );
  }

  Future<void> selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      await selectStartTime();
    }
  }

  Future<void> selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        selectedEndDate = picked;
      });
      await selectEndTime();
    }
  }

  Future<void> selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedEndTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedEndTime = picked;
      });
    }
  }

  void saveEvent() {
    final eventBloc = BlocProvider.of<EventAdminBloc>(context);
    if (!checkDates()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor revise las fechas del evento')),
      );
      return;
    }
    final title = titleController.text;
    final int? maxAttendees = int.tryParse(maxAttendeesController.text);
    if (title.isEmpty || maxAttendees == null || maxAttendees <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Por favor complete todos los campos obligatorios correctamente')),
      );
      return;
    }

    final initDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final endDate = DateTime(
      selectedEndDate!.year,
      selectedEndDate!.month,
      selectedEndDate!.day,
      selectedEndTime!.hour,
      selectedEndTime!.minute,
    );

    if (widget.isUpdate) {
      eventBloc.add(UpdateEventEvent(
        id: widget.existingEvent!.id,
        date: initDate,
        endDate: endDate,
        title: title,
        description: descriptionController.text,
        instructions: instructionsController.text,
        address: addressController.text,
        imageUrl: imageUrlController.text,
        maxAttendees: maxAttendees,
      ));
    } else {
      eventBloc.add(InserEventEvent(
        date: initDate,
        endDate: endDate,
        title: title,
        description: descriptionController.text,
        instructions: instructionsController.text,
        address: addressController.text,
        imageUrl: imageUrlController.text,
        maxAttendees: maxAttendees,
      ));
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
}
