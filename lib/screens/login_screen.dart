import 'package:flutter/material.dart';
import 'camera_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  bool _isValidId(String input) {
    final id = int.tryParse(input);
    return id != null && id >= 1 && id <= 1000;
  }

  void _login() {
    if (_isValidId(_controller.text)) {
      setState(() => _errorText = null);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CameraScreen(userId: int.parse(_controller.text)),
        ),
      );
    } else {
      setState(() => _errorText = '1〜1000のIDを入力してください');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'フォトコンテスト',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text(
                'ログインID',
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '入力してください',
                  border: const OutlineInputBorder(),
                  errorText: _errorText,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _login,
                child: const Text('ログイン'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
