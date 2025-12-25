import 'package:blocexample/bloc/file_bloc.dart';
import 'package:blocexample/bloc/file_event.dart';
import 'package:blocexample/homepage.dart';
import 'package:blocexample/repository/file_rep.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main()  {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  BlocProvider(
      create: (_) => DocumentBloc(DocumentRepository())..add(LoadDocument()),
        child: Homepage(),
      ),
    );
  }
}
