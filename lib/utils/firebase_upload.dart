import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

Future<String?> uploadImageToFirebase(File file, String fileName, String userId) async {
  try {
    print('アップロードファイル: ${file.path}');
    print('ファイル存在: ${file.existsSync()}');
    print('ファイルサイズ: ${file.existsSync() ? file.lengthSync() : 'N/A'}');
    final storageRef = FirebaseStorage.instance.ref().child(
      'uploads/$userId/$fileName',
    );
    final uploadTask = storageRef.putFile(file);
    await uploadTask;
    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  } catch (e, st) {
    print('Firebase upload error: $e\n$st');
    throw Exception('Firebase upload error: $e');
  }
}
