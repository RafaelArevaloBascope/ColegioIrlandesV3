import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';

abstract class StorageRemoteDatasource{
  Future <String> uploadFile(Uint8List data, String fileName, String destinationPath);
}

class StorageRemoteDatasourceImpl extends StorageRemoteDatasource{
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<String> uploadFile(Uint8List data, String fileName, String destinationPath) async {
  final uniqueName = '${DateTime.now().millisecondsSinceEpoch}-$fileName';
  final ref = _storage.ref('$destinationPath/$uniqueName');
  
  final mimeType = lookupMimeType(fileName);
  await ref.putData(data, SettableMetadata(contentType: mimeType));

  final url = await ref.getDownloadURL();
  return url;
}
}