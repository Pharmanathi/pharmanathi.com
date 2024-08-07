import 'package:client_pharmanathi/Repository/appointment_repository.dart';
import 'package:client_pharmanathi/routes/app_routes.dart';
import 'package:client_pharmanathi/services/api_provider.dart';
import 'package:client_pharmanathi/screens/components/UserProvider.dart';
import 'package:client_pharmanathi/helpers/api_helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _loadEnvironmentVariables();
  await _setPreferredOrientation();
  await _initializeFirebase();

  ApiProvider apiProvider = ApiProvider();
  AppointmentRepository appointmentRepository =
      AppointmentRepository(apiProvider);

  bool enableSentry = _shouldEnableSentry();

  if (enableSentry) {
    await _initializeSentry(() async {
      await _runApp(appointmentRepository);
    });
  } else {
    await _runApp(appointmentRepository);
  }
}

Future<void> _loadEnvironmentVariables() async {
  await dotenv.load();
}

Future<void> _setPreferredOrientation() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

bool _shouldEnableSentry() {
  String sentryOnSetting = dotenv.get("SENTRY_ON", fallback: 'false');
  return sentryOnSetting == "true" || kReleaseMode;
}

Future<void> _initializeSentry(Future<void> Function() appRunner) async {
  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN']!;
      options.environment = dotenv.env['ENVIRONMENT'] ?? 'production';
    },
    appRunner: appRunner,
  );
}

Future<void> _runApp(AppointmentRepository appointmentRepository) async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider.value(value: appointmentRepository),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handleIncomingLinks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleIncomingLinks();
    }
  }

  void _handleIncomingLinks() {
    PlatformDispatcher.instance.onPlatformMessage = (String name,
        ByteData? data, PlatformMessageResponseCallback? callback) {
      if (name == 'flutter/navigation' && data != null) {
        final String url =
            String.fromCharCodes(data.buffer.asUint8List()).substring(8);
        final Uri uri = Uri.parse(url);
        _handleUri(uri);
      }
      if (callback != null) {
        callback(ByteData(0));
      }
    };
  }

  void _handleUri(Uri uri) {
    if (uri.scheme == 'Pharmanathi.com' && uri.host == 'payment') {
      final reference = uri.queryParameters['reference'];
      if (reference != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.appointments);
      }
    }
  }

  Future<bool> _checkFirstTimeSignIn() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return await userProvider.isFirstTimeSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoutes.generateRoute,
      home: FutureBuilder<bool>(
        future: _checkFirstTimeSignIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            String initialRoute =
                snapshot.data == true ? AppRoutes.signIn : AppRoutes.onboarding;
            if (dotenv.get('ENVIRONMENT', fallback: 'prod') == 'dev') {
              if (ApiHelper.retrieveLocaAPIToken(context) != null) {
                initialRoute = AppRoutes.homePage;
              }
            }

            return Navigator(
              initialRoute: initialRoute,
              onGenerateRoute: AppRoutes.generateRoute,
            );
          }
        },
      ),
    );
  }
}
