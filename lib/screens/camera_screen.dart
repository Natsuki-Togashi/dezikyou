import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'confirm_screen.dart';

class CameraScreen extends StatefulWidget {
  final int userId;
  const CameraScreen({super.key, required this.userId});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  void initState() {
    super.initState();
    _openNativeCamera();
  }

  Future<void> _openNativeCamera() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ConfirmScreen(userId: widget.userId, imageFile: image),
        ),
      );
    } else if (mounted) {
      // ユーザーが撮影をキャンセルした場合は前の画面に戻る
      Navigator.pop(context);
    }
  }

    @override
    Widget build(BuildContext context) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFFEE8),
        body: Center(child: CircularProgressIndicator()),
      );
    }
}
