// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:flutter/material.dart';

class Form4 extends StatefulWidget {
  final void Function(Map<String, String>) onFormChanged;
  const Form4({Key? key, required this.onFormChanged}) : super(key: key);
  @override
  State<Form4> createState() => Form4State();
}

class Form4State extends State<Form4> {
  // Controllers for input fields
  TextEditingController spcaController = TextEditingController();
  TextEditingController mpController = TextEditingController();
  TextEditingController inController = TextEditingController();
  bool isFormCompleted = false;

   Map<String, String> getFormData() {
    return {
      'spcaNumber': spcaController.text,
      'mpNumber': mpController.text,
      'inNummber': inController.text,

    };
  }

  void updateForm() {
    if (!isFormCompleted) {
      widget.onFormChanged(getFormData());
      isFormCompleted = true;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interact With Patients Personally or Virtually',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6F7ED7),
          ),
        ),
        SizedBox(height: 20),
        Column(
          children: [
            // Input field for SPCA number
            TextFormField(
              controller: spcaController,
               onChanged: (value) => updateForm(),
              decoration: InputDecoration(
                  labelText: 'SPCA Number',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  )),
            ),
            SizedBox(height: 20),
            // Input field for MP number
            TextFormField(
              controller: mpController,
               onChanged: (value) => updateForm(),
              decoration: InputDecoration(
                  labelText: 'MP Number',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  )),
            ),
            SizedBox(height: 20),
            // Input field for IN number
            TextFormField(
              controller: inController,
               onChanged: (value) => updateForm(),
              decoration: InputDecoration(
                  labelText: 'IN Number',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  )),
            ),
            SizedBox(height: 20),
          ],
        )
        // Add more form fields or any other content you want
      ],
    );
  }
}
