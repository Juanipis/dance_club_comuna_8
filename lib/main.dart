import 'package:dance_club_comuna_8/logic/bloc/auth/auth_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_admin_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/images/image_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_bloc.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_presentations_service.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_storage_service.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/admin_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
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
import 'package:dance_club_comuna_8/logic/services/auth_service.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_events_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Logger logger = Logger();
  logger.i(
      const String.fromEnvironment('DEBUG_KEY', defaultValue: 'default_key'));

  await FirebaseAppCheck.instance.activate(
    webProvider: kReleaseMode
        ? ReCaptchaV3Provider(const String.fromEnvironment(
            'RECAPTCHA_V3_SITE_KEY',
            defaultValue: 'default_key'))
        : ReCaptchaV3Provider(const String.fromEnvironment('DEBUG_KEY',
            defaultValue: 'default_key')),
    // androidProvider: AndroidProvider.playIntegrity,
  );

  final FirestoreEventsService firestoreEventsService =
      FirestoreEventsService();
  final AuthService authService = AuthService();
  final FirestoreStorageService bucketService = FirestoreStorageService();
  final FirestorePresentationsService firestorePresentationsService =
      FirestorePresentationsService();
  runApp(MyApp(
      firestoreEventsService: firestoreEventsService,
      authService: authService,
      bucketService: bucketService,
      firestorePresentationsService: firestorePresentationsService));
}

class MyApp extends StatelessWidget {
  final FirestoreEventsService firestoreEventsService;
  final AuthService authService;
  final FirestoreStorageService bucketService;
  final FirestorePresentationsService firestorePresentationsService;

  const MyApp(
      {super.key,
      required this.firestoreEventsService,
      required this.authService,
      required this.bucketService,
      required this.firestorePresentationsService});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EventBloc>(
          create: (context) => EventBloc(firestoreEventsService),
        ),
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authService: authService)..add(AppStarted()),
        ),
        BlocProvider<EventRegisterBloc>(
          create: (context) => EventRegisterBloc(firestoreEventsService),
        ),
        BlocProvider<EventAdminBloc>(
            create: (context) => EventAdminBloc(firestoreEventsService)),
        BlocProvider<ImageBloc>(
            create: (context) =>
                ImageBloc(firestoreStorageService: bucketService)),
        BlocProvider<PresentationsBloc>(
          create: (context) => PresentationsBloc(
            firestorePresentationsService: (firestorePresentationsService),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Danzas la ladera alma y tradición',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange.shade200),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Danzas la ladera alma y tradición'),
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
    'title': 'Danzas la ladera alma y tradición',
    'imageBackground': 'assets/images/0014.webp',
  };
  var backgrounds = [
    'assets/images/0014.webp',
    'assets/images/0015.webp',
    'assets/images/0014.webp',
    'assets/images/0010.webp',
    'assets/images/0015.webp',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var screens = [
      (
        const BuildHomeScreen(),
        'Página principal',
      ),
      (const BuildAboutScreen(), '¿Quiénes somos?'),
      (const BuildPresentationsScreen(), 'Presentaciones'),
      (const BuildEventsScreen(), 'Eventos'),
      (const BuildContactScreen(), 'Contacto'),
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
            padding: const EdgeInsets.symmetric(
                horizontal: 8.0, vertical: 4.0), // Añadimos padding
            decoration: BoxDecoration(
              color: selectedScreenIndex == i
                  ? Theme.of(context).primaryColor.withOpacity(
                      0.7) // Fondo semitransparente basado en el tema cuando está seleccionado
                  : Theme.of(context).primaryColorDark.withOpacity(
                      0.8), // Fondo semitransparente cuando no está seleccionado
              border: Border(
                bottom: BorderSide(
                  color: selectedScreenIndex == i
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              borderRadius: BorderRadius.circular(4.0), // Bordes redondeados
            ),
            child: Text(
              screens[i].$2,
              style: const TextStyle(
                color: Colors.white, // Color de texto siempre blanco
              ),
            ),
          ),
        ),
      IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AdminScreen()));
          },
          icon: const Icon(Icons.lock))
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
      ListTile(
        title: const Text('Admin'),
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AdminScreen()));
        },
      ),
    ];

    return Scaffold(
      drawer: screenWidth < 680
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
            leading: screenWidth < 680
                ? Builder(
                    builder: (context) => Container(
                      // color: Colors.red, // Si se quiere cambiar el fondo del color
                      color: Colors.transparent,
                      child: IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  )
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Image.asset(
                    backgrounds[selectedScreenIndex],
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    fit: BoxFit.cover,
                    alignment: const Alignment(1.0, -0.3),
                  ),
                  Container(
                    color: Theme.of(context).primaryColor.withOpacity(
                        0.7), // Fondo semitransparente usando el del tema
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      resources['title'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 60,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            actions: screenWidth > 680 ? actionsBiggerScreen : [],
          ),
          SliverToBoxAdapter(
            child: screens[selectedScreenIndex].$1,
          )
        ],
      ),
    );
  }
}
