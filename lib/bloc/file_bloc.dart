  import 'package:blocexample/bloc/file_event.dart';
  import 'package:blocexample/bloc/file_state.dart';
  import 'package:blocexample/model/file_models.dart';
  import 'package:blocexample/repository/file_rep.dart';
  import 'package:dio/dio.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';

  class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
    final DocumentRepository repository;
    final Map<String, CancelToken> _canceltoken = {};
    final Map<String, int> _downloadbytes = {};
    final Map<String, int> _totalbytes = {};

    DocumentBloc(this.repository) : super(DocumentLoading()) {
      on<LoadDocument>((event, emit) async {
        try {
          emit(LoadingDocument());
          final docs = await repository.fetchdocument();
          emit(DocumentLoaded(docs));
        } catch (e) {
          emit(DocumentError(e.toString()));
        }
      });

      on<DownloadDocument>((event, emit) async {
          if (state is DocumentLoaded) {
            final currentstate = state as DocumentLoaded;
            final updateddownload = Map<String, DocumentInfo>.from(
              currentstate.downloads,
            );
            final token = CancelToken();
            _canceltoken[event.doc.name] = token;
            _downloadbytes[event.doc.name] = 0;
            updateddownload[event.doc.name] = DocumentInfo(
              progress: 0,
              ispaused: false,
              downloadedbyte: 0,
              totalbyte: 0,
            );
            emit(DocumentLoaded(currentstate.doc, downloads: updateddownload));
            await startorResume(event.doc, emit);
          }
      });

      on<PauseDownload>((event, emit) {
        if (state is DocumentLoaded) {
          final currentstate = state as DocumentLoaded;
          _canceltoken[event.doc.name]?.cancel();
          _canceltoken.remove(event.doc.name);
          final updatedstate = Map<String, DocumentInfo>.from(
            currentstate.downloads,
          );
          updatedstate[event.doc.name] = updatedstate[event.doc.name]!.copyWith(isPaused: true);

          emit(DocumentLoaded(currentstate.doc, downloads: updatedstate));
        }
      });

      on<ResumeDownload>((event, emit) async {
        if (state is DocumentLoaded) {
          final token = CancelToken();
          _canceltoken[event.doc.name] = token;

        await startorResume(event.doc, emit);
        emit(DocumentLoaded((state as DocumentLoaded).doc));
        }
      });

      on<CancelDownload>((evet, emit)async {
        if (state is DocumentLoaded) {
          final currentstate = state as DocumentLoaded;
          _canceltoken[evet.doc.name]?.cancel();
          _canceltoken.remove(evet.doc.name);
          await repository.delettemp(evet.doc.name);

          _downloadbytes.remove(evet.doc.name);
          _totalbytes.remove(evet.doc.name);
          final updateddownload = Map<String, DocumentInfo>.from(
            currentstate.downloads,
          );
          updateddownload.remove(evet.doc.name);
          emit(DocumentLoaded(currentstate.doc, downloads: updateddownload));
        }
      });
      on<DownloadAll>((event, emit)async {
        if(state is DocumentLoaded){
          final currentstate = state as DocumentLoaded;
          for(final doc in currentstate.doc){
            if(!currentstate.downloads.containsKey(doc.name)){
              add(DownloadDocument(doc));
              await Future.delayed(const Duration(milliseconds: 800));
            }
          }
        }
      },);
    }
      Future<void> startorResume(Document doc, Emitter<DocumentState> emit)async{
        final currentstate = state as DocumentLoaded;
        final updateddownload = Map<String, DocumentInfo>.from(currentstate.downloads);
        final token = _canceltoken[doc.name];
        if(token == null) return;
        final startBytes = _downloadbytes[doc.name] ?? 0;
        try{
        await repository.downloadwithresume(
              url: doc.url,
              fileName:doc.name,
              startByte:startBytes,
              cancelToken: token,
              onProgress: (received, total) async {
                if(token.isCancelled) return;

                _downloadbytes[doc.name] = received;
                _totalbytes[doc.name] = total;

                if(state is! DocumentLoaded) return;
                final progress = ((received / total) * 100).toInt();
                updateddownload[doc.name] = updateddownload[doc.name]!.copyWith(
                  progress: progress,
                  isPaused: false,
                  downloadedByte: received,
                  totalByte: total,
                );
                emit(
                  DocumentLoaded(currentstate.doc, downloads: updateddownload),
                );
                if (received >= total) {
                  await repository.savedownload(doc.name);
                }
              },
            );
        }catch (e) {
          if (e is DioException && e.type == DioExceptionType.cancel) {
            return;
          }
          emit(DocumentError(e.toString()));
        }
      }
      
  }
