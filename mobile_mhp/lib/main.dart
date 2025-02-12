// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharma_nathi/blocs/address_bloc.dart';
import 'package:pharma_nathi/blocs/sign_in_bloc.dart';
import 'package:pharma_nathi/firebase_options.dart';
import 'package:pharma_nathi/repositories/address_repository.dart';
import 'package:pharma_nathi/repositories/sign_in_repository.dart';
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

import 'services/notification_service.dart';

// Global Navigator Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadEnvironmentVariables();
  await _setPreferredOrientation();
  await _initializeFirebase();

  final notificationService = NotificationService();
  await notificationService.initialize(); 

  ApiProvider apiProvider = ApiProvider();
  AppointmentRepository appointmentRepository =
      AppointmentRepository(apiProvider);
  UserRepository userRepository = UserRepository(apiProvider);
  SpecialityRepository specialityRepository = SpecialityRepository(apiProvider);
  AddressRepository addressRepository = AddressRepository(apiProvider);
  DoctorRepository doctorRepository = DoctorRepository(apiProvider);
  GoogleSignInRepository sign_in_repository =
      GoogleSignInRepository(apiProvider);

  bool enableSentry = _shouldEnableSentry();

  if (enableSentry) {
    await _initializeSentry(() async {
      await _runApp(appointmentRepository, userRepository,addressRepository, specialityRepository,
          doctorRepository, sign_in_repository);
    });
  } else {
    await _runApp(appointmentRepository, userRepository, addressRepository ,specialityRepository,
        doctorRepository, sign_in_repository);
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
    AddressRepository addressRepository,
    SpecialityRepository specialityRepository,
    DoctorRepository doctorRepository,
    GoogleSignInRepository sign_in_repository) async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AddressBloc(addressRepository)),
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
        Provider(create: (_) => GoogleSignInBloc(sign_in_repository)),
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
        home: Builder(
          builder: (context) {
            String initialRoute = AppRoutes.signIn;
            if (dotenv.get('ENVIRONMENT', fallback: 'production') ==
                'development') {
              if (Apihelper.retrieveLocaAPIToken(context) != null) {
                initialRoute = AppRoutes.homePage;
              } else {
                initialRoute = AppRoutes.signIn;
              }
            }
            return Navigator(
              initialRoute: initialRoute,
              onGenerateRoute: AppRoutes.generateRoute,
            );
          },
        ),
      ),
    );
  }
}
