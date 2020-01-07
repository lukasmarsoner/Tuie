import 'package:tuie/business_logic/event.dart';
import 'package:flutter/material.dart';


Map<String,dynamic> testIO = {
  'name': 'Test Name',
  'due': new DateTime.now().add(new Duration(hours: 20)),
  'duration': new Duration(minutes: 30),
  'icon': Image.asset('assets/icons/event_types/camping-tent.png'),
};

Event getTestEvent({String name, DateTime due, Duration duration, IconData icon}){
  Event _event = new Event();
  _event.name = name == null?testIO['name']:name;
  _event.due = due == null?testIO['due']:due;
  _event.icon = icon == null?testIO['icon']:icon;
  _event.duration = duration == null?testIO['duration']:duration;
  return _event;
}