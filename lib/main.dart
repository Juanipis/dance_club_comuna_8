import 'package:dance_club_comuna_8/logic/bloc/member/member_bloc.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_member_service.dart';
import 'package:dance_club_comuna_8/presentation/screen/members/members.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:logger/logger.dart';

import 'package:dance_club_comuna_8/firebase_options.dart';
import 'package:dance_club_comuna_8/logic/bloc/auth/auth_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/auth/auth_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_admin_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_register_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/images/image_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_bloc.dart';
import 'package:dance_club_comuna_8/logic/services/auth_service.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_events_service.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_presentations_service.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_storage_service.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/admin_screen.dart';
import 'package:dance_club_comuna_8/presentation/screen/about/about_screen.dart';
import 'package:dance_club_comuna_8/presentation/screen/contact/contact_screen.dart';
import 'package:dance_club_comuna_8/presentation/screen/events/events_screen.dart';
import 'package:dance_club_comuna_8/presentation/screen/home/home_screen.dart';
import 'package:dance_club_comuna_8/presentation/screen/presentations/presentations_screen.dart';
import 'package:dance_club_comuna_8/presentation/widgets/theme.dart';

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
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirestoreEventsService firestoreEventsService =
      FirestoreEventsService();
  final AuthService authService = AuthService();
  final FirestoreStorageService bucketService = FirestoreStorageService();
  final FirestorePresentationsService firestorePresentationsService =
      FirestorePresentationsService();
  final FirestoreMemberService firestoreMemberService =
      FirestoreMemberService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EventBloc>(
          create: (_) => EventBloc(firestoreEventsService),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authService: authService)..add(AppStarted()),
        ),
        BlocProvider<EventRegisterBloc>(
          create: (_) => EventRegisterBloc(firestoreEventsService),
        ),
        BlocProvider<EventAdminBloc>(
          create: (_) => EventAdminBloc(firestoreEventsService),
        ),
        BlocProvider<ImageBloc>(
          create: (_) => ImageBloc(firestoreStorageService: bucketService),
        ),
        BlocProvider<PresentationsBloc>(
          create: (_) => PresentationsBloc(
              firestorePresentationsService: firestorePresentationsService),
        ),
        BlocProvider<MemberBloc>(
          create: (_) => MemberBloc(firestoreMemberService),
        )
      ],
      child: MaterialApp(
        title: 'Danzas la ladera alma y tradición',
        theme: customTheme,
        home: const MyHomePage(title: 'Danzas la ladera alma y tradición'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Logger logger = Logger();
  int selectedScreenIndex = 0;

  // Screens and their properties extracted into a list of ScreenData
  final List<ScreenData> screens = [
    ScreenData(const BuildHomeScreen(), 'Página principal', Icons.home),
    ScreenData(const BuildAboutScreen(), '¿Quiénes somos?', Icons.people),
    ScreenData(const Members(), 'Miembros', Icons.people),
    ScreenData(
        const BuildPresentationsScreen(), 'Presentaciones', Icons.event_seat),
    ScreenData(const BuildEventsScreen(), 'Eventos', Icons.event),
    ScreenData(
        const BuildContactScreen(), 'Contacto', Icons.contact_support_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: screenWidth < 785 ? _buildDrawer() : null,
      body: CustomScrollView(
        slivers: <Widget>[
          _buildSliverAppBar(screenWidth),
          SliverToBoxAdapter(
            child: screens[selectedScreenIndex].screenWidget,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      shape: const BeveledRectangleBorder(),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _buildDrawerItems(),
            ),
          ),
          _buildAdminOption(),
        ],
      ),
    );
  }

  List<Widget> _buildDrawerItems() {
    return screens.map((screenData) {
      return ListTile(
        leading: Icon(screenData.icon),
        title: Text(screenData.title),
        onTap: () {
          setState(() {
            selectedScreenIndex = screens.indexOf(screenData);
          });
          Navigator.pop(context);
        },
      );
    }).toList();
  }

  Widget _buildAdminOption() {
    return ListTile(
      leading: const Icon(Icons.lock),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminScreen()),
        );
      },
    );
  }

  Widget _buildSliverAppBar(double screenWidth) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      leading: screenWidth < 785 ? _buildMenuButton() : null,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildFlexibleSpaceBarBackground(),
      ),
      actions: screenWidth > 785 ? _buildActionButtons() : [],
    );
  }

  Widget _buildMenuButton() {
    return Builder(
      builder: (context) => Container(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        child: IconButton(
          icon:
              Icon(Icons.menu, color: Theme.of(context).colorScheme.secondary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    );
  }

  Stack _buildFlexibleSpaceBarBackground() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Image.asset(
          _getBackgroundImage(),
          width: MediaQuery.of(context).size.width,
          height: 300,
          fit: BoxFit.cover,
          alignment: const Alignment(1.0, -0.3),
        ),
        Container(
          color: Theme.of(context).primaryColor.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: const Text(
            'Danzas la ladera alma y tradición',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.w100,
            ),
          ),
        ),
      ],
    );
  }

  String _getBackgroundImage() {
    const backgrounds = [
      'assets/images/0014.webp',
      'assets/images/0010.webp',
      'assets/images/0015.webp',
      'assets/images/0014.webp',
      'assets/images/0010.webp',
      'assets/images/0015.webp',
    ];
    return backgrounds[selectedScreenIndex];
  }

  List<Widget> _buildActionButtons() {
    return screens.map((screenData) {
      final index = screens.indexOf(screenData);
      return TextButton(
        onPressed: () => setState(() {
          selectedScreenIndex = index;
        }),
        child: _buildActionButtonContent(screenData, index),
      );
    }).toList()
      ..add(
        TextButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AdminScreen()));
          },
          child: const Icon(Icons.lock), // Wrapping Icon in TextButton
        ),
      );
  }

  Widget _buildActionButtonContent(ScreenData screenData, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: selectedScreenIndex == index
            ? Theme.of(context).primaryColor.withOpacity(0.7)
            : Theme.of(context).primaryColorDark.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: selectedScreenIndex == index
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        screenData.title,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class ScreenData {
  final Widget screenWidget;
  final String title;
  final IconData icon;

  ScreenData(this.screenWidget, this.title, this.icon);
}
