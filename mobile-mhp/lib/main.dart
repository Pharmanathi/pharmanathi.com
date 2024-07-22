// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharma_nathi/firebase_options.dart';
import 'package:pharma_nathi/repositories/speciality_repository.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'blocs/doctor_bloc.dart';
import 'blocs/speciality_bloc.dart';
import 'helpers/http_helpers.dart';
import 'repositories/appointment_repository.dart';
import 'repositories/doctor_repository.dart';
import 'repositories/user_repository.dart';
import 'routes/app_routes.dart';
import 'services/api_provider.dart';
import 'screens/components/UserProvider.dart';
import 'screens/components/image_data.dart';

import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _loadEnvironmentVariables();
  await _setPreferredOrientation();
  await _initializeFirebase();

  ApiProvider apiProvider = ApiProvider();
  AppointmentRepository appointmentRepository =
      AppointmentRepository(apiProvider);
  UserRepository userRepository = UserRepository(apiProvider);
  SpecialityRepository specialityRepository = SpecialityRepository(apiProvider);
  DoctorRepository doctorRepository = DoctorRepository(apiProvider);

  bool enableSentry = _shouldEnableSentry();

  if (enableSentry) {
    await _initializeSentry(() async {
      await _runApp(appointmentRepository, userRepository, specialityRepository,
          doctorRepository);
    });
  } else {
    await _runApp(appointmentRepository, userRepository, specialityRepository,
        doctorRepository);
  }
}

Future<void> _loadEnvironmentVariables() async {
  // Load environment variables from appropriate .env file
  await dotenv.load(
      fileName: kReleaseMode ? '.env.production' : '.env.development');
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

Future<void> _runApp(
    AppointmentRepository appointmentRepository,
    UserRepository userRepository,
    SpecialityRepository specialityRepository,
    DoctorRepository doctorRepository) async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageDataProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider<SpecialityBloc>(
            create: (_) => SpecialityBloc(specialityRepository)),
             ChangeNotifierProvider<DoctorBloc>(
            create: (_) => DoctorBloc(doctorRepository)),
        Provider.value(value: appointmentRepository),
        Provider.value(value: userRepository),
        Provider.value(value: specialityRepository),
        Provider.value(value: doctorRepository),
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

class _MyAppState extends State<MyApp> {
  Future<bool> _checkFirstTimeSignIn() async {
    final userProvider = UserProvider();
    return await userProvider.isFirstTimeSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
              if (Apihelper.retrieveLocaAPIToken(context) != null) {
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
