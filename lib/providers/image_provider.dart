import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndSaveImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Comprimi e ridimensiona l'immagine
      final File imageFile = File(image.path);
      final bytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(bytes);

      if (originalImage == null) return null;

      // Ridimensiona se necessario
      img.Image resized = originalImage;
      if (originalImage.width > 800 || originalImage.height > 800) {
        resized = img.copyResize(
          originalImage,
          width: originalImage.width > originalImage.height ? 800 : null,
          height: originalImage.height > originalImage.width ? 800 : null,
        );
      }

      // Salva l'immagine compressa
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String savedPath = path.join(appDir.path, 'images', fileName);
      
      // Crea la directory se non esiste
      final Directory imageDir = Directory(path.dirname(savedPath));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      final File savedFile = File(savedPath);
      await savedFile.writeAsBytes(img.encodeJpg(resized, quality: 85));

      return savedPath;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Gestione errori silenziosa
    }
  }
}