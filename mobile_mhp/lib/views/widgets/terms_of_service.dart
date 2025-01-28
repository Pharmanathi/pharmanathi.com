import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/views/widgets/privacy_policy.dart';

class TermsOfServiceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text('Terms of Service',
                  style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Pallet.PRIMARY_650)),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: RichText(
                text: TextSpan(
                  style:
                      GoogleFonts.openSans(fontSize: 16.0, color: Colors.black),
                  children: [
                    const TextSpan(
                      text:
                          'Welcome to Pharmanathi! These Terms of Service govern your use of our platform, including our website, mobile application, and related services (collectively, the "Services"). By accessing or using our Services, you agree to be bound by these Terms. If you do not agree, please do not use our Services.\n\n',
                    ),
                    TextSpan(
                      text: '1. Acceptance of Terms\n',
                      style: GoogleFonts.openSans(
                        fontSize: 18.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Pallet.PRIMARY_500,
                      ),
                    ),
                    const TextSpan(
                      text: 'By using the Services, you represent that:\n'
                          '- You are at least 18 years of age or the legal age of majority in your jurisdiction.\n'
                          '- You have read, understood, and agree to be bound by these Terms.\n\n',
                    ),
                    TextSpan(
                      text: '2. Services Provided\n',
                      style: GoogleFonts.openSans(
                        fontSize: 18.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Pallet.PRIMARY_500,
                      ),
                      children: [
                        TextSpan(
                          text: 'Our platform facilitates:\n'
                              '- Online consultations with licensed healthcare professionals.\n'
                              '- Appointment booking with clinics or healthcare providers.\n'
                              '- Access to health-related information and resources.\n\n',
                          style: GoogleFonts.openSans(
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Disclaimer: ',
                          style: GoogleFonts.openSans(
                            fontSize: 17.0.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text:
                              'We do not provide medical advice, diagnosis, or treatment. All consultations and advice provided by healthcare professionals are their sole responsibility.\n\n',
                          style: GoogleFonts.openSans(
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    TextSpan(
                      text: '3. User Responsibilities\n',
                      style: GoogleFonts.openSans(
                        fontSize: 18.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Pallet.PRIMARY_500,
                      ),
                    ),
                    const TextSpan(
                      text: 'You agree to:\n'
                          '- Provide accurate, complete, and updated information when creating an account or booking appointments.\n'
                          '- Use the Services for lawful purposes only.\n'
                          '- Not impersonate another person or provide false information.\n\n',
                    ),
                    TextSpan(
                      text: '4. Healthcare Provider Responsibility\n',
                      style: GoogleFonts.openSans(
                        fontSize: 18.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Pallet.PRIMARY_500,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Healthcare providers listed on our platform are independent professionals. We do not employ or control them. The quality and accuracy of consultations or treatments are the sole responsibility of the healthcare provider.\n\n',
                    ),
                    TextSpan(
                      text: '5. Payments and Refunds\n',
                      style: GoogleFonts.openSans(
                        fontSize: 18.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Pallet.PRIMARY_500,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '- Payments for consultations or appointments must be made through the platform.\n'
                          '- Refunds are subject to the cancellation policy of the specific healthcare provider.\n'
                          '- We are not responsible for disputes regarding payments made outside the platform.\n\n',
                    ),
                    TextSpan(
                      text: '6. Privacy and Data Security\n',
                      style: GoogleFonts.openSans(
                        fontSize: 18.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Pallet.PRIMARY_500,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Your privacy is important to us. Please refer to our ',
                      style: GoogleFonts.openSans(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: GoogleFonts.openSans(
                        fontSize: 18.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Pallet.PRIMARY_500,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigate to the Privacy Policy page or show a modal
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16.0)),
                            ),
                            builder: (context) => FractionallySizedBox(
                                heightFactor: 0.7,
                                child: PrivacyPolicyWidget()),
                          );
                        },
                    ),
                    TextSpan(
                      text:
                          ' for details on how we collect, use, and protect your personal information.\n\n',
                      style: GoogleFonts.openSans(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: '7. Prohibited Activities\n',
                      style: GoogleFonts.openSans(
                        fontSize: 18.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Pallet.PRIMARY_500,
                      ),
                    ),
                    const TextSpan(
                      text: 'You agree not to:\n'
                          '- Use the Services for any unauthorized or illegal purposes.\n'
                          '- Attempt to gain unauthorized access to our systems or other users\' accounts.\n'
                          '- Share any medical advice or prescriptions received through the platform with others.\n\n',
                    ),
                    TextSpan(
                      text: '8. Limitation of Liability\n',
                      style: GoogleFonts.openSans(
                        fontSize: 18.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Pallet.PRIMARY_500,
                      ),
                    ),
                    const TextSpan(
                      text: 'To the fullest extent permitted by law:\n'
                          '- Pharmanathi is not responsible for any injury, loss, or damages resulting from the use of our Services.\n'
                          '- We do not guarantee the availability or accuracy of the information provided by healthcare providers.\n\n',
                    ),
                    TextSpan(
                      text: '9. Termination of Use\n',
                      style: GoogleFonts.openSans(
                        fontSize: 18.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Pallet.PRIMARY_500,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'We reserve the right to suspend or terminate your access to the Services at our discretion, including for violations of these Terms.\n\n',
                    ),
                    TextSpan(
                      text: '10. Changes to the Terms\n',
                      style: GoogleFonts.openSans(
                        fontSize: 18.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Pallet.PRIMARY_500,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'We may update these Terms from time to time. Any changes will be effective upon posting. Continued use of the Services constitutes your acceptance of the revised Terms.\n\n',
                    ),
                    TextSpan(
                      text: '11. Governing Law\n',
                      style: GoogleFonts.openSans(
                        fontSize: 18.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Pallet.PRIMARY_500,
                      ),
                    ),
                    const TextSpan(
                      text:
                          //TODO: [Thabang] find the right law that govern this
                          'These Terms are governed by the laws of [we need to find the law and act], without regard to conflict of law principles.\n\n',
                    ),
                    TextSpan(
                      text: '12. Contact Information\n',
                      style: GoogleFonts.openSans(
                        fontSize: 18.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Pallet.PRIMARY_500,
                      ),
                      children: [
                        TextSpan(
                          text:
                              'If you have any questions about these Terms, please contact us at:\n',
                          style: GoogleFonts.openSans(
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Email: ',
                          style: GoogleFonts.openSans(
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: '[Insert Email Address]\n',
                          style: GoogleFonts.openSans(
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Phone: ',
                          style: GoogleFonts.openSans(
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: '[Insert Phone Number]\n',
                          style: GoogleFonts.openSans(
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Address: ',
                          style: GoogleFonts.openSans(
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: '[Insert Physical Address]\n\n',
                          style: GoogleFonts.openSans(
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Emergency Disclaimer: ',
                          style: GoogleFonts.openSans(
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text:
                              '"Our Services are not intended for emergency situations. If you are experiencing a medical emergency, please call your local emergency number immediately."',
                          style: GoogleFonts.openSans(
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
