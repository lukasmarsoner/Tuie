
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tuie/business_logic/event_registry.dart';
import 'package:tuie/ui_elements/event_item_list.dart';
import 'package:tuie/ui_elements/sliver_app_bar.dart';
import 'dart:async';

class FullScreenMessage extends StatelessWidget{
  final String content;
  final String imagePath;

  FullScreenMessage({this.content, this.imagePath});

  @override
  Widget build(BuildContext context){
    Padding _text = Padding(
      padding: EdgeInsets.only(top: 20),
      child: Text(content, textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0))
    );

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 1/20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 3/4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[Image.asset(imagePath, height: MediaQuery.of(context).size.width * 1/4, width: MediaQuery.of(context).size.width * 1/4), _text],
            )
        )]
      )
    );
  }
}

class InteractiveUILists extends StatefulWidget {
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

  InteractiveUIListsState({this.eventRegistry});

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

  Widget getTabBar(BuildContext context){
    return TabBar(
      labelColor: Colors.white,
      indicatorColor: Colors.white,
      onTap: (_) => setState(()=> null),
      unselectedLabelColor: Colors.black,
      tabs: [
        new Tab(icon: Container(padding: EdgeInsets.all(6) ,child: new Image.asset('assets/icons/tab_menu/alarm-clock.png')), key: Key('OpenItemsTab'),),
        new Tab(icon: Container(padding: EdgeInsets.all(6) ,child: new Image.asset('assets/icons/tab_menu/tea-cup.png')), key: Key('ClosedItemsTab'),),
        new Tab(icon: Container(padding: EdgeInsets.all(6) ,child: new Image.asset('assets/icons/tab_menu/statistics.png')), key: Key('AnalysisTab'),),
      ],
    );
  }

  List<Widget> _getOpenEventsWidgets(){
    List<Widget> _widgetsRange = new List<Widget>();
    switch(eventsSortedByCompletionProgress.length) {
      case 0:
        _widgetsRange.add(new FullScreenMessage(content: 'Nothing to to right now...', imagePath: 'assets/icons/beach.png'));
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
        _widgetsRange.add(new FullScreenMessage(content: 'No finished tasks yet\nLet\'s create some to get started!', imagePath: 'assets/icons/super.png'));
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
      return <Widget>[new FullScreenMessage(content: 'No graphs yet', imagePath: 'assets/icons/beach.png')];
    } 
  }

  //Sorts the list of event items by their completion progress
  List<Widget> yieldEventSliversSortedByCompletion(BuildContext context){
    List<Widget> _sliverList = [new DynamicTopMenu(tabBar: getTabBar(context)),
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
