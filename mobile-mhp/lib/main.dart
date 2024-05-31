// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharma_nathi/screens/components/forms/form1.dart';
import 'package:pharma_nathi/screens/components/forms/form2.dart';
import 'package:pharma_nathi/screens/components/forms/form3.dart';
import 'package:pharma_nathi/screens/components/forms/form4.dart';
import 'package:pharma_nathi/screens/pages/onboard_page.dart';
import 'package:pharma_nathi/screens/pages/signIn.dart';
import 'package:provider/provider.dart';
import 'helpers/http_helpers.dart';
import 'screens/pages/appointments.dart';
import 'screens/pages/earnings.dart';
import 'screens/pages/home_page.dart';
import 'screens/pages/patient_list.dart';
import 'screens/pages/profile.dart';

import 'screens/components/UserProvider.dart';
import 'screens/components/image_data.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // Set preferred orientation before initializing Firebase
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageDataProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
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
    //* Obtain an instance of UserProvider
    final userProvider = UserProvider();

    //* Check if it's the first time sign-in
    return await userProvider.isFirstTimeSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        //* Check if it's the first time signing
        future: _checkFirstTimeSignIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink(); //* Return an empty SizedBox
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            //* Determine the initial route based on whether it's the first time
            String initialRoute =
                snapshot.data == true ? '/signIn' : '/onboarding';
            if (dotenv.get('ENVIRONMENT', fallback: 'prod') == 'dev') {
              if (Apihelper.retrieveLocaAPIToken(context) != null) {
                initialRoute = '/home_page';
              }
            }
            return Navigator(
              initialRoute: initialRoute,
              onGenerateRoute: (settings) {
                // print('Requested Route: ${settings.name}');
                try {
                  switch (settings.name) {
                    case '/onboarding':
                      return MaterialPageRoute(
                        builder: (context) => OnboardScreen(
                          currentIndex: 0,
                          form1Key: GlobalKey<Form1State>(),
                          form2Key: GlobalKey<Form2State>(),
                          form3Key: GlobalKey<Form3State>(),
                          form4Key: GlobalKey<Form4State>(),
                        ),
                      );

                    case '/signIn':
                      return MaterialPageRoute(
                        builder: (context) => const GoogleSignInWidget(),
                      );
                    case '/home_page':
                      return MaterialPageRoute(
                        builder: (context) => HomePage(),
                      );
                    case '/appointments':
                      return MaterialPageRoute(
                        builder: (context) => Appointments(),
                      );
                    case '/earnings':
                      return MaterialPageRoute(
                        builder: (context) => const Earnings(),
                      );
                    case '/patient_list':
                      return MaterialPageRoute(
                        builder: (context) => const PatientList(),
                      );
                    case '/profile':
                      return MaterialPageRoute(
                        builder: (context) => MyProfile(
                          onImageChanged: (newImage) {
                            // print('New image selected: $newImage');
                          },
                        ),
                      );
                    default:
                      return null;
                  }
                } catch (e) {
                  // print('Error navigating to ${settings.name}: $e');

                  //* Close the loading indicator on error
                  Navigator.pop(context);

                  //* Return null to handle the error route
                  return null;
                }
              },
            );
          }
        },
      ),
    );
  }
}
