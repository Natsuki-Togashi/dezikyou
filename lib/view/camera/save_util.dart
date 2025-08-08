import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

//文字入力を管理

class SaveUtil {
  static Future<void> saveImageFile(File imageFile, String photoName) async {
    final directory = await getApplicationDocumentsDirectory();
    final savePath = '${directory.path}/$photoName.png';
    await imageFile.copy(savePath);
  }

  static Future<void> saveImageAndLocation(
    String imagePath,
    double latitude,
    double longitude,
    String photoName,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/saved_data.json');
    Map<String, dynamic> data = {
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'photoName': photoName,
      'timestamp': DateTime.now().toIso8601String(),
    };

    List<dynamic> savedList = [];
    if (await file.exists()) {
      String content = await file.readAsString();
      if (content.isNotEmpty) {
        savedList = json.decode(content);
      }
    }
    savedList.add(data);

    await file.writeAsString(json.encode(savedList));
  }
}

class KatakanaInputPanel extends StatefulWidget {
  final Function(String) onChanged;
  final String initialText;

  KatakanaInputPanel({required this.onChanged, this.initialText = ''});

  @override
  _KatakanaInputPanelState createState() => _KatakanaInputPanelState();
}

class _KatakanaInputPanelState extends State<KatakanaInputPanel> {
  String inputText = '';

  final List<String> katakanaList = [
    'ア',
    'イ',
    'ウ',
    'エ',
    'オ',
    'カ',
    'キ',
    'ク',
    'ケ',
    'コ',
    'サ',
    'シ',
    'ス',
    'セ',
    'ソ',
    'タ',
    'チ',
    'ツ',
    'テ',
    'ト',
    'ナ',
    'ニ',
    'ヌ',
    'ネ',
    'ノ',
    'ハ',
    'ヒ',
    'フ',
    'ヘ',
    'ホ',
    'マ',
    'ミ',
    'ム',
    'メ',
    'モ',
    'ヤ',
    '゛',
    'ユ',
    '゜',
    'ヨ',
    'ラ',
    'リ',
    'ル',
    'レ',
    'ロ',
    'ワ',
    'ヲ',
    'ン',
    'ー',
    '削除',
  ];

  @override
  void initState() {
    super.initState();
    inputText = widget.initialText;
  }

  void _onKatakanaTap(String char) {
    setState(() {
      if (char == '削除') {
        if (inputText.isNotEmpty) {
          inputText = inputText.substring(0, inputText.length - 1);
        }
      } else {
        inputText += char;
      }
      widget.onChanged(inputText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('写真名: $inputText', style: TextStyle(fontSize: 20)),
        SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: katakanaList.map((char) {
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: ElevatedButton(
                onPressed: () => _onKatakanaTap(char),
                child: Text(char, style: TextStyle(fontSize: 18)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
