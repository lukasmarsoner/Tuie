import 'package:flutter/material.dart';
import 'package:tuieno/events.dart';
import 'events.dart';

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
  final EventItemListState eventItemList = new EventItemListState();

  //We can provide the events here for testing - later these will be loaded
  MyApp({this.eventRegistry}){
    eventItemList.eventRegistry = eventRegistry;
    //For testing => add a few test events
    for(int i=0; i<10; i++){
      eventRegistry.registerEvent(_getTestEvent());
    }
    }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuieNo',
      home: new Scaffold(
        body: new StreamBuilder(
          stream: eventRegistry.eventStream(),
          builder: (BuildContext context, AsyncSnapshot<Map<int, bool>> event){
            switch (event.connectionState) {
              case ConnectionState.waiting:
                return const Text('Loading...');
              default:
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
  EventRegistry eventRegistry;

  void updateEventList(Map<int, bool>newEvents){
    for(int iEvent in newEvents.keys){
      //Add or update entries
      //Negative indexes are used for deletion
      newEvents[iEvent]
      ?eventItems.keys.contains(iEvent)
        ?eventItems.remove(iEvent)
        :throw new Exception('Invalid index!')
      :eventItems[iEvent] = ListItem(iEvent: iEvent, eventRegistry: eventRegistry);
    }
  }

  @override
  Widget build(BuildContext context){
    return ListView(children: eventItems.values.toList());
  }
}

class ListItem extends StatelessWidget{
  final int iEvent;
  final EventRegistry eventRegistry;

  ListItem({this.iEvent, this.eventRegistry});

  @override
  Widget build(BuildContext context){
    //Show up-to 6 items on screen on phones
    //TODO: Add proper support for PCs

    int nItemsOnScreen = 6;

    double _widgetHeigt = MediaQuery.of(context).size.height / nItemsOnScreen;
    double _iconHeight = _widgetHeigt * 4/10;

    return Dismissible(
      onDismissed: (direction) {
          direction == DismissDirection.startToEnd
          ?eventRegistry.deleteEvent(iEvent)
          :eventRegistry.updateEventCompletionStatus(iEvent: iEvent, newStatus: true);
        },
      key: Key(iEvent.toString()),
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black)),
          color: Colors.red.withAlpha(eventRegistry.getCompletionPercentage(iEvent))),
        height: _widgetHeigt,
        child: Container(
          alignment: Alignment.center,
          child: ListTile(
            leading: Icon(eventRegistry.getEventIcon(iEvent), size: _widgetHeigt / 3),
            title: Text(eventRegistry.getEventName(iEvent))
          )
        )
      ),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: _iconHeight/4),
        color: Colors.green, 
        child: Icon(Icons.check_circle_outline, size: _iconHeight)
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: _iconHeight/4),
        color: Colors.yellow, 
        child: Icon(Icons.delete_outline, size: _iconHeight)
      ),
    );
  }
}