// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:io';

import 'package:client_pharmanathi/screens/components/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../helpers/api_helpers.dart';

class GoogleSignInWidget extends StatefulWidget {
  @override
  State<GoogleSignInWidget> createState() => _GoogleSignInWidgetState();
}

class _GoogleSignInWidgetState extends State<GoogleSignInWidget> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  static final String apiUrl = ApiHelper.getApiBaseUrl();
  GoogleSignInAccount? _currentUser;
  bool _isLoading = false;

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          'assets/images/pharmanathi-patient-icon.png',
                          height: 100,
                        ),
                        Text(
                          'PHARMA',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color.fromARGB(255, 101, 115, 207),
                          ),
                        ),
                        Text(
                          'NATHI',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            color: Color.fromARGB(255, 101, 115, 207),

                            /// Adjust the text color
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
                                print('Google Sign-In failed: $e');
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
        print('_currentUser set: $_currentUser'); // Debug print
      });

      // Get authentication data
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Send Google Sign-In request to backend and get backend token
      final String backendToken =
          await sendGoogleSignInRequest('${googleAuth.idToken}');

      // Use the Google Sign-In authentication data and backend token
      print('User email: ${_currentUser?.email}');
      print('User name: ${_currentUser?.displayName}');
      print('Google Auth ID Token: ${googleAuth.idToken}');
      print('Backend Token: $backendToken');

      // Access the UserProvider and set user information including the backend token
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Set user information including the backend token
      await userProvider.setUserInformation(
        _currentUser?.email ?? '',
        _currentUser?.displayName ?? '',
        _currentUser?.photoUrl ?? '',
        backendToken,
      );

      // Close the loading dialog
      Navigator.pop(context);

      //* Check if it's the first time sign-in
      final isFirstTimeSignInResult = await userProvider.isFirstTimeSignIn();

      if (isFirstTimeSignInResult) {
        //* If it's the first sign-in, navigate to the onboarding page
        Navigator.pushNamed(
          context,
          '/onboarding',
          arguments: {
            'email': _currentUser?.email,
          },
        );
      } else {
        //* If it's not the first sign-in, navigate to the home page
        Navigator.pushNamed(
          context,
          '/home_page',
          arguments: {
            'email': _currentUser?.email,
          },
        );
      }
    } catch (e) {
      // Handle errors
      print('Error during Google Sign-In: $e');

      // Close the loading dialog
      Navigator.pop(context);

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
      Navigator.pushNamed(context, '/signIn');
    } finally {
      // Re-enable the button after the sign-in process
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to send Google Sign-In request to the backend
  Future<String> sendGoogleSignInRequest(String idToken) async {
    try {
      final apiEndpoint = '$apiUrl/google-login-by-id-token?id_token=$idToken';

      // Make HTTP request to backend with the request headers
      final response = await ApiHelper.httpRequestWithAuthorization(
        context,
        apiEndpoint,
        'GET',
        '',
      );

      if (response.statusCode == 200) {
        // Handle a successful response from the backend and return the backend token
        print('Backend response: ${response.body}');
        return response.body;
      } else {
        // Handle a unsuccessful response from the backend
        print('Backend response: ${response.statusCode}');
        throw Exception('Failed to get backend token');
      }
    } catch (e) {
      // Handle network or other errors
      print('Failed to send Google Sign-In request to the backend: $e');
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

  // Add a method to sign out
  Future<void> _signOut() async {
    await _googleSignIn.signOut();
    setState(() {
      _currentUser = null;
    });
  }
}
