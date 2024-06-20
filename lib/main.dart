import 'package:dance_club_comuna_8/logic/bloc/auth/auth_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_admin_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/images/image_bloc.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_storage_service.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/admin_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  await FirebaseAppCheck.instance.activate(
    webProvider: kReleaseMode
        ? ReCaptchaV3Provider(const String.fromEnvironment(
            'RECAPTCHA_V3_SITE_KEY',
            defaultValue: 'default_key'))
        : ReCaptchaV3Provider(const String.fromEnvironment('DEBUG_KEY',
            defaultValue: 'default_key')),
    androidProvider: AndroidProvider.debug,
  );

  final FirestoreEventsService firestoreEventsService =
      FirestoreEventsService();
  final AuthService authService = AuthService();
  final FirestoreStorageService bucketService = FirestoreStorageService();

  runApp(MyApp(
      firestoreEventsService: firestoreEventsService,
      authService: authService,
      bucketService: bucketService));
}

class MyApp extends StatelessWidget {
  final FirestoreEventsService firestoreEventsService;
  final AuthService authService;
  final FirestoreStorageService bucketService;

  const MyApp(
      {super.key,
      required this.firestoreEventsService,
      required this.authService,
      required this.bucketService});
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
      drawer: screenWidth < 650
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
            leading: screenWidth < 650
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
