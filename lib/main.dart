import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tuieno/events.dart';
import 'events.dart';
import 'dart:async';
import 'package:tuieno/design.dart';

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
  final OpenEventItemListState openEventItemList = new OpenEventItemListState();
  final ClosedEventItemListState closedEventItemList = new ClosedEventItemListState();

  //We can provide the events here for testing - later these will be loaded
  MyApp({this.eventRegistry}){
    openEventItemList.eventRegistry = eventRegistry;
    //For testing => add a few test events
    //for(int i=0; i<10; i++){
    //  eventRegistry.registerEvent(_getTestEvent());
    //}
    }

  Widget getMainPages(BuildContext context, String page){
    return new StreamBuilder(
      stream: eventRegistry.eventStream(),
      builder: (BuildContext context, AsyncSnapshot<Map<bool, Map<int, bool>>> event){
        switch (event.connectionState) {
          case ConnectionState.waiting:
            return new FullScreenMessage(content: 'Loading...', icon: Icons.work);
          default:
          {
            if(page == 'open'){
              openEventItemList.updateEventList(event.data[true]);
              return openEventItemList.build(context);
              }
            else if(page == 'closed'){
              closedEventItemList.updateEventList(event.data[false]);
              return closedEventItemList.build(context);
              }
            else{return openEventItemList.build(context);}
        }
      }},
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      home:  DefaultTabController(
        length: 3,
        child: new Scaffold(
          body: SafeArea(
            child: TabBarView(
              children: <Widget>[
                getMainPages(context, 'open'),
                getMainPages(context, 'closed'),
                getMainPages(context, 'stats'),
              ]
            )
          )
        )
        ),
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


class OpenEventItemList extends StatefulWidget{
  @override
  OpenEventItemListState createState() => new OpenEventItemListState();
}

class OpenEventItemListState extends State<OpenEventItemList>{
  Map<int,Widget> eventItems = Map<int,Widget>();
  List<int> eventsSortedByCompletionProgress = new List<int>();
  EventRegistry eventRegistry;

  void updateEventList(Map<int, bool>newEvents){
    if(newEvents != null){
      for(int iEvent in newEvents.keys){
        //Add or update entries
        newEvents[iEvent]
        ?eventItems.keys.contains(iEvent)
          ?eventItems.remove(iEvent)
          :throw new Exception('Invalid index!')
        :eventItems[iEvent] = EventListItem(iEvent: iEvent, eventRegistry: eventRegistry);
      }
    }
  }

  //Sorts the list of event items by their completion progress
  List<Widget> yieldEventSliversSortedByCompletion(BuildContext context){
    List<Widget> _sliverList = eventItems.length == 0
    ?[new MainSliverAppBar(eventRegistry),
      SliverList(
        delegate: SliverChildListDelegate(
        [new FullScreenMessage(content: 'Nothing to to right now 😎', icon: Icons.work)]
        )
      )
    ]
    :[new MainSliverAppBar(eventRegistry),
      SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int iItem) {
        return eventItems[eventsSortedByCompletionProgress[iItem]];
      },
      childCount: eventRegistry.nEvents,
      )
    )];
    return _sliverList;
  }

  @override
  Widget build(BuildContext context){
    eventsSortedByCompletionProgress = eventRegistry.getEventsOrderedByCompletionProgress(now: DateTime.now());
    return CustomScrollView(slivers: yieldEventSliversSortedByCompletion(context));
  }
}


class ClosedEventItemList extends StatefulWidget{
  @override
  ClosedEventItemListState createState() => new ClosedEventItemListState();
}

class ClosedEventItemListState extends State<ClosedEventItemList>{
  Map<int,Widget> eventItems = Map<int,Widget>();
  List<int> eventsSortedByCompletionDate = new List<int>();
  EventRegistry eventRegistry;

  void updateEventList(Map<int, bool>newEvents){
    if(newEvents != null){
      for(int iEvent in newEvents.keys){
        //We only need to add entries as no updates should ever occur
        eventItems[iEvent] = EventListItem(iEvent: iEvent, eventRegistry: eventRegistry);
      }
    }
  }

  //Sorts the list of event items by their completion progress
  List<Widget> yieldEventSliversSortedByCompletion(BuildContext context){
    List<Widget> _sliverList = eventItems.length == 0
    ?[new MainSliverAppBar(eventRegistry),
      SliverList(
        delegate: SliverChildListDelegate(
        [new FullScreenMessage(content: 'No completed events yet - let\'s get going 🥰', icon: Icons.work)]
        )
      )
    ]
    :[new MainSliverAppBar(eventRegistry),
      SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int iItem) {
        return eventItems[eventsSortedByCompletionDate[iItem]];
      },
      childCount: eventRegistry.nEvents,
      )
    )];
    return _sliverList;
  }

  @override
  Widget build(BuildContext context){
    eventsSortedByCompletionDate = eventRegistry.getEventsSortedByCompletionDate();
    return CustomScrollView(slivers: yieldEventSliversSortedByCompletion(context));
  }
}


class MainSliverAppBar extends StatelessWidget{
  EventRegistry eventRegistry = new EventRegistry();

  MainSliverAppBar(this.eventRegistry);

  SliverAppBar getSliverAppBar(BuildContext context){
    double _screenHeight = MediaQuery.of(context).size.height;
    SliverAppBar _appBar = new SliverAppBar(
      expandedHeight: _screenHeight * 1/4,
      title: Text('TuieNo'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.only(bottomEnd: Radius.circular(10.0), bottomStart: Radius.circular(10.0))),
      pinned: true,
      snap: true,
      bottom: getTabBar(),
      floating: true,
    );

    return _appBar;
  }

  Widget getTabBar(){
    return TabBar(
      labelColor: white,
      onTap: (_) => eventRegistry.cancleEventStream(),
      unselectedLabelColor: Colors.black,
      tabs: [
        new Tab(icon: new Icon(Icons.info), key: Key('OpenItemsTab'),),
        new Tab(icon: new Icon(Icons.account_circle), key: Key('ClosedItemsTab'),),
        new Tab(icon: new Icon(Icons.lightbulb_outline), key: Key('AnalysisTab'),),
      ],
    );
  }

  @override
  Widget build(BuildContext context){
    return getSliverAppBar(context);
  }
}


class EventListItem extends StatelessWidget{
  final int iEvent;
  final EventRegistry eventRegistry;

  EventListItem({this.iEvent, this.eventRegistry});

  //Used for testing
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return iEvent.toString();
  }

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
              ?eventRegistry.deleteEvent(iEvent)
              :eventRegistry.setEventToCompleted(iEvent: iEvent);
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