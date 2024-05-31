import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class Form3 extends StatefulWidget {
  final void Function(Map<String, String>) onFormChanged;

  const Form3({Key? key, required this.onFormChanged}) : super(key: key);
  @override
  State<Form3> createState() => Form3State();
}

class Form3State extends State<Form3> {
  TextEditingController universityController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController passportController = TextEditingController();
  List<String> selectedUniversities = [];
  List<String> _universities = [
    'University of Cape Town',
    'University of the Witwatersrand',
    'Stellenbosch University',
    'Vaal University of Technology',
    'University of Pretoria',
    'University of Johannesburg',
    'University of KwaZulu-Natal',
    'North-West University',
    'Rhodes University',
    'University of the Free State',
    'University of South Africa',
    'University of Venda',
    'University of Zululand',
    'Cape Peninsula University of Technology',
    'Durban University of Technology',
    'Tshwane University of Technology',
    'Central University of Technology',
    'University of Mpumalanga',
    'University of Limpopo',
    'University of Fort Hare',
    'Nelson Mandela University',
    'Sefako Makgatho Health Sciences University',
    'Sol Plaatje University',
    'Walter Sisulu University',
  ];
  bool isFormCompleted = false;

  @override
  void initState() {
    super.initState();
    universityController.text = selectedUniversities.join(', ');
  }

  void updateForm() {
    if (!isFormCompleted) {
      widget.onFormChanged(getFormData());
      isFormCompleted = true;
    }
  }

  Map<String, String> getFormData() {
    return {
      'universities': selectedUniversities.join(', '),
      'id': idController.text,
      'passport': passportController.text,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keep Your Patient Records in One Place',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6F7ED7),
          ),
        ),
        SizedBox(height: 10),
        Column(
          children: [
            SizedBox(height: 10),
            // Multi-select checkbox for selecting universities
            MultiSelectDialogField(
              items: _universities
                  .map((university) =>
                      MultiSelectItem<String>(university, university))
                  .toList(),
              initialValue: selectedUniversities,
              title: Text('Select University'),
              selectedColor: Colors.blue,
              buttonText: Text('Select University'),
              onConfirm: (List<String> values) {
                setState(() {
                  selectedUniversities = values;
                  updateForm(); // Move updateForm inside setState
                });
              },
            ),
            SizedBox(height: 10),
            // Input field for ID
            TextFormField(
              controller: idController,
              onChanged: (value) => updateForm(), // Call updateForm here
              decoration: InputDecoration(
                  labelText: 'ID',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  )),
            ),
            SizedBox(height: 10),
            // Input field for passport
            TextFormField(
              controller: passportController,
              onChanged: (value) => updateForm(), // Call updateForm here
              decoration: InputDecoration(
                  labelText: 'Passport',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  )),
            ),
            SizedBox(height: 10),
          ],
        ),
      ],
    );
  }
}
