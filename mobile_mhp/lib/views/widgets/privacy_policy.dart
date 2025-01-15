import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_nathi/config/color_const.dart';


class PrivacyPolicyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextStyle headingStyle =
        Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18.0.sp,
              color: Pallet.PRIMARY_650,
            );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Pallet.PRIMARY_650),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                '1. Introduction',
                style: headingStyle,
              ),
              const SizedBox(height: 8.0),
              const Text(
                'We are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our app.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                '2. Data Collection',
                style: headingStyle,
              ),
              const SizedBox(height: 8.0),
              const Text(
                '- Personal Information: Name, email, phone number, and other details provided during registration or appointment booking.\n'
                '- Health Information: Details provided during consultations or shared via the app.\n'
                '- Usage Data: Information about how you use the app, including device information and IP address.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                '3. Data Usage',
                style: headingStyle,
              ),
              const SizedBox(height: 8.0),
              const Text(
                'We use your data to:\n'
                '- Provide and manage your appointments and consultations.\n'
                '- Improve app functionality and user experience.\n'
                '- Comply with legal obligations and ensure data security.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                '4. Data Sharing',
                style: headingStyle,
              ),
              const SizedBox(height: 8.0),
              const Text(
                'We do not sell or share your personal information with third parties, except:\n'
                '- With your consent.\n'
                '- To comply with legal requirements.\n'
                '- To trusted service providers who assist us in operating the app.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                '5. Data Security',
                style: headingStyle,
              ),
              const SizedBox(height: 8.0),
              const Text(
                'We implement appropriate technical and organizational measures to protect your data. However, no method of transmission over the internet is completely secure.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                '6. Your Rights',
                style: headingStyle,
              ),
              const SizedBox(height: 8.0),
              const Text(
                'You have the right to:\n'
                '- Access your data.\n'
                '- Request corrections or deletions.\n'
                '- Withdraw consent for data processing.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                '7. Changes to This Policy',
                style: headingStyle,
              ),
              const SizedBox(height: 8.0),
              const Text(
                'We may update this Privacy Policy from time to time. Please review it periodically for any changes.',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
