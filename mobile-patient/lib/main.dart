// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:client_pharmanathi/screens/pages/onboard_page.dart';
import 'package:client_pharmanathi/screens/pages/singnin_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/components/UserProvider.dart';
import 'firebase_options.dart';
import 'screens/pages/appointment.dart';
import 'screens/pages/doctors.dart';
import 'screens/pages/home_page.dart';
import 'screens/pages/profile_settings.dart';
import 'helpers/api_helpers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //* Load environment variables
  await dotenv.load();

  //* Set preferred orientation before initializing Firebase
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(),
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

            String initialRoute = snapshot.data == true ? '/signIn' : '/onboarding';
            if(dotenv.get('ENVIRONMENT', fallback: 'prod') == 'dev'){
              if(ApiHelper.retrieveLocaAPIToken(context) != null ) {
                initialRoute = '/home_page';
              }
            }

            return Navigator(
              initialRoute: initialRoute,
              onGenerateRoute: (settings) {
                try {
                  switch (settings.name) {
                    case '/onboarding':
                      return MaterialPageRoute(
                        builder: (context) => OnboardScreen(
                          currentIndex: 0,
                          headings: OnboardScreen.sampleHeadings,
                          texts: OnboardScreen.sampleTexts,
                        ),
                      );
                    case '/signIn':
                      return MaterialPageRoute(
                        builder: (context) => GoogleSignInWidget(),
                      );
                    case '/home_page':
                      return MaterialPageRoute(
                        builder: (context) => HomePage(),
                      );
                    case '/doctors':
                      return MaterialPageRoute(
                        builder: (context) => Doctors(),
                      );
                    case '/appointment':
                      return MaterialPageRoute(
                        builder: (context) => Appointments(),
                      );
                    case '/profile_settings':
                      return MaterialPageRoute(
                        builder: (context) => ProfileSetting(),
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
