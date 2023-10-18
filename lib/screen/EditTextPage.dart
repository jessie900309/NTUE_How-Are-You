import 'dart:io';
import 'package:how_are_you/screen/PickPhotoPage.dart';
import 'package:how_are_you/util/LoadingAnimation.dart';
import 'package:how_are_you/util/UtilFunction.dart';
import 'package:path/path.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:how_are_you/util/Constants.dart';

class EditTextPage extends StatefulWidget {
  // route :
  // HomePage() <= EditTextPage / Loading =>>>  PickPhotoPage(photoList,)
  File file;

  EditTextPage({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  _EditTextPageState createState() => _EditTextPageState();
}

class _EditTextPageState extends State<EditTextPage> {
  bool waiting = false;

  @override
  Widget build(BuildContext context) {
    Future<http.StreamedResponse> sendImgur(
        File uploadImage, String uploadImageName) async {
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://api.imgur.com/3/image'));
      request.headers.addAll({
        'Authorization': '${ImgurConstants().accessToken}',
      });
      request.fields.addAll({
        'album': '${ImgurConstants().album}',
      });
      var picture = await http.MultipartFile.fromBytes(
          'image', (uploadImage).readAsBytesSync(),
          filename: uploadImageName);
      request.files.add(picture);
      var response = await request.send();
      print("\nsendImgur response : ${response.statusCode}");
      return response;
    }

    Future<String> trySendImgur(
        File uploadImage, String uploadImageName) async {
      http.StreamedResponse responseFromImgur;
      String responseImgurUrl = '';
      bool isStatus200 = false;
      do {
        try {
          // Imgur API
          responseFromImgur = await sendImgur(uploadImage, uploadImageName);
          isStatus200 = (responseFromImgur.statusCode == 200);
          // 解析 Imgur response 取得圖片link(String)
          var responseData = await responseFromImgur.stream.toBytes();
          String responseString = String.fromCharCodes(responseData);
          print("responseFromImgur.body = \n${responseString}");
          Map<String, dynamic> responseJson =
              convert.jsonDecode(responseString);
          responseImgurUrl = responseJson['data']['link'];
        } catch (e) {
          isStatus200 = false;
        }
        if (!isStatus200) {
          await showDialog(
              context: context,
              builder: (context) {
                return apiExceptionDialog();
              });
        }
      } while (!isStatus200);
      return responseImgurUrl;
    }

    Future<http.Response> sendAI(String uploadImage, String uploadImageName,
        String uploadEmotionText) async {
      Uri url = Uri.parse(
          "http://jcwang.ntue.edu.tw:5000/submit?file_name=${uploadImage}&file_url=${uploadImageName}&emotion_text=${uploadEmotionText}");
      var response = await http.get(url);
      print("\nsendAI response : ${response.statusCode}");
      return response;
    }

    Future<List<String>> trySendAI(String uploadImage, String uploadImageName,
        String uploadEmotionText) async {
      List<String> aiImageUrlList = [];
      bool isStatus200 = false;
      do {
        try {
          // AI API
          http.Response responseFromAI =
              await sendAI(uploadImage, uploadImageName, uploadEmotionText);
          isStatus200 = (responseFromAI.statusCode == 200);
          print("responseFromAI.body = \n${responseFromAI.body}");
          // 解析 AI response 取得圖片link(List<String>)
          Map<String, dynamic> aiImageJson =
              convert.jsonDecode(responseFromAI.body);
          aiImageJson.forEach((k, v) => aiImageUrlList.add(v));
        } catch (e) {
          isStatus200 = false;
        }
        if (!isStatus200) {
          await showDialog(
              context: context,
              builder: (context) {
                return apiExceptionDialog();
              });
        }
      } while (!isStatus200);
      return aiImageUrlList;
    }

    final TextEditingController _textController = TextEditingController();

    final InputDecoration textFieldInputDecoration = InputDecoration(
      icon: Icon(
        Icons.attach_file_outlined,
        color: textFieldShowColor,
      ),
      labelText: "How are you?",
      labelStyle: TextStyle(
        color: textFieldShowColor,
      ),
      filled: true,
      fillColor: textFieldFilledColor,
      focusColor: textFieldCursorColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: textFieldShowColor,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );

    final TextField textField = TextField(
      controller: _textController,
      keyboardType: TextInputType.multiline,
      maxLines: 5,
      // minLines: 1,
      cursorColor: textFieldCursorColor,
      decoration: textFieldInputDecoration,
    );

    final Row pageAction = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        //previousButton : back to HomePage()
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: previousButtonDesign,
        ),
        //nextButton =>>> call api
        TextButton(
          onPressed: () async {
            if (_textController.text != "") {
              setState(() {
                waiting = true;
              });
              try {
                // data
                File passImage = widget.file;
                String passText = _textController.text;
                String passFilename = basename((passImage).path);
                // imgur (http)
                var passImgurUrl = await trySendImgur(passImage, passFilename);
                // AI (http)
                var aiImageUrlList =
                    await trySendAI(passFilename, passImgurUrl, passText);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PickPhotoPage(
                      imageList: aiImageUrlList,
                      text: passText,
                    ),
                  ),
                  (Route router) => false,
                );
              } catch (e) {
                print(e.toString());
              }
            }
          },
          child: nextButtonDesign,
        ),
      ],
    );

    return waiting
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
        : GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              body: Padding(
                padding: scaffoldPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    textField,
                    pageAction,
                  ],
                ),
              ),
            ),
          );
  }
}
