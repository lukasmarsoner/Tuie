import 'package:flutter/material.dart';
import 'dart:io' show Platform;

ThemeData lightTheme = ThemeData(
  textTheme: Platform.isAndroid?Typography.blackMountainView:Typography.blackCupertino
);