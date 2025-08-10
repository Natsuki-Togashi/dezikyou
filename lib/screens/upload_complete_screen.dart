import 'package:flutter/material.dart';
import 'camera_screen.dart';

class UploadCompleteScreen extends StatelessWidget {
  final int userId;
  const UploadCompleteScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('アップロード完了')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text('アップロードが完了しました！', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(userId: userId),
                  ),
                  (route) => false,
                );
              },
              child: const Text('写真を撮る'),
            ),
          ],
        ),
      ),
    );
  }
}
