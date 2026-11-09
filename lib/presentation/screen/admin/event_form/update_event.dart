import 'package:dance_club_comuna_8/presentation/screen/admin/event_form/event_form.dart';
import 'package:flutter/material.dart';

class UpdateEventScreen extends StatefulWidget {
  final String eventId;
  const UpdateEventScreen({super.key, required this.eventId});

  @override
  State<UpdateEventScreen> createState() => _UpdateEventScreenState();
}

class _UpdateEventScreenState extends State<UpdateEventScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actualizando evento ${widget.eventId}'),
      ),
      body: EventForm(
        isUpdate: true,
        eventId: widget.eventId,
      ),
    );
  }
}
