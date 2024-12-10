// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pharma_nathi/blocs/sign_in_bloc.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/repositories/sign_in_repository.dart';
import 'package:pharma_nathi/repositories/user_repository.dart';
import 'package:pharma_nathi/routes/app_routes.dart';
import 'package:pharma_nathi/screens/components/UserProvider.dart';
import 'package:pharma_nathi/services/api_provider.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class GoogleSignInWidget extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'openid']);

  Future<void> _fetchUserData(
      BuildContext context, UserProvider userProvider) async {
    try {
      final userRepository = context.read<UserRepository>();
      final user = await userRepository.fetchUserData(context);
      if (user != null) {
        userProvider.setUserData(user);
      }
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final googleSignInBloc =
        GoogleSignInBloc(GoogleSignInRepository(ApiProvider()));

    return Scaffold(
      backgroundColor: Pallet.PRIMARY_COLOR,
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
                              'assets/images/pharmanathi-mhp-icon.png',
                              height: 100,
                            ),
                            Text(
                              'PHARMA',
                              style: GoogleFonts.openSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color.fromARGB(255, 253, 253, 253),
                              ),
                            ),
                             Text(
                              'NATHI',
                              style: GoogleFonts.openSans(
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                                color: Color.fromARGB(255, 253, 253, 253),
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
                                  googleSignInBloc.isLoading.value = true;
                                  try {
                                    final googleUser =
                                        await _googleSignIn.signIn();
                                    if (googleUser != null) {
                                      final googleAuth =
                                          await googleUser.authentication;
                                      await googleSignInBloc.signInWithGoogle(
                                        context,
                                        googleAuth.idToken ?? '',
                                      );

                                      if (googleSignInBloc.error.value ==
                                          null) {
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

                                        // Fetch user data after setting user information
                                        await _fetchUserData(
                                            context, userProvider);

                                        final isDrProfileIncompleteResult =
                                            await userProvider
                                                .hasIncompleteDoctorProfile();

                                        if (isDrProfileIncompleteResult) {
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
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Failed to sign in. Please try again.'),
                                      ),
                                    );
                                  } finally {
                                    googleSignInBloc.isLoading.value = false;
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
