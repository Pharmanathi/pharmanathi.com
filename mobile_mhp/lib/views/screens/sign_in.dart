// ignore_for_file: use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pharma_nathi/blocs/sign_in_bloc.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/repositories/sign_in_repository.dart';
import 'package:pharma_nathi/repositories/user_repository.dart';
import 'package:pharma_nathi/routes/app_routes.dart';
import 'package:pharma_nathi/screens/components/UserProvider.dart';
import 'package:pharma_nathi/services/api_provider.dart';
import 'package:pharma_nathi/views/widgets/privacy_policy.dart';
import 'package:pharma_nathi/views/widgets/terms_of_service.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:pharma_nathi/views/widgets/shared/showErrorSnackBar.dart';

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
                      padding: const EdgeInsets.only(top: 200),
                      child: SizedBox(
                        // height: 200.h,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/pharmanathi-stack-logowhite.png',
                              height: 124.h,
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
                                        showErrorSnackBar(context,
                                        'Sign-in failed. Please try again.');
                                        Sentry.captureMessage(
                                          'Sign-in failed with error: ${googleSignInBloc.error.value}',
                                          level: SentryLevel.error,);
                                      }
                                    }
                                  } catch (e, stackTrace) {
                                    Sentry.captureException(e, stackTrace: stackTrace);
                                    showErrorSnackBar(context, "Failed to sign in. Please try again.");
                                  } finally {
                                    googleSignInBloc.isLoading.value = false;
                                  }
                                },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/google.png',
                                height: 24.h,
                              ),
                              SizedBox(width: 8.w),
                              const Text('Sign In with Google'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 54.0),
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text:
                                  'By continuing you agree to Pharmanathi\'s ',
                              style: GoogleFonts.openSans(
                                color: Pallet.SECONDARY_100,
                                fontSize: 14.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: GoogleFonts.openSans(
                                    color: Pallet.NEUTRAL_200,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16.0),
                                          ),
                                        ),
                                        builder: (context) =>
                                            FractionallySizedBox(
                                          heightFactor: 0.7,
                                          child: TermsOfServiceWidget(),
                                        ),
                                      );
                                    },
                                ),
                                const TextSpan(
                                  text: ' and ',
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: GoogleFonts.openSans(
                                    color: Pallet.NEUTRAL_200,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(26.0)),
                                        ),
                                        builder: (context) =>
                                            FractionallySizedBox(
                                                heightFactor: 0.7,
                                                child: PrivacyPolicyWidget()),
                                      );
                                    },
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ))),
                  ],
                ),
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 36.0),
                      child:
                          CircularProgressIndicator(color: Pallet.PRIMARY_300),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
