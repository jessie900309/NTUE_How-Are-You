import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:how_are_you/screen/ShowResultPage.dart';
import 'package:how_are_you/util/Constants.dart';
import 'package:how_are_you/util/CustomSliderDialog.dart';
import 'package:how_are_you/util/LoadingAnimation.dart';
import 'package:how_are_you/util/UtilFunction.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class EditPhotoPage extends StatefulWidget {
  // route :
  // PickPhotoPage() <= EditPhotoPage =>>> ShowResultPage(resultPhoto)
  String pickedPhoto;
  String text;

  EditPhotoPage({
    Key? key,
    required this.pickedPhoto,
    required this.text,
  });

  late Color initPickerColor;
  late ValueChanged<Color> initOnColorChanged;
  late double initSliderValue;

  @override
  _EditPhotoPageState createState() => _EditPhotoPageState();
}

class _EditPhotoPageState extends State<EditPhotoPage> {
  Offset positionLT = Offset(0.0, 0.0);
  double ofX = 0.0;
  double ofY = 0.0;
  bool canMove = true;
  final GlobalKey _widgetKey = GlobalKey();

  void getWidgetPosition() {
    final RenderBox renderBox =
        _widgetKey.currentContext?.findRenderObject() as RenderBox;
    Offset widgetOffset = renderBox.localToGlobal(Offset.zero);
    ofX = widgetOffset.dx;
    ofY = widgetOffset.dy;
  }

  Color _pickerColor = Colors.amber;
  Color currentColor = Colors.amber;

  void changeColor(Color color) {
    setState(() => _pickerColor = color);
  }

  double _sliderValue = 24;
  double currentSize = 24;

  String currentStyle = '';
  Color showTextStyleColor = Colors.black;
  double showTextStyleSize = 24;

  TextAlign currentAlign = TextAlign.start;
  List alignList = <TextAlign>[
    TextAlign.start,
    TextAlign.center,
    TextAlign.end,
  ];

  Color userDrawIconColor = Colors.black38;

  bool exporting = false;
  String errtx = '';

  @override
  void initState() {
    super.initState();
    widget.initPickerColor = _pickerColor;
    widget.initOnColorChanged = changeColor;
    widget.initSliderValue = _sliderValue;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      this.getWidgetPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userArtText = Text(
      widget.text,
      textAlign: currentAlign,
      style: TextStyle(
          color: currentColor,
          fontSize: currentSize,
          fontFamily: currentStyle,
          decoration: TextDecoration.none),
    );

    final userArtTextDraggable = Draggable(
      child: userArtText,
      feedback: userArtText,
      onDraggableCanceled: (Velocity velocity, Offset offset) {
        setState(
            () => positionLT = Offset((offset.dx - ofX), (offset.dy - ofY)));
      },
    );

    final userPhoto = RepaintBoundary(
      key: _widgetKey,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          //底圖
          Image.network(widget.pickedPhoto),
          //文字(可在userDraw控制顏色、大小、字型、位置)
          Positioned(
            left: positionLT.dx,
            top: positionLT.dy,
            child: canMove ? userArtTextDraggable : userArtText,
          ),
        ],
      ),
    );

    void _showEditColorDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: const EdgeInsets.all(0),
            contentPadding: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: MediaQuery.of(context).orientation ==
                      Orientation.portrait
                  ? const BorderRadius.vertical(
                      top: Radius.circular(500),
                      bottom: Radius.circular(100),
                    )
                  : const BorderRadius.horizontal(right: Radius.circular(500)),
            ),
            content: SingleChildScrollView(
              child: HueRingPicker(
                pickerColor: currentColor,
                onColorChanged: widget.initOnColorChanged,
                enableAlpha: true,
                displayThumbColor: true,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  "pick color!",
                  style: TextStyle(
                    color: appDialogActionColor,
                  ),
                ),
                onPressed: () {
                  setState(() => currentColor = _pickerColor);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void _showEditSizeDialog() async {
      final selectedFontSize = await showDialog<double>(
        context: context,
        builder: (context) => CustomSliderDialog(initValue: currentSize),
      );
      if (selectedFontSize != null) {
        setState(() => currentSize = selectedFontSize);
      }
    }

    final userDraw = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // text reset
        TextButton(
          onPressed: () {
            setState(() {
              canMove = true;
              positionLT = Offset(0.0, 0.0);
              ofX = 0.0;
              ofY = 0.0;
              getWidgetPosition();
            });
          },
          child: Icon(
            Icons.refresh,
            color: userDrawIconColor,
          ),
        ),
        // text color
        TextButton(
          onPressed: () {
            setState(() => _showEditColorDialog());
          },
          child: Icon(
            Icons.color_lens,
            color: userDrawIconColor,
          ),
        ),
        // text size
        TextButton(
          onPressed: () {
            setState(() => _showEditSizeDialog());
          },
          child: Icon(
            Icons.text_format,
            color: userDrawIconColor,
          ),
        ),
        // text align
        TextButton(
          onPressed: () {
            setState(() {
              var index = alignList.indexOf(currentAlign);
              currentAlign = alignList[(index + 1) % 3];
            });
          },
          child: Icon(
            Icons.wrap_text,
            color: userDrawIconColor,
          ),
        ),
        // text style
        PopupMenuButton(
          icon: Icon(
            Icons.text_fields,
            color: userDrawIconColor,
          ),
          onSelected: (value) {
            setState(() {
              currentStyle = value.toString();
            });
          },
          offset: Offset(0.0, 50.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            PopupMenuItem<String>(
              value: "Running",
              child: Text(
                "行書",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "Running",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "TWSung",
              child: Text(
                "宋體",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "TWSung",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "TWKai",
              child: Text(
                "楷書",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "TWKai",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "Retro",
              child: Text(
                "復古",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "Retro",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "Terror",
              child: Text(
                "恐怖",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "Terror",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "art",
              child: Text(
                "藝術",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "art",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "Chalk",
              child: Text(
                "粉筆",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "Chalk",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "Chinese_characters",
              child: Text(
                "隸書",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "Chinese_characters",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "POP",
              child: Text(
                "POP",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "POP",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "Hand_painted",
              child: Text(
                "手繪",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "Hand_painted",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "pen",
              child: Text(
                "鋼筆",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "pen",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "Literature",
              child: Text(
                "文青",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "Literature",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "Annotated",
              child: Text(
                "注音",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "Annotated",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "BoutiqueBitmap7x7",
              child: Text(
                "點陣",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "BoutiqueBitmap7x7",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "otakupen",
              child: Text(
                "自動",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "otakupen",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "Dot_circle",
              child: Text(
                "圓形",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "Dot_circle",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "Dot_square",
              child: Text(
                "方形",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "Dot_square",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "Dot_diamond",
              child: Text(
                "鑽石",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "Dot_diamond",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "ebas927",
              child: Text(
                "說文",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "ebas927",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "setofont",
              child: Text(
                "瀨戶",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "setofont",
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "NotoSansTC",
              child: Text(
                "思源",
                style: TextStyle(
                  color: showTextStyleColor,
                  fontSize: showTextStyleSize,
                  fontFamily: "NotoSansTC",
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final userWorkSpace = Padding(
      padding: EdgeInsets.all(10.0),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            flex: 10,
            child: userPhoto,
          ),
          Expanded(
            flex: 1,
            child: userDraw,
          ),
        ],
      ),
    );

    final pageAction = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        //previousButton : back to PickPhotoPage()
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: previousButtonDesign,
        ),
        //nextButton => ShowResultPage(resultPhoto)
        TextButton(
          onPressed: () async {
            setState(() {
              exporting = true;
            });
            try {
              RenderRepaintBoundary boundary = _widgetKey.currentContext!
                  .findRenderObject() as RenderRepaintBoundary;
              final ui.Image image = await boundary.toImage();
              final ByteData? byteData =
                  await image.toByteData(format: ui.ImageByteFormat.png);
              final Uint8List pngBytes = byteData!.buffer.asUint8List();
              final finalImageName =
                  'emotion_${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}_${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}.jpg';
              var appDocDir = await getTemporaryDirectory();
              String savePath = appDocDir.path + "/" + finalImageName;
              File(savePath).writeAsBytes(pngBytes);
              ImageGallerySaver.saveFile(savePath);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => ShowResultPage(
                    resultPhoto: savePath,
                  ),
                ),
                (Route router) => false,
              );
            } catch (e) {
              print(e.toString());
            }
          },
          child: nextButtonDesign,
        ),
      ],
    );

    return exporting
        ? WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Scaffold(
              body: Center(
                child: LoadingAnimation(),
              ),
            ),
          )
        : WillPopScope(
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
                  userWorkSpace,
                  pageAction,
                ],
              ),
            ),
          );
  }
}
