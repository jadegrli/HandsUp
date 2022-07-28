import 'package:flutter/material.dart';

import '../models/repetition.dart';

class RepetitionPage extends StatefulWidget {
  final Repetition repetition;
  const RepetitionPage({Key? key, required this.repetition}) : super(key: key);

  @override
  State<RepetitionPage> createState() => _RepetitionPage();
}

class _RepetitionPage extends State<RepetitionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Repetition profile"),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("ID : ${widget.repetition.id}"),
            Text("isHealthy : ${widget.repetition.isHealthy}"),
            Text("scoreId : ${widget.repetition.scoreId}"),
            Text("rangeAngularUp : ${widget.repetition.rangeAngularUp}"),
            Text(
                "rangeAccBackCoordX : ${widget.repetition.rangeAccBackCoordX}"),
            Text(
                "rangeAccBackCoordY : ${widget.repetition.rangeAccBackCoordY}"),
            Text(
                "rangeAccBackCoordZ : ${widget.repetition.rangeAccBackCoordZ}"),
            Text(
                "rangeGyroBackCoordX : ${widget.repetition.rangeGyroBackCoordX}"),
            Text(
                "rangeGyroBackCoordY : ${widget.repetition.rangeGyroBackCoordY}"),
            Text(
                "rangeGyroBackCoordZ : ${widget.repetition.rangeGyroBackCoordZ}"),
            Text("rangeAccUpCoordX : ${widget.repetition.rangeAccUpCoordX}"),
            Text("rangeAccUpCoordY : ${widget.repetition.rangeAccUpCoordY}"),
            Text("rangeAccUpCoordZ : ${widget.repetition.rangeAccUpCoordZ}"),
            Text("rangeGyroUpCoordX : ${widget.repetition.rangeGyroUpCoordX}"),
            Text("rangeGyroUpCoordY : ${widget.repetition.rangeGyroUpCoordY}"),
            Text("rangeGyroUpCoordZ : ${widget.repetition.rangeGyroUpCoordZ}"),
          ],
        ),
      ),
    );
  }
}
