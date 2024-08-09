import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:dance_club_comuna_8/presentation/widgets/date_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_admin_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/presentation/widgets/image_selection.dart';

class EventForm extends StatefulWidget {
  final bool isUpdate;
  final Event? existingEvent;
  final String? eventId;

  const EventForm(
      {super.key, this.isUpdate = false, this.existingEvent, this.eventId});

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController instructionsController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController maxAttendeesController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime? selectedEndDate;
  TimeOfDay? selectedEndTime;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate && widget.eventId != null) {
      // Enviar el evento de cargar el evento por ID
      BlocProvider.of<EventAdminBloc>(context)
          .add(LoadEventEventById(id: widget.eventId!));
    } else {
      _loadEventData(widget.existingEvent);
    }
  }

  void _loadEventData(Event? event) {
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
    return BlocBuilder<EventAdminBloc, EventState>(
      builder: (context, state) {
        if (state is LoadEventByIdState) {
          // Cargar los datos del evento al formulario

          _loadEventData(state.event);

          return _buildForm();
        } else if (state is EventInsertedState || state is EventUpdatedState) {
          // Mostrar mensaje de éxito
          _showAlertDialog(
            context,
            state is EventInsertedState
                ? 'Evento añadido'
                : 'Evento actualizado',
            'El evento se ha guardado exitosamente',
          );
        } else if (state is EventErrorState) {
          // Manejar el error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al cargar el evento: ${state.message}')),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    bool numeric = false,
    IconData? leadingIcon,
    int? maxLines,
    String helperText = '',
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        icon: leadingIcon != null ? Icon(leadingIcon) : null,
        helperText: helperText,
      ),
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
      buildCounter: (context,
              {required currentLength, required isFocused, int? maxLength}) =>
          Text('$currentLength de ${maxLength ?? ''}'),
      validator: validator,
    );
  }

  Widget buildImagePicker() {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: TextFormField(
            enabled: false,
            controller: imageUrlController,
            decoration: const InputDecoration(
              labelText: 'URL de la imagen del Evento',
              icon: Icon(Icons.image),
            ),
          ),
        ),
        const SizedBox(width: 16),
        imageSelectionButton(context, imageUrlController)
      ],
    );
  }

  Widget buildDateTimePicker(String label, Function() onTap, IconData avatar) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(avatar),
      label: Text(label),
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

  void _showAlertDialog(BuildContext context, String title, String content) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (title == 'Evento añadido' ||
                    title == 'Evento actualizado') {
                  Navigator.of(context)
                      .pop(); // Cerrar el formulario después de guardar
                }
              },
            ),
          ],
        );
      },
    );
  }

  void saveEvent() {
    if (_formKey.currentState?.validate() ?? false) {
      final eventBloc = BlocProvider.of<EventAdminBloc>(context);
      if (!checkDates()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor revise las fechas del evento'),
          ),
        );
        return;
      }
      final title = titleController.text;
      final int? maxAttendees = int.tryParse(maxAttendeesController.text);

      if (maxAttendees == null || maxAttendees <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor ingrese un número válido de asistentes'),
          ),
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
        if (widget.eventId == null) {
          return;
        }
        eventBloc.add(UpdateEventEvent(
          id: widget.eventId!,
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

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            buildTextField(
              titleController,
              'Título del Evento',
              leadingIcon: Icons.title,
              helperText: "Obligatorio",
              maxLength: 50,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El título es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            buildTextField(
              descriptionController,
              'Descripción del Evento',
              leadingIcon: Icons.description,
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 16),
            buildTextField(
              instructionsController,
              'Instrucciones del Evento',
              leadingIcon: Icons.info,
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            buildTextField(
              addressController,
              'Dirección del Evento',
              leadingIcon: Icons.location_on,
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            buildImagePicker(),
            const SizedBox(height: 16),
            buildTextField(
              maxAttendeesController,
              'Máximo de asistentes',
              numeric: true,
              leadingIcon: Icons.people,
              helperText: "Obligatorio",
              maxLength: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El número máximo de asistentes es obligatorio';
                }
                final int? maxAttendees = int.tryParse(value);
                if (maxAttendees == null || maxAttendees <= 0) {
                  return 'Ingrese un número válido de asistentes';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      buildDateTimePicker('Fecha y Hora de Inicio',
                          selectStartDate, Icons.event_available),
                      if (selectedDate != null && selectedTime != null)
                        DateTimeDisplay(
                          isStart: true,
                          selectedDate: selectedDate,
                          selectedTime: selectedTime,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      buildDateTimePicker('Fecha y Hora de Fin', selectEndDate,
                          Icons.event_busy),
                      if (selectedEndDate != null && selectedEndTime != null)
                        DateTimeDisplay(
                          isStart: false,
                          selectedDate: selectedEndDate,
                          selectedTime: selectedEndTime,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: saveEvent,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Evento'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
