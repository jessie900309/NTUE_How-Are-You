import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:how_are_you/util/Constants.dart';

final exitAppDialogContentText = "Press \"leave\" "
    "if you want to exit the application.";
final exitAppDialogActionText = "Cancel";
final apiExceptionDialogContentText = "Sorry, API is not working QAQ\n"
    "Please confirm that the Internet connection is working properly.";
final apiExceptionDialogActionText = "Try again";
final fileExceptionDialogContentText = "We only accept JPG/JPEG file (<700kB).";
final fileExceptionDialogActionText = "I see";

const Color appDialogBackgroundColor = Color(0xFFFAF0E6);
const Color appDialogTitleColor = Color(0xFF704214);
const double appDialogTitleSize = 20.0;
const Color appDialogContentColor = Color(0xFFB87333);
const double appDialogTextSize = 16.0;

final appDialogBackground = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(20),
);

final dialogContentStyle = TextStyle(
  color: appDialogContentColor,
  fontSize: appDialogTextSize,
);
final dialogActionPopStyle = TextStyle(
  color: appDialogActionColor,
  fontSize: appDialogTextSize,
);
final dialogActionLeaveStyle = TextStyle(
  color: Colors.black38,
  fontSize: appDialogTextSize,
);

final dialogTitleTips = Text(
  "Tips",
  style: TextStyle(
    color: appDialogTitleColor,
    fontSize: appDialogTitleSize,
    fontWeight: FontWeight.bold,
  ),
);
final dialogActionLeave = Text(
  "leave",
  style: dialogActionLeaveStyle,
);

Future<void> exitApp(BuildContext ctx) async {
  Navigator.pop(ctx);
  await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}

class ExitAppDialog extends StatelessWidget {
  const ExitAppDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: appDialogBackgroundColor,
      shape: appDialogBackground,
      title: dialogTitleTips,
      content: Text(
        exitAppDialogContentText,
        style: dialogContentStyle,
      ),
      actions: [
        TextButton(
          onPressed: () => exitApp(context),
          child: dialogActionLeave,
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            exitAppDialogActionText,
            style: dialogActionPopStyle,
          ),
        ),
      ],
    );
  }
}

class apiExceptionDialog extends StatelessWidget {
  const apiExceptionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: appDialogBackgroundColor,
      shape: appDialogBackground,
      title: dialogTitleTips,
      content: Text(
        apiExceptionDialogContentText + "\nor\n" + exitAppDialogContentText,
        style: dialogContentStyle,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            apiExceptionDialogActionText,
            style: dialogActionPopStyle,
          ),
        ),
        TextButton(
          onPressed: () => exitApp(context),
          child: dialogActionLeave,
        ),
      ],
    );
  }
}

class fileExceptionDialog extends StatelessWidget {
  const fileExceptionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: appDialogBackgroundColor,
      shape: appDialogBackground,
      title: dialogTitleTips,
      content: Text(
        fileExceptionDialogContentText,
        style: dialogContentStyle,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            fileExceptionDialogActionText,
            style: dialogActionPopStyle,
          ),
        ),
      ],
    );
  }
}
