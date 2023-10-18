import 'dart:io';
import 'package:flutter/material.dart';
import 'package:how_are_you/util/UtilFunction.dart';
import 'package:share_extend/share_extend.dart';
import 'package:how_are_you/screen/HomePage.dart';
import 'package:how_are_you/util/Constants.dart';

class ShowResultPage extends StatefulWidget {
  // X <= ShowResultPage =>>> HomePage()
  String resultPhoto;

  ShowResultPage({
    Key? key,
    required this.resultPhoto,
  }) : super(key: key);
  final double iconSize = 20.0;
  final Color iconColor = Color(0xFF442B2D);

  _ShowResultPageState createState() => _ShowResultPageState();
}

class _ShowResultPageState extends State<ShowResultPage> {
  @override
  Widget build(BuildContext context) {
    final userArt = Container(
      child: Image.file(File(widget.resultPhoto)),
    );

    final userAction = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          // onPressed: () => ShareExtend.share((widget.resultPhoto).path, "image",),
          onPressed: () => ShareExtend.share(
            (widget.resultPhoto),
            "image",
          ),
          child: Icon(
            Icons.share,
            color: widget.iconColor,
            size: iconSize,
            semanticLabel: 'share',
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(),
            ),
            (Route router) => false,
          ),
          child: Icon(
            Icons.refresh,
            color: widget.iconColor,
            size: iconSize,
            semanticLabel: 'again',
          ),
        ),
      ],
    );

    return WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            builder: (context) {
              return ExitAppDialog();
            });
        return false;
      },
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            userArt,
            userAction,
          ],
        ),
      ),
    );
  }
}
