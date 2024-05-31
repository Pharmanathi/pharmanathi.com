import 'dart:io';
import 'package:flutter/material.dart';

class ImageDataProvider with ChangeNotifier {
  File? _imageFile;

  File? get imageFile => _imageFile;

  // Method to update the image file
  void updateImageFile(File newImageFile) {
    _imageFile = newImageFile;
    notifyListeners();
  }
}

