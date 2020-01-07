import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tuie/business_logic/event_registry.dart';

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

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: new Container(
        width: MediaQuery.of(context).size.width,
        height: _widgetHeigt,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
            alignment: Alignment.center,
            child: Dismissible(
              key: Key(iEvent.toString()),
              onDismissed: (direction) {
                direction == DismissDirection.startToEnd
                  ?eventRegistry.setEventToCompleted(iEvent: iEvent)
                  :eventRegistry.deleteEvent(iEvent);
                },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(child: eventRegistry.getEventIcon(iEvent), height: _widgetHeigt / 3, width: _widgetHeigt / 3),
                  Text(eventRegistry.getEventName(iEvent))
                ]
              ),
              background: Container(
                decoration: BoxDecoration(
                  color: Color(0xff25ae88),
                ),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: _iconHeight/4),
                child: Image.asset('assets/icons/success.png', height: _iconHeight, width: _iconHeight),
              ),
              secondaryBackground: Container(
                decoration: BoxDecoration(
                  color: Color(0xffcc5d48),
                ),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: _iconHeight/4),
                child: Image.asset('assets/icons/trash.png', height: _iconHeight, width: _iconHeight)
              ),
            )
          ),
        ),
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

    return Padding(
      padding: EdgeInsets.all(8),
      child: new Container(
        key: Key(iEvent.toString()),
        width: MediaQuery.of(context).size.width,
        height: _widgetHeigt,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(child: eventRegistry.getEventIcon(iEvent), height: _widgetHeigt / 3, width: _widgetHeigt / 3),
            Text(eventRegistry.getEventName(iEvent))
          ]
        ),
        ),
    );
  }
}
