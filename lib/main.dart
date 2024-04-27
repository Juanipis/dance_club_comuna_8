import 'package:dance_club_comuna_8/firebase_options.dart';
import 'package:dance_club_comuna_8/logic/bloc/auth/auth_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_bloc.dart';
import 'package:dance_club_comuna_8/presentation/screen/test/get_attend.dart';
import 'package:dance_club_comuna_8/presentation/screen/test/insert_test.dart';
import 'package:dance_club_comuna_8/presentation/screen/test/login_test.dart';
import 'package:dance_club_comuna_8/logic/services/auth_service.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_events_service.dart';
import 'package:dance_club_comuna_8/presentation/screen/test/update_event.dart';
import 'package:dance_club_comuna_8/presentation/screen/test/view_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final FirestoreEventsService firestoreEventsService =
      FirestoreEventsService();
  final AuthService authService = AuthService();
  runApp(MyApp(
      firestoreEventsService: firestoreEventsService,
      authService: authService));
}

class MyApp extends StatelessWidget {
  final FirestoreEventsService firestoreEventsService;
  final AuthService authService;

  const MyApp(
      {super.key,
      required this.firestoreEventsService,
      required this.authService});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EventBloc>(
          create: (context) => EventBloc(firestoreEventsService),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authService: authService),
        ),
      ],
      child: MaterialApp(
        title: 'Club de danza comuna 8',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InsertEventPage()),
                );
              },
              child: const Text('Agregar Evento'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginWidget()),
                );
              },
              child: const Text('Iniciar sesión'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EventNavigationPage()),
                );
              },
              child: const Text('Ver eventos'),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EventAttendeesWidget()));
                },
                child: const Text('Ver asistentes')),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UpdateEventPage()));
                },
                child: const Text('Actualizar evento')),
          ],
        ),
      ),
    );
  }
}
