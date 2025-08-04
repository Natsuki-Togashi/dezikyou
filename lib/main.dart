import 'package:flutter/material.dart';
import 'view/camera/camera.dart'; // 遷移用にcamera.dartをインポート
import 'view/camera/saved_list.dart'; // 遷移用にsaved_list.dartをインポート

void main() {
  runApp(MaterialApp(title: 'カメラ＋GPSデモ', home: TopPage()));
}

class TopPage extends StatelessWidget {
  // トップページのウィジェット
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('topページ')),
      body: Center(
        child: Column(
          //画面の中央に配置
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //ボタンを縦に並べる
            ElevatedButton(
              child: Text('写真を撮る'),
              onPressed: () {
                //ボタンを押すと
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraGpsPage(),
                  ), // camera.dartに遷移
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              //ボタン
              child: Text('保存された写真を見る'),
              onPressed: () {
                //ボタンを押すと
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // saved_list.dartに遷移
                    builder: (context) => SavedListPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
