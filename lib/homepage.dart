import 'package:blocexample/bloc/file_bloc.dart';
import 'package:blocexample/bloc/file_event.dart';
import 'package:blocexample/bloc/file_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
      ),
      body: BlocConsumer<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentDownloaded) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${state.name} saved to Downloads')));
            context.read<DocumentBloc>().add(LoadDocument());
          }
          if (state is DocumentError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
            context.read<DocumentBloc>().add(LoadDocument());
          }
        },
        
        builder: (context, state) {

          if (state is DocumentLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is DocumentLoaded) {
            return ListView.builder(
              itemCount: state.doc.length,
              itemBuilder: (context, index) {
                final doc = state.doc[index];
                return ListTile(
                  title: Text(doc.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      context
                          .read<DocumentBloc>()
                          .add(DownloadDocument(doc));
                    },
                  ),
                );
              },
            );
          }
          if (state is DocumentDownloading) {
            return Center(
              child: Text(
                'Downloading ${state.name} ${state.progresd}%',
              ),
            );
          }
          return SizedBox();
        },
      ),
    );
  }
}
