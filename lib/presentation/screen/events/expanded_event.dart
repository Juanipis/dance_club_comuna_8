import 'package:dance_club_comuna_8/logic/bloc/event/event_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_register_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class ExpandedEvent extends StatefulWidget {
  final String eventId;
  final String title;
  const ExpandedEvent({super.key, required this.eventId, required this.title});

  @override
  State<ExpandedEvent> createState() => _ExpandedEventState();
}

class _ExpandedEventState extends State<ExpandedEvent> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<EventBloc>(context).add(
      LoadEventEventById(id: widget.eventId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ],
      ),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LoadEventByIdState) {
            Event event = state.event;
            var placeHolderImage = 'assets/images/placeholder1.jpg';
            var isNetworkImage = event.imageUrl.startsWith('http') ||
                event.imageUrl.startsWith('https');

            var image = isNetworkImage
                ? Image.network(
                    event.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  )
                : Image.asset(
                    placeHolderImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  );

            var formattedDate =
                DateFormat('EEEE, d MMMM, HH:mm', 'es_ES').format(event.date);
            var formattedEndDate =
                DateFormat('HH:mm', 'es_ES').format(event.endDate);
            bool isEventFull = event.attendes >= event.maxAttendees;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: image,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Finaliza a las: $formattedEndDate',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event.description,
                      style: const TextStyle(fontSize: 17),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Instrucciones: $event.instructions}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Dirección: ${event.address}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.people, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Asistentes: ${event.attendes}/ ${event.maxAttendees}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: isEventFull
                          ? null
                          : () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return RegisterDialog(
                                        title: event.title, eventId: event.id);
                                  });
                            },
                      icon: const Icon(Icons.event_available),
                      label: const Text('Registrarse'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                    if (isEventFull)
                      const Text(
                        'Evento lleno',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
            );
          } else if (state is EventErrorState) {
            return Center(
              child: Text(state.message),
            );
          } else {
            return const Center(
              child: Text("No hay eventos"),
            );
          }
        },
      ),
    );
  }
}

class RegisterDialog extends StatefulWidget {
  final String title;
  final String eventId;

  const RegisterDialog({super.key, required this.title, required this.eventId});

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController name = TextEditingController();
  Logger logger = Logger();
  bool isLoading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventRegisterBloc, EventState>(
      listener: (context, state) {
        if (state is UserRegisteredState) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Registro exitoso'),
              content: const Text('Te has registrado exitosamente.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    BlocProvider.of<EventBloc>(context).add(
                      LoadEventEventById(id: widget.eventId),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else if (state is EventErrorState) {
          setState(() {
            isLoading = false;
            error = state.message;
          });
        }
      },
      child: AlertDialog(
        title: Text("Te estás registrando en ${widget.title}"),
        content: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                    ),
                  ),
                  TextField(
                    controller: phoneNumber,
                    decoration: const InputDecoration(
                      labelText: 'Número de teléfono',
                    ),
                  ),
                  if (error != null)
                    Text(
                      error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const Text(
                      'Al registrarte aceptas nuestra política de tratamiento de datos'),
                ],
              ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              logger.d(
                  'Registrando usuario, evento: ${widget.eventId} teléfono: ${phoneNumber.text} nombre: ${name.text}');
              BlocProvider.of<EventRegisterBloc>(context).add(
                RegisterUserEvent(
                  eventId: widget.eventId,
                  phoneNumber: phoneNumber.text,
                  name: name.text,
                ),
              );
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
