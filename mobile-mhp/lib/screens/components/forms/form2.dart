// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pharma_nathi/screens/components/UserProvider.dart';
import 'package:provider/provider.dart';

class Form2 extends StatefulWidget {
  final void Function(Map<String, String>) onFormChanged;
  const Form2({Key? key, required this.onFormChanged  }) : super(key: key);

  @override
  State<Form2> createState() => Form2State();
}

class Form2State extends State<Form2> {
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController comfirmPasswordController = TextEditingController();
  bool isFormCompleted = false;

  Map<String, String> getFormData() {
    return {
      'emmail': emailController.text,
      'contact': phoneController.text,
      'password': passwordController.text,
      'comfirmPassword': comfirmPasswordController.text,
    };
  }

  //* Function to update the form data and trigger the callback
  void updateForm() {
    if (!isFormCompleted) {
      widget.onFormChanged(getFormData());
      isFormCompleted = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Help Patients Online',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6F7ED7),
          ),
        ),
        SizedBox(height: 20),
        Column(
          children: [
            //* Email input field
            TextFormField(
              readOnly: true, //* Make it read-only
              decoration: InputDecoration(
                labelText: userProvider.email, //* Display email from provider
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            SizedBox(height: 20),
            //* Phone input field
            TextFormField(
              controller: phoneController,
               onChanged: (value) => updateForm(),
              decoration: InputDecoration(
                  labelText: 'Phone',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  )),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            //* Password input field
            TextFormField(
              controller: passwordController,
               onChanged: (value) => updateForm(),
              decoration: InputDecoration(
                  labelText: 'Password',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  )),
              obscureText: true,
            ),
            SizedBox(height: 20),
            // Confirm password input field
            TextFormField(
              controller: comfirmPasswordController,
               onChanged: (value) => updateForm(),
              decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  )),
              obscureText: true,
            ),
            SizedBox(height: 20),
          ],
        ),

        // Add more form fields or any other content you want
      ],
    );
  }
}
