import 'package:dance_club_comuna_8/logic/bloc/event/event_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class ExpandedEvent extends StatefulWidget {
  final Event event;
  const ExpandedEvent({super.key, required this.event});

  @override
  State<ExpandedEvent> createState() => _ExpandedEventState();
}

class _ExpandedEventState extends State<ExpandedEvent> {
  @override
  Widget build(BuildContext context) {
    var placeHolderImage = 'assets/images/placeholder1.jpg';
    var isNetworkImage = widget.event.imageUrl.startsWith('http') ||
        widget.event.imageUrl.startsWith('https');

    var image = isNetworkImage
        ? Image.network(
            widget.event.imageUrl,
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
        DateFormat('EEEE, d MMMM, HH:mm', 'es_ES').format(widget.event.date);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                widget.event.title,
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
                widget.event.description,
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 16),
              Text(
                'Instrucciones: ${widget.event.instructions}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Dirección: ${widget.event.address}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.people, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Cupo máximo: ${widget.event.maxAttendees}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return buildAlertDialog(
                            context, widget.event.title, widget.event.id);
                      });
                },
                icon: const Icon(Icons.event_available),
                label: const Text('Registrarse'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BlocListener<EventBloc, EventState> buildAlertDialog(
    BuildContext dialogContext, String title, String eventId) {
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController name = TextEditingController();
  EventBloc eventBloc = BlocProvider.of<EventBloc>(dialogContext);
  Logger logger = Logger();
  return BlocListener<EventBloc, EventState>(
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
                  Navigator.pop(dialogContext);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else if (state is EventErrorState) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Registro fallido'),
            content: Text(state.message),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(dialogContext);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    },
    child: AlertDialog(
      title: Text("Te estás registrando en $title"),
      content: Column(
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
          const Text(
              'Al registrarte aceptas nuestra política de tratamiento de datos'),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            logger.d(
                'Registrando usuario, evento: $eventId teléfono: ${phoneNumber.text} nombre: ${name.text}');
            eventBloc.add(RegisterUserEvent(
                eventId: eventId, phoneNumber: phoneNumber.text));
          },
          child: const Text('Aceptar'),
        ),
      ],
    ),
  );
}
