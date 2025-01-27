import 'package:app_links/app_links.dart';
import 'package:patient/Repository/doctor_repository.dart';
import 'package:patient/Repository/sign_in_repository.dart';
import 'package:patient/blocs/sign_in_bloc.dart';
import 'package:patient/helpers/api_helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'dart:async';
import 'routes/app_routes.dart';
import 'services/api_provider.dart';
import 'Repository/appointment_repository.dart';
import 'screens/components/UserProvider.dart';
import 'firebase_options.dart';
import '../helpers/api_helpers.dart' as http_helpers;

// Global Navigator Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _loadEnvironmentVariables();
  await _setPreferredOrientation();
  await _initializeFirebase();

  ApiProvider apiProvider = ApiProvider();
  AppointmentRepository appointmentRepository =
      AppointmentRepository(apiProvider);
  DoctorRepository doctortRepository = DoctorRepository();
  GoogleSignInRepository sign_in_repository =
      GoogleSignInRepository(apiProvider);

  bool enableSentry = _shouldEnableSentry();

  if (enableSentry) {
    await _initializeSentry(() async {
      await _runApp(
          appointmentRepository, doctortRepository, sign_in_repository);
    });
  } else {
    await _runApp(appointmentRepository, doctortRepository, sign_in_repository);
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
      options.environment = dotenv.env['ENVIRONMENT'] ?? 'prod';
    },
    appRunner: appRunner,
  );
}

Future<void> _runApp(
    AppointmentRepository appointmentRepository,
    DoctorRepository doctortRepository,
    GoogleSignInRepository sign_in_repository) async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider.value(value: appointmentRepository),
        Provider.value(value: doctortRepository),
        Provider(create: (_) => GoogleSignInBloc(sign_in_repository)),
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
  late final AppLinks _appLinks;
  late final StreamSubscription<Uri?> _sub;
  final DeepLinkHandler _deepLinkHandler = DeepLinkHandler();

  @override
  void initState() {
    super.initState();
    _initializeDeepLinking();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<void> _initializeDeepLinking() async {
    //* Instantiate AppLinks early
    _appLinks = AppLinks();

    //* Subscribe to all events (initial link and further deep links)
    _sub = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          //* Add a slight delay to ensure the context is valid
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _deepLinkHandler.handleDeepLink(uri.toString());
            }
          });
        }
      },
      onError: (err, stackTrace) {
        //* Handle exception with your helper
        http_helpers.ApiHelper.handleException(context, err);

        //* Report the exception to Sentry
        Sentry.captureException(err, stackTrace: stackTrace);
      },
    );
  }

  Future<bool> _checkFirstTimeSignIn() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return await userProvider.isFirstTimeSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 845),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        theme: ThemeData(
          textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme),
        ),
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
              String initialRoute = snapshot.data == true
                  ? AppRoutes.signIn
                  : AppRoutes.onboarding;
              if (dotenv.get('ENVIRONMENT', fallback: 'prod') == 'dev') {
                if (ApiHelper.retrieveLocaAPIToken(context) != null) {
                  initialRoute = AppRoutes.appointments;
                }
              }

              return Navigator(
                initialRoute: initialRoute,
                onGenerateRoute: AppRoutes.generateRoute,
              );
            }
          },
        ),
      ),
    );
  }
}

class DeepLinkHandler {
  void handleDeepLink(String link) {
    final uri = Uri.parse(link);

    if (uri.scheme == 'unilinks' && uri.host.contains("pharmanathi.com")) {
      // Use navigatorKey.currentContext safely
      final context = navigatorKey.currentContext;
      if (context != null) {
        navigatorKey.currentState
            ?.pushNamed("${uri.queryParameters['screen']}")
            .catchError((err, stackTrace) {
          //* Log the error using the ApiHelper
          http_helpers.ApiHelper.handleException(context, err);

          //* Report the exception to Sentry with stack trace
          Sentry.captureException(err, stackTrace: stackTrace);

          return err;
        });
      }
    }
  }
}
