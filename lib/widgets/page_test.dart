import 'dart:async';

import 'package:flutter/material.dart';

class PageTest extends StatefulWidget {
  const PageTest({Key? key}) : super(key: key);

  @override
  State<PageTest> createState() => _PageTest();
}

class _PageTest extends State<PageTest> {
  late Timer _timer;
  int _start = 10;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: move2(context, "Hand Up"),
        ),
      ),
    );
  }

  Widget move2(BuildContext context, String text) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.deepOrangeAccent,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.black54,
              blurRadius: 15.0,
              offset: Offset(0.0, 0.75))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(text,
                style: const TextStyle(
                    fontSize: 30.0, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                child: Image.asset(
                  'assets/images/rest.jpg',
                  height: MediaQuery.of(context).size.height / 1.5,
                  fit: BoxFit.fitHeight,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("$_start",
                    style: const TextStyle(
                        fontSize: 120.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.black)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  side: const BorderSide(
                      width: 3, color: Colors.red),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.all(20)
                  ),
              onPressed: () {},
              child: const Text("CANCEL")),
        ],
      ),
    );
  }
}
