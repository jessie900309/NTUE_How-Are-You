import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({Key? key}) : super(key: key);

  @override
  _LoadingAnimationState createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation> {
  @override
  Widget build(BuildContext context) {
    return SpinKitSpinningLines(
      size: 200.0,
      color: Colors.black38,
    );
  }
}
