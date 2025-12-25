import 'package:blocexample/bloc/file_event.dart';
import 'package:blocexample/bloc/file_state.dart';
import 'package:blocexample/repository/file_rep.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentBloc extends Bloc< DocumentEvent,DocumentState>{
  final DocumentRepository repository;

  DocumentBloc(this.repository): super(DocumentLoading()){
    on<LoadDocument>((event, emit) async{
      try{
        final docs = await repository.fetchdocument();
        emit(DocumentLoaded(docs));
      }catch(e){
        emit(DocumentError(e.toString()));
      }
    });

    on<DownloadDocument>((event, emit) async{
      try{
        await repository.downloaddocument(event.doc, (received, total){
          final progress = ((received/total) * 100).toInt();
          emit(DocumentDownloading(event.doc.name, progress));
        });
        emit(DocumentDownloaded(event.doc.name));
      }catch(e){
        emit(DocumentError(e.toString()));
      }
    });
  }
}