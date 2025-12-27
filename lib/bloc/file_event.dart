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

class DownloadProgress extends DocumentEvent {
  final String name;
  final int received;
  final int total;

  DownloadProgress(this.name, this.received, this.total);
}

class DownloadFinished extends DocumentEvent {
  final String name;
  DownloadFinished(this.name);
}
