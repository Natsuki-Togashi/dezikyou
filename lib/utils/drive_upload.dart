import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

Future<bool> uploadToDrive({
  required File file,
  required int userId,
  required String photoName,
}) async {
  try {
    // サービスアカウント認証情報の読み込み
    final jsonString = await rootBundle.loadString('assets/credentials.json');
    final credentials = ServiceAccountCredentials.fromJson(
      json.decode(jsonString),
    );
    final scopes = [drive.DriveApi.driveFileScope, drive.DriveApi.driveScope];
    final client = await clientViaServiceAccount(credentials, scopes);

    final driveApi = drive.DriveApi(client);

    // フォルダIDを指定（"フォトコンテスト"フォルダのIDをここに設定）
    const folderId = '15lZMdelmtl6aho_oawb5Vm-wJ9gFAKhx';

    final media = drive.Media(file.openRead(), file.lengthSync());
    final driveFile = drive.File();
    driveFile.name = photoName.isNotEmpty ? photoName : p.basename(file.path);
    driveFile.parents = [folderId];

    await driveApi.files.create(driveFile, uploadMedia: media);
    client.close();
    return true;
  } catch (e, st) {
    print('Drive upload error: $e\n$st');
    throw Exception('Drive upload error: $e');
  }
}
