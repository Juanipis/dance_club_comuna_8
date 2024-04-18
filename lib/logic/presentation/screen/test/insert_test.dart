import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';

class InsertEventPage extends StatefulWidget {
  const InsertEventPage({Key? key}) : super(key: key);

  @override
  State<InsertEventPage> createState() => _InsertEventPageState();
}

class _InsertEventPageState extends State<InsertEventPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insertar Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título del Evento',
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción del Evento',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final eventBloc = BlocProvider.of<EventBloc>(context);
                eventBloc.add(InserEventEvent(
                  date: DateTime.now(),
                  title: titleController.text,
                  description: descriptionController.text,
                  instructions: "Ninguna",
                  address: "Dirección por definir",
                  imageUrl: "",
                  attendees: 1,
                ));
              },
              child: const Text('Guardar Evento'),
            ),
          ],
        ),
      ),
    );
  }
}
