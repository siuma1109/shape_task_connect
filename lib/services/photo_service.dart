import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class PhotoService {
  final _picker = ImagePicker();

  Future<String?> pickAndSavePhoto({required bool fromCamera}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80, // Compress image quality
      );

      if (image == null) return null;

      // Get app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final savedImage = File('${appDir.path}/photos/$fileName');

      // Create photos directory if it doesn't exist
      await savedImage.parent.create(recursive: true);

      // Copy picked image to app directory
      await File(image.path).copy(savedImage.path);

      return savedImage.path;
    } catch (e) {
      return null;
    }
  }
}
