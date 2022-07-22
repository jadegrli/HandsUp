import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hands_up/widgets/home_page.dart';

import 'bloc_measure/bloc_measure.dart';


void main() {
  runApp(const MyApp());
  /*runApp(BlocProvider(
    create: (context) => MeasureBloc(),
    child: const MyApp(),
  ),
  );*/
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HandsUp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}