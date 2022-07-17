
import 'package:flutter/material.dart';

import '../bloc_database/db_bloc_score.dart';
import '../models/score.dart';




class AllScoresPage extends StatefulWidget {
  const AllScoresPage({Key? key}) : super(key: key);

  @override
  State<AllScoresPage> createState() => _AllScoresPage();
}

class _AllScoresPage extends State<AllScoresPage> {

  final DataBaseBlocScore bloc = DataBaseBlocScore();

  @override
  void initState() {
    super.initState();
    bloc.getAllScore();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Score>>(
          stream: bloc.data,
          builder: (context, snapshot) {
            bloc.getAllScore();
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                //primary: false, //sinon ça scroll pas à cause du SingleChildScrollView
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index].id.toString()),
                    onTap: () {
                      bloc.deleteScoreById(snapshot.data![index].id!);
                    },
                  );
                },
              );
            } else {
              return const Align(
                  child: CircularProgressIndicator(),
                  alignment: FractionalOffset.center);
            }
          }),
    );
  }

}