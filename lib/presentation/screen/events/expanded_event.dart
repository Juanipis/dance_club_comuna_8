import 'package:dance_club_comuna_8/logic/bloc/event/event_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:dance_club_comuna_8/presentation/widgets/event/register_dialog.dart';
import 'package:dance_club_comuna_8/presentation/widgets/google_calendar_button.dart';
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
            return _buildEventContent(state.event);
          } else if (state is EventErrorState) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text("No hay eventos"));
          }
        },
      ),
    );
  }

  Widget _buildEventContent(Event event) {
    var isNetworkImage =
        event.imageUrl.startsWith('http') || event.imageUrl.startsWith('https');
    var image = isNetworkImage
        ? Image.network(
            event.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return expandedEventPlaceHolderImage();
            },
          )
        : expandedEventPlaceHolderImage();

    var formattedDate =
        DateFormat('EEEE, d MMMM, HH:mm', 'es_ES').format(event.date);
    var formattedEndDate = DateFormat('HH:mm', 'es_ES').format(event.endDate);
    bool isEventFull = event.attendes >= event.maxAttendees;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  image,
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formattedDate,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        _buildEventDetail('Finaliza a las', formattedEndDate),
                        _buildEventDetail('Instrucciones', event.instructions),
                        _buildEventDetail('Dirección', event.address),
                        _buildAttendeeInfo(event.attendes, event.maxAttendees),
                        const SizedBox(height: 16),
                        if (!isEventFull) _buildRegisterButton(event),
                        if (isEventFull)
                          const Text(
                            'Evento lleno',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        const SizedBox(height: 16),
                        GoogleCalendarButton(event: event),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeeInfo(int current, int max) {
    return Row(
      children: [
        const Icon(Icons.people, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          'Asistentes: $current / $max',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildRegisterButton(Event event) {
    return FilledButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return RegisterDialog(title: event.title, eventId: event.id);
          },
        );
      },
      icon: const Icon(Icons.event_available),
      label: const Text('Registrarse'),
    );
  }
}
