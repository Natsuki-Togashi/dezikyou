import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../utils/firebase_upload.dart';
import 'camera_screen.dart';
import 'upload_complete_screen.dart';

class ConfirmScreen extends StatefulWidget {
  final int userId;
  final XFile imageFile;
  const ConfirmScreen({
    super.key,
    required this.userId,
    required this.imageFile,
  });

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  String photoName = '';
  String message = '';
  String errorDetail = '';
  bool uploading = false;

  // 五十音リスト
  final List<String> gojuon = [
    'あ',
    'い',
    'う',
    'え',
    'お',
    'か',
    'き',
    'く',
    'け',
    'こ',
    'さ',
    'し',
    'す',
    'せ',
    'そ',
    'た',
    'ち',
    'つ',
    'て',
    'と',
    'な',
    'に',
    'ぬ',
    'ね',
    'の',
    'は',
    'ひ',
    'ふ',
    'へ',
    'ほ',
    'ま',
    'み',
    'む',
    'め',
    'も',
    'や',
    'ゆ',
    'よ',
    'ら',
    'り',
    'る',
    'れ',
    'ろ',
    'わ',
    'を',
    'ん',
  ];

  void _onRetake() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(userId: widget.userId),
      ),
    );
  }

  Future<void> _onUpload() async {
    setState(() {
      uploading = true;
      message = '';
      errorDetail = '';
    });
    try {
      final url = await uploadImageToFirebase(
        File(widget.imageFile.path),
        '${photoName}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        widget.userId.toString(),
      );
      setState(() {
        uploading = false;
      });
      if (url != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UploadCompleteScreen(userId: widget.userId),
          ),
        );
      } else {
        setState(() {
          message = 'アップロード失敗';
        });
      }
    } catch (e) {
      setState(() {
        uploading = false;
        message = 'アップロード失敗';
        errorDetail = e.toString();
      });
    }
  }

  void _addKana(String kana) {
    setState(() {
      photoName += kana;
    });
  }

  void _removeLastChar() {
    setState(() {
      if (photoName.isNotEmpty) {
        photoName = photoName.substring(0, photoName.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('写真確認')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.file(File(widget.imageFile.path), height: 120),
              ),
              const SizedBox(height: 8),
              Text('写真名: $photoName', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  ...gojuon.map(
                    (k) => ElevatedButton(
                      onPressed: uploading ? null : () => _addKana(k),
                      child: Text(k),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: uploading ? null : _removeLastChar,
                    child: const Text('消去'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(48, 36),
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (uploading) const Center(child: CircularProgressIndicator()),
              if (message.isNotEmpty)
                Center(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (errorDetail.isNotEmpty)
                Center(
                  child: Text(
                    errorDetail,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: uploading ? null : _onRetake,
                    child: const Text('撮り直し'),
                  ),
                  ElevatedButton(
                    onPressed: (uploading || photoName.isEmpty)
                        ? null
                        : _onUpload,
                    child: const Text('アップロード'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
