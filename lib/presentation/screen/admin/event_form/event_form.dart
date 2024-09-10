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

  final String? eventId;

  const EventForm({super.key, this.isUpdate = false, this.eventId});

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
  Event? existingEvent;
  bool dataLoaded = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate && widget.eventId != null) {
      // Enviar el evento de cargar el evento por ID
      BlocProvider.of<EventAdminBloc>(context)
          .add(LoadEventEventById(id: widget.eventId!));
    } else {
      _loadEventData(null);
    }
  }

  void _loadEventData(Event? event) {
    if (dataLoaded) {
      return;
    }
    titleController.text = event?.title ?? '';
    descriptionController.text = event?.description ?? '';
    instructionsController.text = event?.instructions ?? '';
    addressController.text = event?.address ?? '';
    imageUrlController.text = event?.imageUrl ?? '';
    maxAttendeesController.text = event?.maxAttendees.toString() ?? '';

    selectedDate = event?.date ?? DateTime.now();
    selectedTime = event != null
        ? TimeOfDay(hour: event.date.hour, minute: event.date.minute)
        : TimeOfDay.now();
    selectedEndDate =
        event?.endDate ?? DateTime.now().add(const Duration(hours: 1));
    selectedEndTime = event != null
        ? TimeOfDay(hour: event.endDate.hour, minute: event.endDate.minute)
        : TimeOfDay.now();

    if (widget.isUpdate) {
      existingEvent = event;
    }
    dataLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventAdminBloc, EventState>(
      listener: (context, state) {
        if (state is EventInsertedState || state is EventUpdatedState) {
          _showAlertDialog(
            context,
            widget.isUpdate ? 'Evento actualizado' : 'Evento añadido',
            'El evento se ha guardado exitosamente',
          );
        } else if (state is EventErrorState) {
          _showErrorSnackBar(context, 'Error: ${state.message}');
        } else if (state is EventDosentExistState) {
          _showErrorSnackBar(context, 'Error: El evento no existe');
        } else if (state is EventCannotUpdateMaxAttendeesState) {
          _showErrorSnackBar(context,
              'Error: No se puede actualizar el número máximo de asistentes, ya que hay asistentes registrados');
        }
      },
      child: BlocBuilder<EventAdminBloc, EventState>(
        builder: (context, state) {
          if (state is LoadEventByIdState) {
            _loadEventData(state.event);
          } else if (state is EventLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          return buildForm(context);
        },
      ),
    );
  }

  SingleChildScrollView buildForm(BuildContext context) {
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
            if (widget.isUpdate && existingEvent != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Asistentes actuales: ${existingEvent!.attendes}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
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

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
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
    // Si existe un select end date, first date debe estar antes que initial date
    // initial date debe ser la fecha seleccionada en el select end date, si no existe es la fecha actual
    // first date siempre debe ser 10 dias antes de la fecha que esté en intial date sea la actual o la seleccionada
    DateTime firstDate = DateTime.now();
    if (selectedEndDate != null) {
      firstDate = selectedDate!.subtract(const Duration(days: 10));
    } else {
      firstDate = firstDate.subtract(const Duration(days: 10));
    }
    // last date debe ser 5 años despues de la selected date en caso de que exista, si no es la fecha actual
    DateTime lastDate = DateTime.now();
    if (selectedDate != null) {
      lastDate = selectedDate!.add(const Duration(days: 365 * 5));
    } else {
      lastDate = DateTime.now().add(const Duration(days: 365 * 5));
    }
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: firstDate,
        lastDate: lastDate);
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
    // El initial date debe ser selected date si existe, si no es la fecha actual
    // el first date debe ser 10 dias antes de la fecha seleccionada en initial date
    // el last date debe ser 5 años despues de la fecha seleccionada en initial date

    DateTime firstDate = DateTime.now();
    if (selectedDate != null) {
      firstDate = selectedEndDate!.subtract(const Duration(days: 10));
    } else {
      firstDate = firstDate.subtract(const Duration(days: 10));
    }
    DateTime lastDate = DateTime.now();
    if (selectedDate != null) {
      lastDate = selectedEndDate!.add(const Duration(days: 365 * 5));
    } else {
      lastDate = DateTime.now().add(const Duration(days: 365 * 5));
    }

    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate:
            selectedEndDate ?? DateTime.now().add(const Duration(hours: 1)),
        firstDate: firstDate,
        lastDate: lastDate);
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
                  Navigator.of(context).pop(); // Dismiss the dialog
                  Navigator.of(context).pop(); // Go back to previous screen
                },
              ),
            ],
          );
        },
      );
    });
  }

  void saveEvent() {
    if (_formKey.currentState?.validate() ?? false) {
      final eventBloc = BlocProvider.of<EventAdminBloc>(context);
      if (!checkDates()) {
        _showErrorSnackBar(
            context, 'La fecha de inicio debe ser antes que la fecha de fin');
        return;
      }
      final title = titleController.text;
      final int? maxAttendees = int.tryParse(maxAttendeesController.text);

      if (maxAttendees == null || maxAttendees <= 0) {
        _showErrorSnackBar(context, 'Ingrese un número válido de asistentes');
        return;
      }

      if (widget.isUpdate &&
          existingEvent != null &&
          existingEvent!.attendes > maxAttendees) {
        _showErrorSnackBar(context,
            'No se puede reducir el número máximo de asistentes, ya que hay asistentes registrados');
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
}
