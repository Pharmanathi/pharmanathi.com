// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Form1 extends StatefulWidget {
  final void Function(Map<String, String>) onFormChanged;
  final int currentIndex;

  const Form1({
    Key? key,
    required this.currentIndex,
    required this.onFormChanged,
  }) : super(key: key);

  @override
  State<Form1> createState() => Form1State();
}

class Form1State extends State<Form1> {
  TextEditingController titleController = TextEditingController();
  TextEditingController initialsController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  String selectedTitle = 'Mr.';
  bool isFormCompleted = false;

  @override
  void initState() {
    super.initState();
    titleController.text = selectedTitle;
  }

  @override
  void didUpdateWidget(Form1 oldWidget) {
    if (oldWidget.currentIndex != widget.currentIndex) {
       print('Updated CurrentIndex in form1: ${widget.currentIndex}'); 
      updateForm();
    }
    super.didUpdateWidget(oldWidget);
  }
  

  void updateForm() {
    if (!isFormCompleted) {
      widget.onFormChanged(getFormData());
      isFormCompleted = true;
    }
  }

  Map<String, String> getFormData() {
    return {
      'selectedTitle': selectedTitle,
      'initials': initialsController.text,
      'name': nameController.text,
      'surname': surnameController.text,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Logging currentIndex here
    print('CurrentIndex inside form1: ${widget.currentIndex}');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to Pharma Nathi',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6F7ED7),
          ),
        ),
        SizedBox(height: 20),
        Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedTitle,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTitle = newValue!;
                });
                updateForm();
              },
              decoration: InputDecoration(
                labelText: 'Select your title',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              items: ['Mr.', 'Mrs.', 'Miss', 'Dr.']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: initialsController,
              onEditingComplete: () => updateForm(),
              decoration: InputDecoration(
                labelText: 'Enter your initials',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              onEditingComplete: () => updateForm(),
              decoration: InputDecoration(
                labelText: 'Enter your name',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: surnameController,
              onEditingComplete: () => updateForm(),
              decoration: InputDecoration(
                labelText: 'Enter your surname',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ],
    );
  }
}
