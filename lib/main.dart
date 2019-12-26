import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tuieno/events.dart';

//Only used for testing
Map<String,dynamic> _testIO = {
  'name': 'Test Name',
  'due': new DateTime.now().add(new Duration(days: 2)),
  'duration': new Duration(hours: 10),
};

Event _getTestEvent({String name, DateTime due, Duration duration}){
  Event _event = new Event();
  _event.name = name == null?_testIO['name']:name;
  _event.due = due == null?_testIO['due']:due;
  _event.duration = duration == null?_testIO['duration']:duration;
  return _event;
}
//Only used for testing

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  EventRegistry eventRegistry = new EventRegistry();

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
      title: 'TuieNo',
      home: new Scaffold(
        body: new StreamBuilder(
          stream: eventRegistry.eventStream(),
          builder: (BuildContext context, AsyncSnapshot<Map<int,Event>> event){
            switch (event.connectionState) {
              case ConnectionState.waiting:
                return const Text('Loading...');
              default:
                if (event.hasError) {
                  return Text('Error: ${event.error}');
                  }
                if (event.data.isEmpty) {
                  return new Row(children: <Widget>[Text('Nothing here...')],);
                  }
                else{
                    return EventItemList(event.data);
                }
            }
          },
        )
      ),
    );
  }
}

class EventItemList extends StatelessWidget{
  List<ListItem> eventItems = new List<ListItem>();
  Map<int,Event> eventMap;

  EventItemList(this.eventMap);

  getEventItems(){
    for(int key in eventMap.keys){
      eventItems.add(ListItem(eventMap[key], key));
    }
  }

  @override
  Widget build(BuildContext context){
    getEventItems();
    return ListView(children: eventItems);
  }
}

class ListItem extends StatelessWidget{
  Event event;
  int index;

  ListItem(this.event, this.index);

  @override
  Widget build(BuildContext context){
    return Row(
      key: Key(index.toString()),
      children: <Widget>[
      Text(event.name)
    ]);
  }
}