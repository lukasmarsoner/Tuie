import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tuie/business_logic/event_registry.dart';
import 'package:tuie/business_logic/event.dart';
import 'package:tuie/ui_elements/interactive_list.dart';
import 'package:tuie/design.dart';

//Only used for testing
Map<String,dynamic> testIO = {
  'name': 'Test Name',
  'due': new DateTime.now().add(new Duration(days: 2)),
  'duration': new Duration(hours: 10),
  'icon': Icons.account_box,
};

Event _getTestEvent({String name, DateTime due, Duration duration, Icons icon}){
  Event _event = new Event();
  _event.name = name == null?testIO['name']:name;
  _event.due = due == null?testIO['due']:due;
  _event.icon = icon == null?testIO['icon']:icon;
  _event.duration = duration == null?testIO['duration']:duration;
  return _event;
}
//Only used for testing
void main() => runApp(MyApp(eventRegistry: new EventRegistry()));

class MyApp extends StatelessWidget {
  final EventRegistry eventRegistry;

  //We can provide the events here for testing - later these will be loaded
  MyApp({this.eventRegistry}){
    //For testing => add a few test events
    //for(int i=0; i<10; i++){
    //  eventRegistry.registerEvent(_getTestEvent());
    //}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      home: new Scaffold(
        backgroundColor: Color(0xffECECEC),
        body: DefaultTabController(
          length: 3,
          child: SafeArea(
              child: new InteractiveUILists(eventRegistry),
              )
            )
        )
    );
  }
}