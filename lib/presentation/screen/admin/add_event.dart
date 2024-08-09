import 'package:dance_club_comuna_8/logic/bloc/event/event_admin_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/bloc/images/image_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/images/image_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/images/image_states.dart';
import 'package:dance_club_comuna_8/logic/models/image_bucket.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/event_form/event_form.dart';
import 'package:dance_club_comuna_8/presentation/widgets/image_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Evento'),
      ),
      body: const EventForm(),
    );
  }
}
