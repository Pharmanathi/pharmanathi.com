// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pharma_nathi/logging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharma_nathi/screens/components/UserProvider.dart';
import 'package:provider/provider.dart';
import '../../helpers/http_helpers.dart' as http_helpers;
import '../../models/user.dart';
import '../../repositories/user_repository.dart';

class GoogleSignInWidget extends StatefulWidget {
  const GoogleSignInWidget({super.key});

  @override
  State<GoogleSignInWidget> createState() => _GoogleSignInWidgetState();
}

class _GoogleSignInWidgetState extends State<GoogleSignInWidget> {
  final log = logger(GoogleSignInWidget);
  late UserRepository _userRepository;
  List<User> user = [];
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: ['email', 'profile', 'openid']);
  GoogleSignInAccount? _currentUser;
  String apiUrl =
      dotenv.env['API_BASE_URL'] ?? "make sure you have the right url";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userRepository = context.read<UserRepository>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 101, 115, 207),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Container(
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/pharmanathi-mhp-icon.png',
                          height: 100,
                        ),
                        Text(
                          'PHARMA',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color.fromARGB(255, 253, 253, 253),
                          ),
                        ),
                        Text(
                          'NATHI',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            color: Color.fromARGB(255, 247, 247, 251),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 200),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                await _signInWithGoogle();
                              } catch (e) {
                                log.e('Google Sign-In failed: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Failed to sign in. Please try again.'),
                                  ),
                                );
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/google.png',
                            height: 24,
                          ),
                          SizedBox(width: 8),
                          Text('Sign In with Google'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  // Function to handle Google Sign-In process
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Check if sign-in was canceled
      if (googleUser == null) {
        throw Exception('Google Sign-In canceled');
      }

      // Set current user
      setState(() {
        _currentUser = googleUser;
      });

      // Get authentication data
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Send Google Sign-In request to backend and get backend token
      final String backendToken =
          await sendGoogleSignInRequest('${googleAuth.idToken}');

      // Use the Google Sign-In authentication data and backend token
      log.d('User email: ${_currentUser?.email}');
      log.d('User name: ${_currentUser?.displayName}');
      log.d('Google Auth ID Token: ${googleAuth.idToken}');
      log.d('Backend Token: $backendToken');

      // Access the UserProvider and set user information including the backend token
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Set user information including the backend token
      await userProvider.setUserInformation(
        _currentUser?.email ?? '',
        _currentUser?.displayName ?? '',
        _currentUser?.photoUrl ?? '',
        backendToken,
      );

      // Fetch user data using the obtained backend token
      await _fetchUserData(context);

      // Check if it's the first time sign-in
      final isFirstTimeSignInResult = await userProvider.hasIncompleteDoctorProfile();

      if (isFirstTimeSignInResult) {
        // If it's the first sign-in, navigate to the onboarding page
        Navigator.pushReplacementNamed(
          context,
          '/onboarding',
          arguments: {
            'email': _currentUser?.email,
          },
        );
      } else {
        // If it's not the first sign-in, navigate to the home page
        Navigator.pushReplacementNamed(
          context,
          '/home_page',
          arguments: {
            'email': _currentUser?.email,
          },
        );
      }
    } catch (e) {
      // Handle errors
      log.e('Error during Google Sign-In: $e');

      // Show an error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              'Sign-in failed. Please try again.',
            ),
          ),
        ),
      );

      // Navigate to the sign-in page in case of errors
      Navigator.pushReplacementNamed(context, '/signIn');
    } finally {
      // Re-enable the button after the sign-in process
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserData(BuildContext context) async {
    try {
      User? fetchedUser = await _userRepository.fetchUserData(context);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (fetchedUser != null) {
        userProvider.setUserData(fetchedUser);
        setState(() {
          user = [fetchedUser];
          _isLoading = false;
        });
      }
      log.i('userdata: $fetchedUser');
    } catch (e) {
      log.e('Error loading user data: $e');
    }
  }

  // Function to send Google Sign-In request to the backend
  Future<String> sendGoogleSignInRequest(String idToken) async {
    try {
      // Construct the API endpoint using the API base URL
      final apiEndpoint =
          '${http_helpers.apiBaseURL}/google-login-by-id-token?is_doctor=true&id_token=$idToken';

      final response =
          await http_helpers.Apihelper.httpRequestWithAuthorization(
        context,
        apiEndpoint,
        'GET',
        '',
      );

      if (response.statusCode == 200) {
        // Handle a successful response from the backend and return the backend token
        log.d('Backend response: ${response.body}');
        return response.body;
      } else {
        // Handle an unsuccessful response from the backend
        log.d('Backend response: ${response.statusCode}');
        throw Exception('Failed to get backend token');
      }
    } catch (e) {
      // Handle network or other errors
      log.e('Failed to send Google Sign-In request to the backend: $e');
      // Show a Snackbar for network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              'Oops! Something went wrong. Please check your internet connection and try again.',
            ),
          ),
        ),
      );

      throw Exception('Failed to get backend token');
    }
  }
}
