import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SavedListPage extends StatefulWidget {
  @override
  _SavedListPageState createState() => _SavedListPageState();
}

class _SavedListPageState extends State<SavedListPage> {
  List<dynamic> savedList = [];

  @override
  void initState() {
    //保存データを読み込む
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    //読み込み処理
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/saved_data.json');
    if (await file.exists()) {
      //ファイルが存在する場合、内容を読み込む
      String content = await file.readAsString();
      setState(() {
        savedList = content.isNotEmpty ? json.decode(content) : [];
      });
    }
  }

  Future<void> _deleteItem(int index) async {
    //削除に関する処理
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/saved_data.json');
    final imageFileName =
        savedList[index]['imagePath'] ?? savedList[index]['imageFileName'];
    final imageFile = File('${directory.path}/$imageFileName');
    if (await imageFile.exists()) {
      await imageFile.delete();
    }
    savedList.removeAt(index);
    await file.writeAsString(json.encode(savedList));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('保存された写真一覧')),
      body: ListView.builder(
        itemCount: savedList.length,
        itemBuilder: (context, index) {
          final item = savedList[index];
          return Card(
            child: ListTile(
              contentPadding: EdgeInsets.all(8),
              leading: FutureBuilder<Directory>(
                future: getApplicationDocumentsDirectory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      item['imagePath'] != null) {
                    final imageFile = File(
                      '${snapshot.data!.path}/${item['imagePath'] ?? item['imageFileName']}',
                    );
                    if (imageFile.existsSync()) {
                      return Image.file(
                        imageFile,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      );
                    }
                  }
                  return Container(width: 64, height: 64, color: Colors.grey);
                },
              ),
              title: Text(item['photoName'] ?? ''),
              subtitle: Text(
                '緯度: ${item['latitude']}, 経度: ${item['longitude']}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item['timestamp'] ?? ''),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('削除確認'),
                          content: Text('この写真を削除しますか？'),
                          actions: [
                            TextButton(
                              child: Text('キャンセル'),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            TextButton(
                              child: Text('削除'),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        ),
                      );
                      if (result == true) {
                        await _deleteItem(index); //削除処理を実行
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
