import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:dance_club_comuna_8/firebase_options.dart';
import 'package:dance_club_comuna_8/logic/bloc/auth/auth_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_register_bloc.dart';
import 'package:dance_club_comuna_8/presentation/screen/about/about_screen.dart';
import 'package:dance_club_comuna_8/presentation/screen/contact/contact_screen.dart';
import 'package:dance_club_comuna_8/presentation/screen/events/events_screen.dart';
import 'package:dance_club_comuna_8/presentation/screen/home/home_screen.dart';
import 'package:dance_club_comuna_8/presentation/screen/presentations/presentations_screen.dart';
import 'package:dance_club_comuna_8/presentation/screen/test/get_attend.dart';
import 'package:dance_club_comuna_8/presentation/screen/test/insert_test.dart';
import 'package:dance_club_comuna_8/presentation/screen/test/login_test.dart';
import 'package:dance_club_comuna_8/logic/services/auth_service.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_events_service.dart';
import 'package:dance_club_comuna_8/presentation/screen/test/update_event.dart';
import 'package:dance_club_comuna_8/presentation/screen/test/view_events.dart';
import 'package:firebase_core/firebase_core.dart';
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
        BlocProvider<EventRegisterBloc>(
          create: (context) => EventRegisterBloc(firestoreEventsService),
        ),
      ],
      child: MaterialApp(
        title: 'Club de danza comuna 8',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange.shade200),
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
  var logger = Logger();
  var selectedScreenIndex = 0;
  var resources = {
    'leadingLogo': 'assets/images/logo.png',
    'title': 'Danzas la ladera',
    'imageBackground': 'assets/images/background.jpg',
  };
  var backgrounds = [
    'assets/images/background.jpg',
    'assets/images/background2.jpg',
    'assets/images/background3.jpg',
    'assets/images/background4.jpg',
    'assets/images/background5.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var screens = [
      (
        buildHomeScreen(context),
        'Página principal',
      ),
      (buildAboutScreen(), '¿Quiénes somos?'),
      (buildPresentationsScreen(), 'Presentaciones'),
      (const BuildEventsScreen(), 'Eventos'),
      (buildContactScreen(), 'Contacto'),
    ];
    var actionsBiggerScreen = [
      for (var i = 0; i < screens.length; i++)
        TextButton(
          onPressed: () {
            setState(() {
              logger.i('Selected screen index: $i');
              selectedScreenIndex = i;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: selectedScreenIndex == i
                      ? Colors.orange
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              screens[i].$2,
              style: TextStyle(
                color: selectedScreenIndex == i ? Colors.orange : Colors.white,
              ),
            ),
          ),
        ),
    ];
    var actionsDrawerSmallScreen = [
      for (var i = 0; i < screens.length; i++)
        ListTile(
          title: Text(screens[i].$2),
          onTap: () {
            setState(() {
              logger.i('Selected screen index: $i');
              selectedScreenIndex = i;
            });
            Navigator.pop(context);
          },
        ),
    ];

    return Scaffold(
      drawer: screenWidth < 558
          ? Drawer(
              shape: const BeveledRectangleBorder(),
              child: ListView(
                padding: EdgeInsets.zero,
                children: actionsDrawerSmallScreen,
              ),
            )
          : null,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor:
                Theme.of(context).colorScheme.primary, // Usar color del tema
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            leading: screenWidth < 558
                ? Builder(
                    builder: (context) => Container(
                      // color: Colors.red, // Si se quiere cambiar el fondo del color
                      child: IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  )
                : Image.asset(resources['leadingLogo'] as String, width: 50),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Image.asset(
                    backgrounds[selectedScreenIndex],
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    resources['title'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ],
              ),
            ),
            actions: screenWidth > 550 ? actionsBiggerScreen : [],
          ),
          SliverToBoxAdapter(
            child: screens[selectedScreenIndex].$1,
          )
        ],
      ),
    );
  }
}




/*
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
 */