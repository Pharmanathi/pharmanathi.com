// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_super_parameters, use_build_context_synchronously, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:pharma_nathi/screens/components/UserProvider.dart';
import 'package:provider/provider.dart';

class EditAccount extends StatefulWidget {
  final File? imageFile;
  final void Function(File?) onImageChanged; // Define the named parameter

  const EditAccount({
    Key? key,
    required this.imageFile,
    required this.onImageChanged, // Add this line
  }) : super(key: key);

  @override
  State<EditAccount> createState() => _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {
  File? imageFile;

  // Callback function to notify the parent widget about the picked image
  void _updateImage(File? newImage) {
    setState(() {
      imageFile = newImage;
    });
  }

  // Request permission before accessing the image gallery
  Future<void> requestGalleryPermission() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      // Permission granted, handle accordingly
    } else {
      // Permission denied, handle accordingly
    }
  }

  // changeImage method
  Future<void> changeImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        _updateImage(File(pickedFile.path));
        // Add user feedback here if needed
      }
    } catch (e) {
      // Handle exceptions, e.g., if the user cancels the image selection
      print('Error picking image: $e');
      // Add user feedback here if needed
    }
  }

  Future<File?> saveImage() async {
    try {
      // Check if the imageFile is not null
      if (imageFile != null) {
        // Get the directory where the app can store files.
        final directory = await getApplicationDocumentsDirectory();

        // Create a new file in the specified directory
        final File newImageFile = File('${directory.path}/saved_image.png');

        // Copy the selected image to the new file
        await imageFile!.copy(newImageFile.path);

        // Return the updated file
        return newImageFile;
      } else {
        // Handle the case where there's no image to save
        return null;
      }
    } catch (e) {
      // Handle exceptions, e.g., if the image couldn't be saved
      print('Error saving image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
     String fullName = '${userProvider.name}';


    List<String> nameParts = fullName.split(' ');
     String firstName = nameParts[0];
    String lastName = nameParts.sublist(1).join(' ');

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 110.h,
            color: Color(0xFF6F7ED7),
            child: Padding(
              padding: const EdgeInsets.only(top: 35, right: 30, left: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      // Save the image and get the updated image file
                      File? savedImage = await saveImage();

                      // Check if the image was saved successfully
                      if (savedImage != null) {
                        // Update the imageFile in the state
                        setState(() {
                          imageFile = savedImage;
                        });

                        Navigator.pop(context, savedImage);
                      } else {
                        // Handle the case where the image couldn't be saved
                        print('Error saving image');

                        // Close the screen and pass the updated imageFile
                        Navigator.pop(context, savedImage);
                      }
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 100, bottom: 2),
                    child: Text(
                      'Edit Account',
                      style: GoogleFonts.openSans(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    //profile picture and the button.................
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 270.h,
                          child: imageFile != null
                              ? Image.file(
                                  imageFile!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Placeholder(), //i thought maybe we might need something when theres no picture
                        ),
                        Positioned(
                          top: 200.sp,
                          left: 110.sp,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                            ),
                            onPressed: changeImage,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_a_photo),
                                SizedBox(width: 8.sp),
                                Text('Change Picture'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //heading ,personal info....................
                  Padding(
                    padding: const EdgeInsets.all(35),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Personal info',
                          style: GoogleFonts.openSans(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            //handle
                            print(
                                'am working fine, no need to check 🙄🙄🙄🙄');
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                size: 10.sp,
                                color: Color(0xFF6F7ED7),
                              ),
                              SizedBox(
                                width: 10.sp,
                              ),
                              Text(
                                'Edit',
                                style: GoogleFonts.openSans(
                                  fontSize: 12.sp,
                                  color: Color(0xFF6F7ED7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //first name............................
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 1, right: 25, left: 25, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                           'First Name',
                          style: GoogleFonts.openSans(
                            fontSize: 15.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 102.sp,//TODO:[Thabang] this is weird, need to find out why
                        ),
                        Text(
                          firstName,
                          style: GoogleFonts.openSans(
                            fontSize: 15.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 500.w,//TODO:[Thabang] this is weird, need to find out why
                    child: Divider(
                      color: Colors.grey,
                      thickness: 0.5.sp,
                    ),
                  ),
                  //surname.......................
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, right: 25, left: 25, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          'Surname',
                          style: GoogleFonts.openSans(
                            fontSize: 15.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 117.sp, //TODO:[Thabang] this is weird, need to find out why
                        ),
                        Text(
                         lastName,
                          style: GoogleFonts.openSans(
                            fontSize: 15.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 500.w, //TODO:[Thabang] this is weird, need to find out why
                    child: Divider(
                      color: Colors.grey,
                      thickness: 0.5.sp,
                    ),
                  ),
                  //username name............................
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, right: 25, left: 25, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          'Username',
                          style: GoogleFonts.openSans(
                            fontSize: 15.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 110.sp, //TODO:[Thabang] this is weird, need to find out why
                        ),
                        Text(
                          'Flaviyo',
                          style: GoogleFonts.openSans(
                            fontSize: 15.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 500.w,//TODO:[Thabang] this is weird, need to find out why
                    child: Divider(
                      color: Colors.grey,
                      thickness: 0.5.sp,
                    ),
                  ),
                  //contact details..............................
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, right: 25, left: 25, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          'Phone Number',
                          style: GoogleFonts.openSans(
                            fontSize: 15.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 75.sp,//TODO:[Thabang] this is weird, need to find out why
                        ),
                        Text(
                          '069 321 3995',
                          style: GoogleFonts.openSans(
                            fontSize: 15.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 500.w,//TODO:[Thabang] this is weird, need to find out why
                    child: Divider(
                      color: Colors.grey,
                      thickness: 0.5.sp,
                    ),
                  ),
                  //location..........................
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, right: 25, left: 25, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          'Location',
                          style: GoogleFonts.openSans(
                            fontSize: 15.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 115.w, //TODO:[Thabang] this is weird, need to find out why
                        ),
                        Text(
                          ' Johannesburg',
                          style: GoogleFonts.openSans(
                            fontSize: 15.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 500.w,//TODO:[Thabang] this is weird, need to find out why
                    child: Divider(
                      color: Colors.grey,
                      thickness: 0.5.sp,
                    ),
                  ),
                  //Address.............................
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, right: 25, left: 25, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          'Address',
                          style: GoogleFonts.openSans(
                            fontSize: 15.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 120.w,//TODO:[Thabang] this is weird, need to find out why
                        ),
                        Container(
                          width: 150.w, 
                          child: Text(
                            '26 Maven , Alberton',
                            style: GoogleFonts.openSans(
                              fontSize: 15.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 500.w, //TODO:[Thabang] this is weird, need to find out why
                    child: Divider(
                      color: Colors.grey,
                      thickness: 0.5.sp,
                    ),
                  ),
                  //persona info .........................
                  Padding(
                    padding: const EdgeInsets.all(35),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Personal info',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            //handle
                            print(
                                'am working fine, no need to check 🙄🙄🙄🙄');
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                size: 10,
                                color: Color(0xFF6F7ED7),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6F7ED7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //email Address.............................
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, right: 25, left: 25, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 120,
                        ),
                        Container(
                          width: 170,
                          child: Text(
                             '${userProvider.email}',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 500,
                    child: Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                    ),
                  ),
                  //Address.............................
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, right: 25, left: 25, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 100,
                        ),
                        Text(
                          '..............',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 500,
                    child: Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        //handle
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_rounded),
                          SizedBox(width: 8),
                          Text('Delecte Account'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
