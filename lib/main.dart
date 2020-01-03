import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tuie/events.dart';
import 'events.dart';
import 'dart:async';
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

class FullScreenMessage extends StatelessWidget{
  final String content;
  final IconData icon;

  FullScreenMessage({this.content, this.icon});

  @override
  Widget build(BuildContext context){
    Text _text = Text(content);

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 1/20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 3/4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[Icon(icon, size: MediaQuery.of(context).size.width * 1/4,), _text],
            )
        )]
      )
    );
  }
}

class InteractiveUILists extends StatefulWidget {
  static InteractiveUIListsState of(BuildContext context) => context.findAncestorStateOfType<InteractiveUIListsState>();
  final EventRegistry eventRegistry;
  
  InteractiveUILists(this.eventRegistry);

  @override
  InteractiveUIListsState createState() => InteractiveUIListsState(eventRegistry: eventRegistry);
}

class InteractiveUIListsState extends State<InteractiveUILists>{
  EventRegistry eventRegistry;
  Function updateEventEntries;
  StreamSubscription eventStreamSubscription;
  Map<bool, Map<int,Widget>> eventItems = new Map<bool, Map<int,Widget>>();
  List<int> eventsSortedByCompletionProgress = new List<int>();
  List<int> eventsSortedByCompletionDate = new List<int>();

  updateEventList(Map<bool, Map<int, bool>> newEvents){
    if(newEvents != null){
      for(bool isOpen in newEvents.keys){
        if(newEvents[isOpen] != null){
          for(int iEvent in newEvents[isOpen].keys){
            newEvents[isOpen][iEvent]
            ?eventItems[isOpen].keys.contains(iEvent)
              ?eventItems[isOpen].remove(iEvent)
              :throw new Exception('Invalid index!')
            :eventItems[isOpen][iEvent] = isOpen
              ?OpenEventListItem(iEvent: iEvent, eventRegistry: eventRegistry)
              :ClosedEventListItem(iEvent: iEvent, eventRegistry: eventRegistry);
          }
        }
      }
    }
    eventsSortedByCompletionProgress = eventRegistry.getEventsOrderedByCompletionProgress(now: DateTime.now());
    eventsSortedByCompletionDate = eventRegistry.getEventsSortedByCompletionDate();
    setState(() => null);
  }

  InteractiveUIListsState({this.eventRegistry});

  @override
  dispose(){
    eventStreamSubscription.cancel();
    super.dispose();
  }

  @override
  initState(){
    super.initState();
    eventItems[true] = new Map<int,Widget>();
    eventItems[false] = new Map<int,Widget>();
    eventStreamSubscription = eventRegistry.eventStream().listen((newEvents) => updateEventList(newEvents));
  }

  SliverAppBar getSliverAppBar(BuildContext context){
    double _screenHeight = MediaQuery.of(context).size.height;
    SliverAppBar _appBar = new SliverAppBar(
      expandedHeight: _screenHeight * 1/4,
      title: Text('TuieNo'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.only(bottomEnd: Radius.circular(10.0), bottomStart: Radius.circular(10.0))),
      pinned: true,
      snap: true,
      bottom: getTabBar(context),
      floating: true,
    );

    return _appBar;
  }

  Widget getTabBar(BuildContext context){
    return TabBar(
      labelColor: white,
      onTap: (_) => setState(()=> null),
      unselectedLabelColor: Colors.black,
      tabs: [
        new Tab(icon: new Icon(Icons.info), key: Key('OpenItemsTab'),),
        new Tab(icon: new Icon(Icons.account_circle), key: Key('ClosedItemsTab'),),
        new Tab(icon: new Icon(Icons.lightbulb_outline), key: Key('AnalysisTab'),),
      ],
    );
  }

  List<Widget> _getOpenEventsWidgets(){
    List<Widget> _widgetsRange = new List<Widget>();
    switch(eventsSortedByCompletionProgress.length) {
      case 0:
        _widgetsRange.add(new FullScreenMessage(content: 'Nothing to to right now 😎', icon: Icons.work));
        return _widgetsRange;
      default:
        for(int iItem in eventsSortedByCompletionProgress){
          _widgetsRange.add(eventItems[true][iItem]);
        }
        return _widgetsRange;
    }
  }

  List<Widget> _getClosedEventsWidgets(){
    List<Widget> _widgetsRange = new List<Widget>();
    switch(eventsSortedByCompletionDate.length) {
      case 0:
        _widgetsRange.add(new FullScreenMessage(content: 'No finished tasks yet\nLet\'s create some to get started 😄', icon: Icons.work));
        return _widgetsRange;
      default:
        for(int iItem in eventsSortedByCompletionDate){
          _widgetsRange.add(eventItems[false][iItem]);
        }
        return _widgetsRange;
    }
  }

  List<Widget> _getWidgetRanges(){
    switch (DefaultTabController.of(context).index) {
      case 0:
        return _getOpenEventsWidgets();
    case 1:
        return _getClosedEventsWidgets();
    default:
      return <Widget>[new FullScreenMessage(content: 'No graphs yet 🙃', icon: Icons.work)];
    } 
  }

  //Sorts the list of event items by their completion progress
  List<Widget> yieldEventSliversSortedByCompletion(BuildContext context){
    List<Widget> _sliverList = [getSliverAppBar(context),
      SliverList(
        delegate: SliverChildListDelegate(_getWidgetRanges())
      )
    ];
    return _sliverList;
  }

  @override
  Widget build(BuildContext context){
    return CustomScrollView(slivers: yieldEventSliversSortedByCompletion(context));
  }
}


abstract class EventListItem extends StatelessWidget{
  final int iEvent;
  final EventRegistry eventRegistry;

  EventListItem({this.iEvent, this.eventRegistry});

  //Used for testing
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return iEvent.toString();
  }
}

class OpenEventListItem extends EventListItem{

  OpenEventListItem({iEvent, eventRegistry}) : super(iEvent: iEvent, eventRegistry: eventRegistry);

  @override
  Widget build(BuildContext context){
    //Show up-to 8 items on screen on phones
    //TODO: Add proper support for PCs

    int nItemsOnScreen = 8;

    double _widgetHeigt = MediaQuery.of(context).size.height / nItemsOnScreen;
    double _iconHeight = _widgetHeigt * 4/10;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: red.withAlpha(eventRegistry.getEventCompletionProgress(iEvent)),
        width: MediaQuery.of(context).size.width,
        height: _widgetHeigt,
        child: Dismissible(
          key: Key(iEvent.toString()),
          onDismissed: (direction) {
            direction == DismissDirection.startToEnd
              ?eventRegistry.setEventToCompleted(iEvent: iEvent)
              :eventRegistry.deleteEvent(iEvent);
            },
          child: Container(
            alignment: Alignment.center,
            child: ListTile(
              leading: Icon(eventRegistry.getEventIcon(iEvent), size: _widgetHeigt / 3),
              title: Text(eventRegistry.getEventName(iEvent))
            )
          ),
          background: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: _iconHeight/4),
            color: green, 
            child: Icon(Icons.check_circle_outline, size: _iconHeight)
          ),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: _iconHeight/4),
            color: brown, 
            child: Icon(Icons.delete_outline, size: _iconHeight)
          ),
        )
      )
    );
  }
}

class ClosedEventListItem extends EventListItem{

  ClosedEventListItem({iEvent, eventRegistry}) : super(iEvent: iEvent, eventRegistry: eventRegistry);

  @override
  Widget build(BuildContext context){
    //Show up-to 8 items on screen on phones
    //TODO: Add proper support for PCs

    int nItemsOnScreen = 8;

    double _widgetHeigt = MediaQuery.of(context).size.height / nItemsOnScreen;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: pink,
        width: MediaQuery.of(context).size.width,
        height: _widgetHeigt,
        child: Container(
            key: Key(iEvent.toString()),
            alignment: Alignment.center,
            child: ListTile(
              leading: Icon(eventRegistry.getEventIcon(iEvent), size: _widgetHeigt / 3),
              title: Text(eventRegistry.getEventName(iEvent))
            )
          ),
        )
    );
  }
}
