import 'package:flutter/material.dart';
import 'dart:io' show Platform;

Color primaryColor, backgroundColor;
Image seasonalImage;
Color bottomMenuTextColor;

//Determine the current season in order to set the theme
String setSeasonalTheme({DateTime fakeCurrentYear}){
  //Used for testing
  DateTime _currentDate = fakeCurrentYear==null?new DateTime.utc(2020, 12, 1):fakeCurrentYear;
  int _currentYear = DateTime.now().year;

  Map<String, Map<String, DateTime>> _seasons = new Map<String, Map<String, DateTime>>();
  _seasons['spring'] = {'start': new DateTime.utc(_currentYear, 3, 1),
                        'end': new DateTime.utc(_currentYear, 5, 31),};
  _seasons['summer'] = {'start': new DateTime.utc(_currentYear, 6, 1),
                        'end': new DateTime.utc(_currentYear, 8, 31),};
  _seasons['autumn'] = {'start': new DateTime.utc(_currentYear, 9, 1),
                        'end': new DateTime.utc(_currentYear, 11, 31),};
  //Winter is not needed as it is determined by exclusion

  //Spring
  if(_currentDate.isAfter(_seasons['spring']['start']) && _currentDate.isBefore(_seasons['spring']['end'])){
    primaryColor = Color(0xffa91245);
    backgroundColor = Color(0xffd7a4ad);
    bottomMenuTextColor = Colors.white;
    seasonalImage = Image.asset('assets/top_menu/spring.jpg', fit: BoxFit.cover);
    return 'spring';
  }
  else if(_currentDate.isAfter(_seasons['summer']['start']) && _currentDate.isBefore(_seasons['summer']['end'])){
    primaryColor = Color(0xff00b395);
    backgroundColor = Color(0xffadd4d3);
    bottomMenuTextColor = Colors.black;
    seasonalImage = Image.asset('assets/top_menu/summer.jpg', fit: BoxFit.cover);
    return 'summer';
  }
  else if(_currentDate.isAfter(_seasons['autumn']['start']) && _currentDate.isBefore(_seasons['autumn']['end'])){
    primaryColor = Color(0xff99342a);
    backgroundColor = Color(0xffffb24a);
    bottomMenuTextColor = Colors.white;
    seasonalImage = Image.asset('assets/top_menu/autumn.jpg', fit: BoxFit.cover);
    return 'autumn';
  }
  else{
    primaryColor = Color(0xff6c8098);
    backgroundColor = Color(0xfff0f5fb);
    bottomMenuTextColor = Colors.white;
    seasonalImage = Image.asset('assets/top_menu/winter.jpg', fit: BoxFit.cover);
    return 'winter';
  }

}


ThemeData lightTheme = ThemeData(
  primaryColor: primaryColor,
  textTheme: Platform.isAndroid?Typography.blackMountainView:Typography.blackCupertino
);