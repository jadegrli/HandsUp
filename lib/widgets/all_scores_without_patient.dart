
import 'package:flutter/material.dart';
import 'package:hands_up/widgets/score_page.dart';

import '../bloc_database/db_bloc_score.dart';



class AllScoresWithoutPatientPage extends StatefulWidget {
  const AllScoresWithoutPatientPage({Key? key}) : super(key: key);

  @override
  State<AllScoresWithoutPatientPage> createState() => _AllScoresWithoutPatientPage();
}

class _AllScoresWithoutPatientPage extends State<AllScoresWithoutPatientPage> {

  final DataBaseBlocScore bloc = DataBaseBlocScore();

  @override
  void initState() {
    super.initState();
    bloc.getScoreWithNoPatient();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center (
          child : Column(
          children: <Widget>[
            StreamBuilder<List<dynamic>>(
                stream: bloc.data,
                builder: (context, snapshot) {
                  bloc.getScoreWithNoPatient();
                  if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      primary: false, //sinon ça scroll pas à cause du SingleChildScrollView
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
                                  builder: (context) => ScorePage(score: snapshot.data![index])),
                            );
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
          ],
        ),
      ),
      ),
    );
  }

}