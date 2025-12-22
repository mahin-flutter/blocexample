import 'package:equatable/equatable.dart';

abstract class FileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FileUpload extends FileEvent {}

class FileDownload extends FileEvent{
  final String url;

  FileDownload(this.url);

  @override
  List<Object?> get props => [url];
  }