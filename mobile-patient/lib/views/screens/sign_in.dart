// ignore_for_file: use_build_context_synchronously

import 'package:client_pharmanathi/Repository/sign_in_repository.dart';
import 'package:client_pharmanathi/blocs/sign_in_bloc.dart';
import 'package:client_pharmanathi/routes/app_routes.dart';
import 'package:client_pharmanathi/screens/components/UserProvider.dart';
import 'package:client_pharmanathi/services/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class GoogleSignInWidget extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'openid']);

  @override
  Widget build(BuildContext context) {
    final googleSignInBloc =
        GoogleSignInBloc(GoogleSignInRepository(ApiProvider()));


    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: googleSignInBloc.isLoading,
          builder: (context, isLoading, _) {
            return Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: SizedBox(
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/pharmanathi-patient-icon.png',
                              height: 100,
                            ),
                            const Text(
                              'PHARMA',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color.fromARGB(255, 101, 115, 207),
                              ),
                            ),
                            const Text(
                              'NATHI',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                                color: Color.fromARGB(255, 101, 115, 207),
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
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final googleUser =
                                      await _googleSignIn.signIn();
                                  if (googleUser != null) {
                                    final googleAuth =
                                        await googleUser.authentication;
                                    await googleSignInBloc.signInWithGoogle(
                                      context,
                                      googleAuth.idToken ?? '',
                                    );

                                    if (googleSignInBloc.error.value == null) {
                                      final userProvider =
                                          Provider.of<UserProvider>(context,
                                              listen: false);
                                      await userProvider.setUserInformation(
                                        googleUser.email,
                                        googleUser.displayName ?? '',
                                        googleUser.photoUrl ?? '',
                                        googleSignInBloc.backendToken.value ??
                                            '',
                                      );

                                      final isFirstTimeSignInResult =
                                          await userProvider
                                              .isFirstTimeSignIn();

                                      if (isFirstTimeSignInResult) {
                                        Navigator.pushNamed(
                                            context, AppRoutes.onboarding,
                                            arguments: {
                                              'email': googleUser.email,
                                            });
                                      } else {
                                        Navigator.pushNamed(
                                            context, AppRoutes.homePage,
                                            arguments: {
                                              'email': googleUser.email,
                                            });
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Sign-in failed. Please try again.'),
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/google.png',
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text('Sign In with Google'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
