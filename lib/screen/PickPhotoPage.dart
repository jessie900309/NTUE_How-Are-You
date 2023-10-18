import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:how_are_you/screen/EditPhotoPage.dart';
import 'package:how_are_you/util/Constants.dart';
import 'package:how_are_you/util/UtilFunction.dart';

class PickPhotoPage extends StatelessWidget {
  // route :
  // X <= PickPhotoPage => EditPhotoPage(pickedPhoto,)
  late List<String> imageList;
  String text;

  PickPhotoPage({
    Key? key,
    required this.imageList,
    required this.text,
  }) : super(key: key);

  var lastPopTime = DateTime.utc(1911, 10, 10, 0, 0, 0);
  int needTime = 3; //3s內快速點擊兩下

  @override
  Widget build(BuildContext context) {
    final List<Widget> imageSliders = (imageList.map((item) {
      return TextButton(
        onPressed: () {
          int pickedPhotoIndex = imageList.indexOf(item);
          if ((DateTime.now()).difference(lastPopTime) <
              Duration(seconds: needTime)) {
            //nextButton => EditPhotoPage(pickedPhoto,)
            String pickedPhotoUrl = this.imageList[pickedPhotoIndex];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditPhotoPage(
                  pickedPhoto: pickedPhotoUrl,
                  text: text,
                ),
              ),
            );
          } else {
            lastPopTime = DateTime.now();
          }
        },
        child: Container(
          margin: EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Stack(
              children: <Widget>[
                Image.network(
                  item,
                  fit: BoxFit.cover,
                  width: 1000.0,
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(200, 0, 0, 0),
                          Color.fromARGB(0, 0, 0, 0)
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    })).toList();

    final photoSlider = Container(
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: false,
          aspectRatio: 9 / 16,
          enlargeCenterPage: true,
          enlargeStrategy: CenterPageEnlargeStrategy.scale,
        ),
        items: imageSliders,
      ),
    );

    final pageDirections = Text(
      "Quickly click your favourite photo twice.",
      style: textButtonStyle,
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
          children: [
            photoSlider,
            Center(
              child: pageDirections,
            ),
          ],
        ),
      ),
    );
  }
}
