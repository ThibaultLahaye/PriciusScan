import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/app_state.dart';

class StartTab extends StatelessWidget {
  const StartTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, model, child) {
        return Scaffold(
            body: Column(
          children: [
            Align(
                alignment: Alignment.topCenter,
                child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.10),
                    child: Image.asset(
                        "assets/images/header-logo-blauw-web.png",
                        height: MediaQuery.of(context).size.width * 0.30))),
            Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.10),
                  child: Image.asset("assets/images/pixel-speech-bubble.png",
                      height: MediaQuery.of(context).size.width * 0.40),
                )),
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02),
                    child: Image.asset(
                      "assets/images/construction-worker.png",
                      height: MediaQuery.of(context).size.width * 0.55,
                    )))
          ],
        ));
      },
    );
  }
}
