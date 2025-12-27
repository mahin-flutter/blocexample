import 'package:blocexample/bloc/file_bloc.dart';
import 'package:blocexample/bloc/file_event.dart';
import 'package:blocexample/bloc/file_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Books'),
        backgroundColor: Colors.blueAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                context.read<DocumentBloc>().add(DownloadAll());
              }, 
            style: TextButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(),
              foregroundColor: Colors.black
            ),
            child: Text('Download All')),
          )
        ],
      ),
      body: BlocConsumer<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentDownloaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${state.name} saved to Downloads')),
            );
            context.read<DocumentBloc>().add(LoadDocument());
          }
          if (state is DocumentError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
            context.read<DocumentBloc>().add(LoadDocument());
          }
        },

        builder: (context, state) {
          if (state is LoadingDocument) {
            return Center(
              child: SpinKitFadingCircle(color: Colors.black, size: 50.0),
            );
          }

          // if (state is DocumentLoading) {
          //   return const Center(
          //     child: CircularProgressIndicator(),
          //   );
          // }
          if (state is DocumentLoaded) {
            return ListView.builder(
              itemCount: state.doc.length,
              itemBuilder: (context, index) {
                final doc = state.doc[index];
                final download = state.downloads[doc.name];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 5.0,
                  ),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(),
                    child: ListTile(
                      title: Text(doc.name),
                      subtitle: download != null
                          ? Column(
                              children: [
                                LinearProgressIndicator(
                                  value: download.progress / 100,
                                  color: Colors.blueAccent,
                                  minHeight: 6,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '${download.progress}% - ${download.ispaused ? 'Paused' : 'Downloaded'}',
                                ),
                              ],
                            )
                          : null,
                      trailing: download == null
                          ? IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () {
                                context.read<DocumentBloc>().add(
                                  DownloadDocument(doc),
                                );
                              },
                            )
                          : Row(
                              mainAxisSize: .min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (download.ispaused) {
                                      context.read<DocumentBloc>().add(
                                        ResumeDownload(doc),
                                      );
                                    } else {
                                      context.read<DocumentBloc>().add(
                                        PauseDownload(doc),
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    download.ispaused
                                        ? Icons.play_arrow
                                        : Icons.pause,
                                  ),
                                ),
                                SizedBox(width: 10),
                                IconButton(
                                  onPressed: () {
                                    context.read<DocumentBloc>().add(PauseDownload(doc));
                                    final bloc = context.read<DocumentBloc>();
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Cancel Download'),
                                          content: Text(
                                            'Are you Sure want to cancel this Download?',
                                          ),
                                          actions: [
                                            Divider(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextButton(
                                                    onPressed: () {
                                                      bloc.add(ResumeDownload(doc));
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                    child: Text('No'),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: TextButton(
                                                    onPressed: () {
                                                     bloc.add(CancelDownload(doc));
                                                          Navigator.of(context).pop();
                                                    },
                                                    style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.blueAccent,
                                                          shape: RoundedRectangleBorder(),
                                                    ),
                                                    child: Text('Yes,Cancel'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.close),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            );
          }
          if (state is DocumentDownloading) {
            return Center(
              child: Text('Downloading ${state.name} ${state.progresd}%'),
            );
          }
          return SizedBox();
        },
      ),
    );
  }
}
