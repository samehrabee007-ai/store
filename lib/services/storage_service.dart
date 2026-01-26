import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:firebase_core/firebase_core.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image
  Future<String?> uploadImage(File file) async {
    String fileName = file.path.split(Platform.pathSeparator).last;
    String destination =
        'product_images/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    Reference ref = _storage.ref().child(destination);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
