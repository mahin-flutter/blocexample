import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class FileRepository{
  final Dio dio = Dio();

  Future<void> uploadFile(File file) async{
    FormData formData = FormData.fromMap({
      'file' : await MultipartFile.fromFile(file.path)
    });

    await dio.post(
      'https://api.myapp.com/upload',
      data: formData
    );
  }

  Future<String> dowmloadFile(String url) async{
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/downloaded_file';

    await dio.download(url, savePath);
    return savePath;
  }
}