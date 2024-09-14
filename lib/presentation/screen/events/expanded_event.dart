import 'package:dance_club_comuna_8/logic/bloc/event/event_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:dance_club_comuna_8/presentation/widgets/event/register_dialog.dart';
import 'package:dance_club_comuna_8/presentation/widgets/placeholder/image_place_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
      ),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LoadEventByIdState) {
            Event event = state.event;

            var isNetworkImage = event.imageUrl.startsWith('http') ||
                event.imageUrl.startsWith('https');

            var image = isNetworkImage
                ? Image.network(
                    event.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    alignment: const Alignment(1.0, -0.3),
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return expandedEventPlaceHolderImage();
                    },
                  )
                : expandedEventPlaceHolderImage();

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
                      'Instrucciones: ${event.instructions}',
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
