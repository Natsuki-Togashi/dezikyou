import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'save_util.dart';
import 'save_complete.dart';
import 'confirm_photo.dart';

class CameraGpsPage extends StatefulWidget {
  final int userId;
  CameraGpsPage({required this.userId});
  @override
  _CameraGpsPageState createState() => _CameraGpsPageState();
}

class _CameraGpsPageState extends State<CameraGpsPage> {
  File? _imageFile; // 画像ファイル
  Position? _position; // GPS位置情報
  String _photoName = ''; // 写真名
  bool _isNameConfirmed = false; // 写真名が確定したかどうか
  String? _address; // 住所用の変数
  bool _isUploading = false; // アップロード中フラグ
  String? _uploadResult; // アップロード結果

  @override
  void initState() {
    super.initState();
    // 画面表示時に自動でカメラを起動
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_imageFile == null) {
        _pickImageAndLocation();
      }
    });
  }

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

  void _goToConfirmPhoto() {
    if (_imageFile != null && _photoName.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmPhotoPage(
            imageFile: _imageFile!,
            photoName: _photoName,
            isUploading: _isUploading,
            uploadResult: _uploadResult,
            onRetake: () {
              Navigator.pop(context);
              setState(() {
                _imageFile = null;
                _photoName = '';
                _isNameConfirmed = false;
              });
            },
            onUpload: _saveData,
          ),
        ),
      );
    }
  }

  Future<void> _saveData() async {
    if (_imageFile != null && _position != null && _photoName.isNotEmpty) {
      setState(() {
        _isUploading = true;
        _uploadResult = null;
      });
      try {
        await _uploadToGoogleDrive(_imageFile!);
        setState(() {
          _uploadResult = 'Googleドライブにアップロード成功';
        });
      } catch (e) {
        setState(() {
          _uploadResult = 'アップロード失敗: $e';
        });
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SaveCompletePage()),
      );
    }
  }

  Future<void> _uploadToGoogleDrive(File file) async {
    // Googleサインイン
    final googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]);
    final account = await googleSignIn.signIn();
    if (account == null) throw 'Googleサインインに失敗しました';
    final authHeaders = await account.authHeaders;
    final authenticateClient = _GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    // IDごとにフォルダ名を分けてアップロード
    final folderName = 'PhotoContest_ID_${widget.userId}';
    String? folderId;
    // 既存フォルダ検索
    final folderList = await driveApi.files.list(
      q: "mimeType='application/vnd.google-apps.folder' and name='$folderName' and trashed=false",
      spaces: 'drive',
    );
    if (folderList.files != null && folderList.files!.isNotEmpty) {
      folderId = folderList.files!.first.id;
    } else {
      // フォルダがなければ作成
      final folder = drive.File();
      folder.name = folderName;
      folder.mimeType = 'application/vnd.google-apps.folder';
      final created = await driveApi.files.create(folder);
      folderId = created.id;
    }

    // ファイルアップロード
    final driveFile = drive.File();
    driveFile.name = _photoName + '.jpg';
    driveFile.parents = [folderId!];
    await driveApi.files.create(
      driveFile,
      uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEE8),
      appBar: AppBar(title: Text('写真＋GPS取得')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_imageFile != null && !_isNameConfirmed) ...[
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
                KatakanaInputPanel(
                  onChanged: (text) {
                    setState(() {
                      _photoName = text;
                    });
                  },
                  initialText: _photoName,
                ),
                ElevatedButton(
                  onPressed: _photoName.isNotEmpty
                      ? () {
                          setState(() {
                            _isNameConfirmed = true;
                          });
                          _goToConfirmPhoto();
                        }
                      : null,
                  child: Text('確定'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Google API用の認証クライアント
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  _GoogleAuthClient(this._headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
