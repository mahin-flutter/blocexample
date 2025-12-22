import 'package:equatable/equatable.dart';

abstract class FileState extends Equatable{
  @override
  List<Object?> get props => [];
}

class FileInit extends FileState{}

class FileLoading extends FileState{}

class FileSucess extends FileState{
  final String message;
  FileSucess(this.message);

  @override
  List<Object?> get props => [message];
}

class FileError extends FileState{
  final String error;
  FileError(this.error);

  @override
  List<Object?> get props => [error];
}