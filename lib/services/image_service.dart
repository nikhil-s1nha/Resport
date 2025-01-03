import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker picker = ImagePicker();

  /// Picks an image from the gallery or camera based on the source
  Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }
}