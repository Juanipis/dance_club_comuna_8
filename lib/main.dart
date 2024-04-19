import 'package:dance_club_comuna_8/firebase_options.dart';
import 'package:dance_club_comuna_8/logic/bloc/auth/auth_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_bloc.dart';
import 'package:dance_club_comuna_8/logic/presentation/screen/test/insert_test.dart';
import 'package:dance_club_comuna_8/logic/presentation/screen/test/login_test.dart';
import 'package:dance_club_comuna_8/logic/services/auth_service.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final FirestoreService firestoreService = FirestoreService();
  final AuthService authService = AuthService();
  runApp(MyApp(firestoreService: firestoreService, authService: authService));
}

class MyApp extends StatelessWidget {
  final FirestoreService firestoreService;
  final AuthService authService;

  const MyApp(
      {super.key, required this.firestoreService, required this.authService});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EventBloc>(
          create: (context) => EventBloc(firestoreService),
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

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
            const Text(
              'Hola mundo',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
