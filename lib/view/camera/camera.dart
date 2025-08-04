import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'save_util.dart';
import 'save_complete.dart';

class CameraGpsPage extends StatefulWidget {
  @override
  _CameraGpsPageState createState() => _CameraGpsPageState();
}

class _CameraGpsPageState extends State<CameraGpsPage> {
  File? _imageFile; // 画像ファイル
  Position? _position; // GPS位置情報
  String _photoName = ''; // 写真名
  bool _isNameConfirmed = false; // 写真名が確定したかどうか
  String? _address; // 住所用の変数

  Future<void> _pickImageAndLocation() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 住所取得
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      String addressText = '';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        addressText =
            '${place.locality ?? ''}${place.subLocality ?? ''}${place.thoroughfare ?? ''}${place.name ?? ''}';
      }

      setState(() {
        _imageFile = File(pickedFile.path);
        _position = position;
        _address = addressText;
        _photoName = '';
        _isNameConfirmed = false;
      });
    }
  }

  Future<void> _saveData() async {
    if (_imageFile != null && _position != null && _photoName.isNotEmpty) {
      await SaveUtil.saveImageFile(_imageFile!, _photoName);
      await SaveUtil.saveImageAndLocation(
        '', // imagePathは不要
        _position!.latitude,
        _position!.longitude,
        _photoName,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SaveCompletePage()),
      );
    }
  }

  void _confirmName() {
    setState(() {
      _isNameConfirmed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('写真＋GPS取得')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_imageFile == null)
                ElevatedButton(
                  onPressed: _pickImageAndLocation,
                  child: Text('写真を撮る'),
                ),
              if (_imageFile != null) ...[
                Image.file(_imageFile!, height: 300),
                SizedBox(height: 20),
                if (_address != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '住所: $_address',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                SizedBox(height: 20),
                if (_isNameConfirmed)
                  Text(
                    '写真名: $_photoName',
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 20),
                if (!_isNameConfirmed)
                  KatakanaInputPanel(
                    onChanged: (text) {
                      setState(() {
                        _photoName = text;
                      });
                    },
                    initialText: _photoName,
                  ),
                if (!_isNameConfirmed)
                  ElevatedButton(
                    onPressed: _photoName.isNotEmpty ? _confirmName : null,
                    child: Text('確定'),
                  ),
                if (_isNameConfirmed)
                  ElevatedButton(onPressed: _saveData, child: Text('情報を保存')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
