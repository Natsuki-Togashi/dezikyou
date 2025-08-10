import 'package:flutter/material.dart';
import '../camera/camera.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  // 有効なIDリスト（1〜1000）
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
          builder: (context) => CameraGpsPage(userId: int.parse(_controller.text)),
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
              Text(
                'フォトコンテスト',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Text(
                'ログインID',
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 8),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '入力してください',
                  border: OutlineInputBorder(),
                  errorText: _errorText,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _login,
                child: Text('ログイン'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[400],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
