import 'dart:convert';
import 'dart:io';

import 'package:blocexample/model/file_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DocumentRepository {
  String sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  Future<File> _getTempFile(String name) async {
    final cacheDir = await getTemporaryDirectory();

    final safeName = sanitizeFileName(name);
    final filePath = '${cacheDir.path}/$safeName.txt';
    return File(filePath);
  }

  Future<List<Document>> fetchdocument() async {
    final response = await http.get(Uri.parse('https://gutendex.com/books/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Document> docs = [];

      for (var book in data['results']) {
        final url = book['formats']['text/plain; charset=us-ascii'];
        if (url != null) {
          docs.add(Document(name: book['title'], url: url));
        }
      }
      return docs;
    } else {
      throw Exception('Failed to Fetch Document');
    }
  }

  Future<void> downloadwithresume({
    required String url,
    required String fileName,
    required int startByte,
    required CancelToken cancelToken,
    required Function(int received, int total) onProgress,
  }) async {
    final dio = Dio(
      BaseOptions(followRedirects: true, receiveTimeout: Duration(minutes: 5)),
    );

    final file = await _getTempFile(fileName);
    final raf = file.openSync(mode: FileMode.append);
    try {
      await dio.download(
        url,
        file.path,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          final curent = startByte + received;
          final totalsize = startByte + total;
          onProgress(curent, totalsize);
        },
        options: Options(
          headers: startByte > 0 ? {'Range': 'bytes = $startByte-'} : null,
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 408 || e.response?.statusCode == 416) {
        await file.writeAsBytes([], flush: true);

        await dio.download(
          url,
          file.path,
          cancelToken: cancelToken,
          onReceiveProgress: onProgress,
        );
      } else {
        rethrow;
      }
    }
    raf.closeSync();
  }

  Future<void> savedownload(String fileName) async {
    final tempFile = await _getTempFile(fileName);

    final params = SaveFileDialogParams(
      sourceFilePath: tempFile.path,
      fileName: "$fileName.txt",
    );
    await FlutterFileDialog.saveFile(params: params);
    if (tempFile.existsSync()) {
      tempFile.deleteSync();
    }
  }

  Future<void> delettemp(String fileName) async {
    final tempFile = await _getTempFile(fileName);
    if (tempFile.existsSync()) {
      tempFile.deleteSync();
    }
  }
}
