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
      backgroundColor: const Color(0xFFFFFEE8),
      appBar: AppBar(title: Text('写真の確認')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(imageFile, height: 300),
            SizedBox(height: 20),
            Text(
              '写真名: $photoName',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            if (uploadResult != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(uploadResult!, style: TextStyle(color: Colors.red)),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6E6D9),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.0),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: isUploading ? null : onRetake,
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      '取り直し',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 24),
                SizedBox(
                  width: 120,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6E6D9),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.0),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: isUploading ? null : onUpload,
                    icon: const Icon(Icons.cloud_upload),
                    label: isUploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'アップロード',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
