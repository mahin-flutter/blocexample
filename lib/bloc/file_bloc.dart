import 'dart:io';

import 'package:blocexample/bloc/file_event.dart';
import 'package:blocexample/bloc/file_state.dart';
import 'package:blocexample/repository/file_rep.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FileBloc extends Bloc<FileEvent ,FileState>{
  final FileRepository repository;

  FileBloc(this.repository): super(FileInit()){
    on<FileUpload>(_onupload);
    on<FileDownload>(_ondowmload);
  }

  Future<void> _onupload(FileUpload event,Emitter<FileState> emit) async{
      try{
        emit(FileLoading());

        FilePickerResult? result =await FilePicker.platform.pickFiles();

        if(result == null) return;

        File file = File(result.files.single.path!);
        await repository.uploadFile(file);

        emit(FileSucess('File Uploaded Successfully'));
      }catch (e){
        emit(FileError(e.toString()));
      }
  }

  Future<void> _ondowmload(FileDownload event,Emitter<FileState> emit) async{
    try{
      emit(FileLoading());

        final path = await repository.dowmloadFile(event.url);
        emit(FileSucess('File Downloaded at $path'));
    }catch (e){
      emit(FileError(e.toString()));
    }
  }
}