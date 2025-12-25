import 'package:blocexample/model/file_models.dart';

abstract class DocumentEvent{}

class LoadDocument extends DocumentEvent{}

class DownloadDocument extends DocumentEvent{
  final Document doc;
  DownloadDocument(this.doc);
}