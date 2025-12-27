import 'package:blocexample/model/file_models.dart';

abstract class DocumentEvent{}

class LoadDocument extends DocumentEvent{}

class DownloadDocument extends DocumentEvent{
  final Document doc;
  DownloadDocument(this.doc);
}

class PauseDownload extends DocumentEvent{
  final Document doc;
  PauseDownload(this.doc);
}
class ResumeDownload extends DocumentEvent{
  final Document doc;
  ResumeDownload(this.doc);
}
class CancelDownload extends DocumentEvent{
  final Document doc;
  CancelDownload(this.doc);
}

class DownloadAll extends DocumentEvent{}