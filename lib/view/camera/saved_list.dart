import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geocoding/geocoding.dart';

//一覧表示ページの実装

class SavedListPage extends StatefulWidget {
  const SavedListPage({super.key});

  @override
  State<SavedListPage> createState() => _SavedListPageState();
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

  Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        List<String> addressParts = [];

        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          addressParts.add(place.thoroughfare!);
        }
        if (place.subThoroughfare != null &&
            place.subThoroughfare!.isNotEmpty) {
          addressParts.add(place.subThoroughfare!);
        }
        if (place.name != null && place.name!.isNotEmpty) {
          addressParts.add(place.name!);
        }

        String addressText = addressParts.join(' ');
        
        // もし住所が取得できない場合は緯度経度を表示
        if (addressText.isEmpty) {
          addressText = '緯度: ${latitude.toStringAsFixed(6)}, 経度: ${longitude.toStringAsFixed(6)}';
        }
        
        return addressText;
      } else {
        // 住所が取得できない場合は緯度経度を表示
        return '緯度: ${latitude.toStringAsFixed(6)}, 経度: ${longitude.toStringAsFixed(6)}';
      }
    } catch (e) {
      // エラーが発生した場合は緯度経度を表示
      return '緯度: ${latitude.toStringAsFixed(6)}, 経度: ${longitude.toStringAsFixed(6)}';
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

  void _showDeleteDialog(int index) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('この写真を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      await _deleteItem(index); //削除処理を実行
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('保存された写真一覧')),
      body: ListView.builder(
        itemCount: savedList.length,
        itemBuilder: (context, index) {
          final item = savedList[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
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
              subtitle: FutureBuilder<String>(
                future: _getAddressFromCoordinates(
                  double.tryParse(item['latitude'].toString()) ?? 0.0,
                  double.tryParse(item['longitude'].toString()) ?? 0.0,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('住所を取得中...');
                  } else if (snapshot.hasData) {
                    return Text(snapshot.data!);
                  } else {
                    return Text('緯度: ${item['latitude']}, 経度: ${item['longitude']}');
                  }
                },
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item['timestamp'] ?? ''),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(index),
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
