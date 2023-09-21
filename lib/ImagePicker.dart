import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

Future pickImageC() async {
  try {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final imageTemp = File(image.path);
    return imageTemp;
  } on PlatformException catch (e) {

    print('Failed to pick image: $e');
    
  }
}
