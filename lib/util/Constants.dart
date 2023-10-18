import 'package:flutter/material.dart';

class ImgurConstants {
  final String post = "POST";
  final String baseurl = "https://i.imgur.com/";
  final String accessToken = "Bearer 1fddc4c11d82df9142c6894ef1005871fcc7edc3";
  final String album = "2n7YVor";
}

const String appName = "How are you?";

const Color appPrimaryColor = Color(0xFFFFD9DA);
const Color appStatusBarColor = shrinePink300;

// image size
const imageFixWidth = 1080.0;
const imageFixHeight = 1920.0;

//page
const scaffoldPadding = EdgeInsets.all(10.0);

//textField
const Color textFieldCursorColor = Colors.brown;
const Color textFieldShowColor = shrineBrown900;
const Color textFieldFilledColor = shrineSurfaceWhite;

//textButton
const Color textButtonColor = shrineBrown900;
const textSize = 16.0;
const iconSize = 20.0;
const textButtonStyle = TextStyle(
  color: textButtonColor,
  fontSize: iconSize,
);
final nextButtonDesign = Row(
  textDirection: TextDirection.ltr,
  children: [
    Text(
      "Next",
      style: textButtonStyle,
    ),
    Icon(
      Icons.arrow_forward_ios_rounded,
      color: textButtonColor,
      size: iconSize,
    ),
  ],
);
final previousButtonDesign = Row(
  textDirection: TextDirection.rtl,
  children: [
    Text(
      "Previous",
      style: textButtonStyle,
    ),
    Icon(
      Icons.arrow_back_ios_rounded,
      color: textButtonColor,
      size: iconSize,
    ),
  ],
);

//alterDialog
const Color appDialogActionColor = Color(0xFFFFB366);

// shrine Theme

IconThemeData _customIconTheme(IconThemeData original) {
  return original.copyWith(color: shrineBrown900);
}

ThemeData shrineTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: _shrineColorScheme,
    accentColor: shrineBrown900,
    primaryColor: appPrimaryColor,
    buttonColor: shrinePink100,
    scaffoldBackgroundColor: appPrimaryColor,
    cardColor: shrineBackgroundWhite,
    textSelectionColor: shrinePink100,
    errorColor: shrineErrorRed,
    buttonTheme: const ButtonThemeData(
      colorScheme: _shrineColorScheme,
      textTheme: ButtonTextTheme.normal,
    ),
    primaryIconTheme: _customIconTheme(base.iconTheme),
    iconTheme: _customIconTheme(base.iconTheme),
  );
}

const ColorScheme _shrineColorScheme = ColorScheme(
  primary: shrinePink100,
  primaryVariant: shrineBrown900,
  secondary: shrinePink400,
  secondaryVariant: shrineBrown900,
  surface: shrineSurfaceWhite,
  background: shrineBackgroundWhite,
  error: shrineErrorRed,
  onPrimary: shrineBrown900,
  onSecondary: shrineBrown900,
  onSurface: shrineBrown900,
  onBackground: shrineBrown900,
  onError: shrineSurfaceWhite,
  brightness: Brightness.light,
);

const Color shrinePink50 = Color(0xFFFEEAE6);
const Color shrinePink100 = Color(0xFFFEDBD0);
const Color shrinePink300 = Color(0xFFFBB8AC);
const Color shrinePink400 = Color(0xFFEAA4A4);

const Color shrineBrown900 = Color(0xFF442B2D);
const Color shrineBrown600 = Color(0xFF7D4F52);

const Color shrineErrorRed = Color(0xFFC5032B);

const Color shrineSurfaceWhite = Color(0xFFFFFBFA);
const Color shrineBackgroundWhite = Colors.white;

const defaultLetterSpacing = 0.03;
