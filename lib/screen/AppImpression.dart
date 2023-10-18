import 'dart:math';
import 'package:flutter/material.dart';

class AppImpression extends StatelessWidget {
  final List<String> splashBackgroundPath = [
    "assets/images/bg1.gif",
    "assets/images/bg2.gif",
    "assets/images/bg3.gif",
  ];

  @override
  Widget build(BuildContext context) {
    Random rand = new Random();
    String imagePath = splashBackgroundPath[rand.nextInt(2)];

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Image.asset(imagePath),
    );
  }
}
