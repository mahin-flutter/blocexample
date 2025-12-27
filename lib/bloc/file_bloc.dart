import 'dart:async';

import 'package:blocexample/bloc/file_event.dart';
import 'package:blocexample/bloc/file_state.dart';
import 'package:blocexample/model/file_models.dart';
import 'package:blocexample/repository/file_rep.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DocumentRepository repository;

  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, int> _downloadedBytes = {};
  final Map<String, int> _totalBytes = {};

  DocumentBloc(this.repository) : super(DocumentLoading()) {
    on<LoadDocument>(_onLoad);
    on<DownloadDocument>(_onDownload);
    on<PauseDownload>(_onPause);
    on<ResumeDownload>(_onResume);
    on<CancelDownload>(_onCancel);
    on<DownloadProgress>(_onProgress);
    on<DownloadFinished>(_onFinished);
    on<DownloadAll>(_onDownloadAll);
  }

  /* ---------------- LOAD DOCUMENTS ---------------- */

  Future<void> _onLoad(
      LoadDocument event, Emitter<DocumentState> emit) async {
    try {
      emit(LoadingDocument());
      final docs = await repository.fetchdocument();
      emit(DocumentLoaded(docs));
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  /* ---------------- START DOWNLOAD ---------------- */

  Future<void> _onDownload(
      DownloadDocument event, Emitter<DocumentState> emit) async {
    if (state is! DocumentLoaded) return;

    final current = state as DocumentLoaded;
    final downloads = Map<String, DocumentInfo>.from(current.downloads);

    final token = CancelToken();
    _cancelTokens[event.doc.name] = token;
    _downloadedBytes[event.doc.name] = 0;

    downloads[event.doc.name] = DocumentInfo(
      progress: 0,
      ispaused: false,
      downloadedbyte: 0,
      totalbyte: 0, 
    );

    emit(DocumentLoaded(current.doc, downloads: downloads));

    await _startOrResume(event.doc);
  }

  void _onPause(PauseDownload event, Emitter<DocumentState> emit) {
    if (state is! DocumentLoaded) return;

    _cancelTokens[event.doc.name]?.cancel();
    _cancelTokens.remove(event.doc.name);

    final current = state as DocumentLoaded;
    final downloads = Map<String, DocumentInfo>.from(current.downloads);

    downloads[event.doc.name] =
        downloads[event.doc.name]!.copyWith(isPaused: true);

    emit(DocumentLoaded(current.doc, downloads: downloads));
  }

  Future<void> _onResume(
      ResumeDownload event, Emitter<DocumentState> emit) async {
    if (state is! DocumentLoaded) return;

    final token = CancelToken();
    _cancelTokens[event.doc.name] = token;

    await _startOrResume(event.doc);
  }

  Future<void> _onCancel(
      CancelDownload event, Emitter<DocumentState> emit) async {
    if (state is! DocumentLoaded) return;

    _cancelTokens[event.doc.name]?.cancel();
    _cancelTokens.remove(event.doc.name);

    await repository.delettemp(event.doc.name);

    _downloadedBytes.remove(event.doc.name);
    _totalBytes.remove(event.doc.name);

    final current = state as DocumentLoaded;
    final downloads = Map<String, DocumentInfo>.from(current.downloads);
    downloads.remove(event.doc.name);

    emit(DocumentLoaded(current.doc, downloads: downloads));
  }

  Future<void> _onDownloadAll(
      DownloadAll event, Emitter<DocumentState> emit) async {
    if (state is! DocumentLoaded) return;

    final current = state as DocumentLoaded;

    for (final doc in current.doc) {
      if (!current.downloads.containsKey(doc.name)) {
        add(DownloadDocument(doc));
        await Future.delayed(const Duration(milliseconds: 600));
      }
    }
  }

  void _onProgress(
      DownloadProgress event, Emitter<DocumentState> emit) {
    if (state is! DocumentLoaded) return;

    final current = state as DocumentLoaded;
    final downloads = Map<String, DocumentInfo>.from(current.downloads);

    final progress =
        ((event.received / event.total) * 100).toInt();

    downloads[event.name] = downloads[event.name]!.copyWith(
      progress: progress,
      isPaused: false,
      downloadedByte: event.received,
      totalByte: event.total,
    );

    emit(DocumentLoaded(current.doc, downloads: downloads));
  }

  Future<void> _onFinished(
      DownloadFinished event, Emitter<DocumentState> emit) async {
    if (state is! DocumentLoaded) return;

    await repository.savedownload(event.name);

    final current = state as DocumentLoaded;
    final downloads = Map<String, DocumentInfo>.from(current.downloads);

    downloads.remove(event.name);
    _downloadedBytes.remove(event.name);
    _totalBytes.remove(event.name);
    _cancelTokens.remove(event.name);

    emit(DocumentLoaded(current.doc, downloads: downloads));
  }

  Future<void> _startOrResume(Document doc) async {
    final token = _cancelTokens[doc.name];
    if (token == null) return;

    final startByte = _downloadedBytes[doc.name] ?? 0;

    try {
      await repository.downloadwithresume(
        url: doc.url,
        fileName: doc.name,
        startByte: startByte,
        cancelToken: token,
        onProgress: (received, total) {
          if (token.isCancelled) return;

          _downloadedBytes[doc.name] = received;
          _totalBytes[doc.name] = total;
          add(DownloadProgress(doc.name, received, total));
        },
      );
      add(DownloadFinished(doc.name));
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) return;
      addError(e);
    }
  }
}
