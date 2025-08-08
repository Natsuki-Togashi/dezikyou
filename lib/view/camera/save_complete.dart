import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//アップロード完了画面表示の管理

class SaveCompletePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('保存完了')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'アップロード完了！',
              style: TextStyle(fontSize: 24, color: Colors.green),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // カメラ画面に戻る（画面スタックをクリアして最初の画面に戻る）
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text('別の写真を撮る'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // アプリを終了
                SystemNavigator.pop();
              },
              child: Text('アプリを終了する'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                textStyle: TextStyle(fontSize: 18),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
