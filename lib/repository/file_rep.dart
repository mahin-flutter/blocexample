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

  Future<List<Document>> fetchdocument() async{
    final response = await http.get(Uri.parse('https://gutendex.com/books/'));

    if(response.statusCode == 200){
      final data = json.decode(response.body);
      final List<Document> docs = [];

      for(var book in data['results']){
        final url = book['formats']['text/plain; charset=us-ascii'];
        if(url != null){
          docs.add(Document(name: book['title'], url: url));
        }
      }
      return docs;
    }else{
      throw Exception('Failed to Fetch Document');
    }
  }

  Future<void> downloaddocument(Document doc, Function(int, int) onProgress) async{
    final dio = Dio(
      BaseOptions(followRedirects: true,receiveTimeout: Duration(minutes: 5))
    );


    final cacheDir = await getTemporaryDirectory();

    final safeName = sanitizeFileName(doc.name);
    final filePath = '${cacheDir.path}/$safeName.txt';
    final tempFile = File(filePath);

    await dio.download(
      doc.url,
      tempFile.path,
      onReceiveProgress: onProgress
    );
    final params = SaveFileDialogParams(
      sourceFilePath: tempFile.path,
      fileName: "${doc.name}.txt"
    );
    await FlutterFileDialog.saveFile(params: params);
  }
}
