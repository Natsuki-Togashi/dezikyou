import 'dart:io';
import 'package:flutter/material.dart';

class ConfirmPhotoPage extends StatelessWidget {
  final File imageFile;
  final String photoName;
  final VoidCallback onRetake;
  final VoidCallback onUpload;
  final bool isUploading;
  final String? uploadResult;

  ConfirmPhotoPage({
    required this.imageFile,
    required this.photoName,
    required this.onRetake,
    required this.onUpload,
    this.isUploading = false,
    this.uploadResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('写真の確認')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(imageFile, height: 300),
            SizedBox(height: 20),
            Text('写真名: $photoName', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            if (uploadResult != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(uploadResult!, style: TextStyle(color: Colors.red)),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isUploading ? null : onRetake,
                  child: Text('取り直し'),
                ),
                SizedBox(width: 24),
                ElevatedButton(
                  onPressed: isUploading ? null : onUpload,
                  child: isUploading ? CircularProgressIndicator() : Text('アップロード'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
