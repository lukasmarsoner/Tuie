import 'dart:math';
import 'package:flutter/material.dart';

class Event{
  String _name;
  DateTime _due, _completionDate;
  Duration _duration;
  Image _icon;
  int _completionProgress;

  //Setters with sanity-checks
  set name(String valIn) => (valIn != null && valIn.length != 0)?_name = valIn.trim():throw new Exception('Invalid name!');
  set due(DateTime valIn) => valIn != null?_due = valIn:throw new Exception('Invalid Date!');
  set completionDate(DateTime valIn) => valIn != null?_completionDate = valIn:throw new Exception('Invalid Date!');
  set icon(Image valIn) => valIn != null?_icon = valIn:throw new Exception('Invalid Icon!');
  //We only support events with durations of at least 15 minuts
  set duration(Duration valIn){
    if(valIn != null){
      if(valIn.inMinutes<15){valIn=Duration(minutes: 15);}
      _duration = valIn;
    }
    else{throw new Exception('Invalid Duration!');}
  }
  void shiftDueDate(Duration valIn) => valIn != null?_due = _due.add(valIn):throw new Exception('Invalid Duration!');

  //Calculate the remaining time as a fraction of 255 to be used as an alpha-values
  void calculateCompletionProgress(DateTime now){
    if(now==null){now = DateTime.now();}
    int _remaintingTime = _due.subtract(duration).difference(now).inMinutes;
    _completionProgress = _remaintingTime < 0
      //Set to 255 if the event is over-due
      ?255
      :(255 - atan(_due.subtract(duration).difference(now).inMinutes / duration.inMinutes) / (pi / 2) * 255).round();
    }

  //Getters for valiables
  get name => _name;
  get due => _due;
  get duration => _duration;
  get icon => _icon;
  get completionDate => _completionDate;
  get completionProgress => _completionProgress;
}