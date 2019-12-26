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
  EventItemListState eventItemList = new EventItemListState();

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
                    eventItemList.updateEventList(event.data);
                    return eventItemList.build(context);
                }
            }
          },
        )
      ),
    );
  }
}

class EventItemList extends StatefulWidget{
  @override
  EventItemListState createState() => new EventItemListState();
}

class EventItemListState extends State<EventItemList>{
  Map<int,Widget> eventItems = Map<int,Widget>();

  void updateEventList(Map<int,Event> newEvents){
    for(int key in newEvents.keys){
      //Add or update entries
      eventItems[key] = ListItem(newEvents[key]);
    }
  }

  @override
  Widget build(BuildContext context){
    return ListView(children: eventItems.values.toList());
  }
}

class ListItem extends StatelessWidget{
  final Event event;

  ListItem(this.event);

  @override
  Widget build(BuildContext context){
    return Row(
      children: <Widget>[
      Text(event.name)
    ]);
  }
}