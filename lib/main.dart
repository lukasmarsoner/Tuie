import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tuieno/events.dart';
import 'events.dart';
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

  //We can provide the events here for testing - later these will be loaded
  MyApp({this.eventRegistry}){
    //For testing => add a few test events
    //for(int i=0; i<10; i++){
    //  eventRegistry.registerEvent(_getTestEvent());
    //}
    }

  @override
  Widget build(BuildContext context) {
    EventList eventList = new EventList(eventRegistry);
    InteractiveUILists interactiveUIElements = new InteractiveUILists(eventRegistry, eventList);
    return MaterialApp(
      theme: lightTheme,
      home: new Scaffold(
        body: DefaultTabController(
          length: 3,
          child: SafeArea(
              child: new StreamBuilder(
              stream: eventRegistry.eventStream(),
              builder: (BuildContext context, AsyncSnapshot<Map<bool, Map<int, bool>>> event){
                switch (event.connectionState) {
                  case ConnectionState.waiting:
                    return new FullScreenMessage(content: 'Loading...', icon: Icons.work);
                    default:
                      {
                        eventList.updateEventEntries(event.data);
                        return interactiveUIElements;
                    }
                }},
              )
            )
        )
      ),
    );
  }
}

class EventList{
  EventRegistry eventRegistry;
  Map<bool, Map<int,Widget>> eventItems = new Map<bool, Map<int,Widget>>();
  List<int> eventsSortedByCompletionProgress = new List<int>();
  List<int> eventsSortedByCompletionDate = new List<int>();

  EventList(this.eventRegistry);

  void updateEventEntries(Map<bool, Map<int, bool>> newEvents){
  if(newEvents != null){
    for(bool isOpen in newEvents.keys){
      for(int iEvent in newEvents[isOpen].keys){
        //Add or update entries
        newEvents[isOpen][iEvent]
        ?eventItems[isOpen].keys.contains(iEvent)
          ?eventItems[isOpen].remove(iEvent)
          :throw new Exception('Invalid index!')
        :eventItems[isOpen][iEvent] = EventListItem(iEvent: iEvent, eventRegistry: eventRegistry);
      }
    }
  }
    eventsSortedByCompletionProgress = eventRegistry.getEventsOrderedByCompletionProgress(now: DateTime.now());
    eventsSortedByCompletionDate = eventRegistry.getEventsSortedByCompletionDate();
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
  final EventList eventList;
  
  InteractiveUILists(this.eventRegistry, this.eventList);

  @override
  InteractiveUIListsState createState() => InteractiveUIListsState(eventRegistry, eventList);
}

class InteractiveUIListsState extends State<InteractiveUILists>{
  EventRegistry eventRegistry;
  Function updateEventEntries;
  EventList eventList;

  InteractiveUIListsState(this.eventRegistry, this.eventList);

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

  Widget _getFullScreenMessage(BuildContext context){
    print('Tab Controller value');
    print(DefaultTabController.of(context).index);
    if(DefaultTabController.of(context).index == 0) {print('A');return new FullScreenMessage(content: 'Nothing to to right now 😎', icon: Icons.work);}
    else if(DefaultTabController.of(context).index == 1) {print('B');return new FullScreenMessage(content: 'No finished tasks yet\nLet\'s create some to get started 😄', icon: Icons.work);}
    else{print('C');return new FullScreenMessage(content: 'No graphs yet 🙃	', icon: Icons.work);}
  }

  Widget _getScrollableList(BuildContext context, int iItem){
    if(DefaultTabController.of(context).index == 0) {return eventList.eventItems[true][eventList.eventsSortedByCompletionProgress[iItem]];}
    else if(DefaultTabController.of(context).index == 1) {return eventList.eventItems[false][eventList.eventsSortedByCompletionDate[iItem]];}
    else{return new FullScreenMessage(content: 'No graphs yet 🙃	', icon: Icons.work);}
  }

  //Sorts the list of event items by their completion progress
  List<Widget> yieldEventSliversSortedByCompletion(BuildContext context){
    List<Widget> _sliverList = eventList.eventItems.length == 0
    ?[getSliverAppBar(context),
      SliverList(
        delegate: SliverChildListDelegate(
        [_getFullScreenMessage(context)]
        )
      )
    ]
    :[getSliverAppBar(context),
      SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int iItem) {
        return _getScrollableList(context, iItem);
      },
      childCount: eventRegistry.nEvents,
      )
    )];
    return _sliverList;
  }

  @override
  Widget build(BuildContext context){
    return CustomScrollView(slivers: yieldEventSliversSortedByCompletion(context));
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