import 'package:blocexample/model/file_models.dart';

abstract class DocumentState{}

class DocumentLoading extends DocumentState{}

class DocumentLoaded extends DocumentState{
  final List<Document> doc;
  final Map<String, DocumentInfo> downloads;
  DocumentLoaded(this.doc, {this.downloads = const{}});
}

class DocumentDownloading extends DocumentState{
  final String name;
  final int progresd;
  final bool ispaused;
  DocumentDownloading({required this.name,required this.progresd,this.ispaused = false});
}

class DocumentDownloaded extends DocumentState{
  final String name;
  DocumentDownloaded(this.name);
}

class DocumentError extends DocumentState{
  final String error;
  DocumentError(this.error);
}

class LoadingDocument extends DocumentState{}

class DocumentInfo extends DocumentState{
  final  int progress;
  final bool ispaused;
  final int downloadedbyte;
  final int totalbyte;
  DocumentInfo({required this.progress,this.ispaused = false, required this.downloadedbyte,required this.totalbyte});
   DocumentInfo copyWith({
    int? progress,
    bool? isPaused,
    int? downloadedByte,
    int? totalByte,
  }) {
    return DocumentInfo(
      progress: progress ?? this.progress,
      ispaused: isPaused ?? ispaused,
      downloadedbyte: downloadedByte ?? downloadedbyte,
      totalbyte: totalByte ?? totalbyte, 
    );
  }
}