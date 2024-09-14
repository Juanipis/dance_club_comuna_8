import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleCalendarButton extends StatelessWidget {
  final Event event;

  const GoogleCalendarButton({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // Formato de fecha para el enlace de Google Calendar
    final startDate = DateFormat('yyyyMMddTHHmmss').format(event.date);
    final endDate = DateFormat('yyyyMMddTHHmmss').format(event.endDate);
    final url = Uri.encodeFull(
        'https://calendar.google.com/calendar/render?action=TEMPLATE&dates=$startDate/$endDate&details=${event.description}&location=${event.address}&text=${event.title}');

    return TextButton.icon(
      onPressed: () {
        launchUrlCalendar(url);
      },
      icon: const Icon(Icons.calendar_today),
      label: const Text('Agregar a Google Calendar'),
    );
  }

  Future<void> launchUrlCalendar(String path) async {
    // Lanzar el enlace en el navegador
    final Uri url = Uri.parse(path);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
