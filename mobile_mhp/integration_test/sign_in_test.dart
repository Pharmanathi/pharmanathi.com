import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:pharma_nathi/main.dart' as app;

void main() {
  patrolTest(
    'App should launch and show sign in screen with correct elements',
    (tester) async {
      await app.main();

      // Add longer initial wait for CI
      await Future.delayed(const Duration(seconds: 7));
      // Wait for the app to stabilize
      await tester.pumpAndSettle(duration: Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 1));

      // Verify the Pharma Nathi logo and text are present
      expect(
        find.image(
            const AssetImage('assets/images/pharmanathi-stack-logowhite.png')),
        findsOneWidget,
        reason: 'Pharma Nathi logo should be visible',
      );

      // Verify the Google Sign-In button is present
      final signInButton = find.byType(ElevatedButton);
      expect(
        signInButton,
        findsOneWidget,
        reason: 'Google Sign-In button should be visible',
      );

      // Verify Google icon and text in the button
      expect(
        find.image(const AssetImage('assets/images/google.png')),
        findsOneWidget,
        reason: 'Google icon should be visible in the button',
      );

      expect(
        find.text('Sign In with Google'),
        findsOneWidget,
        reason: 'Sign In with Google text should be visible',
      );

      // Verify loading indicator is not visible initially
      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
        reason: 'Loading indicator should not be visible initially',
      );
    },
  );
}
