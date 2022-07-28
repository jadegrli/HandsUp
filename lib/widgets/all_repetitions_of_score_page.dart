import 'package:flutter/material.dart';
import 'package:hands_up/widgets/repetition_page.dart';

import '../bloc_database/db_bloc_repetition.dart';

//TODO remove
class AllRepetitionsOfScorePage extends StatefulWidget {
  const AllRepetitionsOfScorePage({Key? key, required this.scoreId}) : super(key: key);

  final int scoreId;

  @override
  State<AllRepetitionsOfScorePage> createState() => _AllRepetitionsOfScorePage();
}

class _AllRepetitionsOfScorePage extends State<AllRepetitionsOfScorePage> {

  final DataBaseBlocRepetition bloc = DataBaseBlocRepetition();

  @override
  void initState() {
    super.initState();
    bloc.getRepetitionsByScoreId(widget.scoreId);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<dynamic>>(
          stream: bloc.data,
          builder: (context, snapshot) {
            bloc.getRepetitionsByScoreId(widget.scoreId);
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                primary: false, //if true doesn't scroll because of SingleChildScrollView
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index].id.toString()),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            RepetitionPage(repetition: snapshot.data![index])),
                      );
                    },
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

}