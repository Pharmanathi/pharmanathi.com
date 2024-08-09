import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'routes/app_routes.dart';
import 'services/api_provider.dart';
import 'Repository/appointment_repository.dart';
import 'screens/components/UserProvider.dart';
import 'firebase_options.dart';
import 'helpers/api_helpers.dart';

// Global Navigator Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _loadEnvironmentVariables();
  await _setPreferredOrientation();
  await _initializeFirebase();

  ApiProvider apiProvider = ApiProvider();
  AppointmentRepository appointmentRepository = AppointmentRepository(apiProvider);

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
        Provider(create: (_) => DeepLinkHandler()),
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
  late StreamSubscription _sub;
  final DeepLinkHandler _deepLinkHandler = DeepLinkHandler();
  
  @override
  void initState() {
    super.initState();
    _initializeDeepLinking();
    
  }

  Future<void> _initializeDeepLinking() async {
    try {
      //* Handle the case when the app is started by a deep link
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _deepLinkHandler.handleDeepLink(initialLink);
      }

      //* Handle the case when the app is already running and receives a deep link
      _sub = linkStream.listen(
        (String? link) {
          if (link != null) {
            // Add a slight delay to ensure the context is valid
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                _deepLinkHandler.handleDeepLink(link);
              }
            });
          }
        },
        onError: (err) {
          print("Link stream error: $err");
        },
      );
    } on Exception catch (e) {
      print("Deep linking initialization error: $e");
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<bool> _checkFirstTimeSignIn() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return await userProvider.isFirstTimeSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, 
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

class DeepLinkHandler {
  void handleDeepLink(String link) {
    final uri = Uri.parse(link);
    if (uri.scheme == 'unilinks' && uri.host.contains("pharmanathi.com")) {
      navigatorKey.currentState?.pushNamed("${uri.queryParameters['screen']}").catchError((e) {
        print("Error during navigation: $e"); // Log to Sentry if needed
      });
    }
  }
}