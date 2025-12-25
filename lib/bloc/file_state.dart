import 'package:blocexample/model/file_models.dart';

abstract class DocumentState{}

class DocumentLoading extends DocumentState{}

class DocumentLoaded extends DocumentState{
  final List<Document> doc;
  DocumentLoaded(this.doc);
}

class DocumentDownloading extends DocumentState{
  final String name;
  final int progresd;
  DocumentDownloading( this.name, this.progresd);
}

class DocumentDownloaded extends DocumentState{
  final String name;
  DocumentDownloaded(this.name);
}

class DocumentError extends DocumentState{
  final String error;
  DocumentError(this.error);
}