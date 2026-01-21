import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image
  Future<String?> uploadImage(File file) async {
    try {
      String fileName = path.basename(file.path);
      String destination = 'product_images/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      Reference ref = _storage.ref().child(destination);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
