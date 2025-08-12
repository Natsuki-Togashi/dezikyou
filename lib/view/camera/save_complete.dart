import 'package:flutter/material.dart';
//import 'save_util.dart';

class SaveCompletePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEE8),
      appBar: AppBar(title: Text('保存完了')),
      body: Center(
        child: Text(
          '保存が完了しました！',
          style: TextStyle(fontSize: 24, color: Colors.green),
        ),
      ),
    );
  }
}
