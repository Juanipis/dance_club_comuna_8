import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:dance_club_comuna_8/presentation/widgets/placeholder/image_place_holder.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

Widget eventCard({
  required Event event,
  required BuildContext context,
  required Future<void> Function(
          BuildContext context, dynamic eventId, String title)
      refreshEvents,
}) {
  initializeDateFormatting();

  var isNetworkImage =
      event.imageUrl.startsWith('http') || event.imageUrl.startsWith('https');

  var image = isNetworkImage
      ? Image.network(
          event.imageUrl,
          fit: BoxFit.cover,
          width: 300,
          height: 200,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            }
          },
          errorBuilder: (context, error, stackTrace) {
            return eventCardPlaceHolderImage();
          },
        )
      : eventCardPlaceHolderImage();

  //Show the date of the event in style of dayofweek, day of month, hh:mm
  // e.g. "sabado, 12 de diciembre, 18:00"
  var formattedDate =
      DateFormat('EEEE, d \'de\' MMMM, HH:mm', 'es_ES').format(event.date);

  return Card(
    child: Column(
      children: [
        SizedBox(
          width: 300,
          height: 200,
          child: image,
        ),
        Text(event.title, style: const TextStyle(fontSize: 17)),
        const SizedBox(height: 10),
        Text(formattedDate),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              'Asistentes: ${event.attendes}/ ${event.maxAttendees}',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
        ElevatedButton(
            onPressed: () {
              refreshEvents(context, event.id, event.title);
            },
            child: const Text('Inscribirse')),
        const SizedBox(height: 10),
      ],
    ),
  );
}
