import 'package:flutter/material.dart';
import 'dart:io' show Platform;

const Color pink = const Color(0xffFBAFD0);
const Color white = const Color(0xffFBF5F5);
const Color yellow = const Color(0xffFEC6A9);
const Color blue = const Color(0xff111850);
const Color green = const Color(0xff056C1E);
const Color red = const Color(0xffC1223E);
const Color purple = const Color(0xffB8668D);
const Color brown = const Color(0xff544D53);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: purple,
  accentColor: purple,
  buttonColor: white,
  highlightColor: yellow,
  splashColor: pink,
  scaffoldBackgroundColor: white,
  textSelectionColor: yellow,
  textTheme: Platform.isAndroid?Typography.blackMountainView:Typography.blackCupertino
);