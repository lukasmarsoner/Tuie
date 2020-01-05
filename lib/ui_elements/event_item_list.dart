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
      padding: EdgeInsets.all(12.0),
      child: new Container(
        width: MediaQuery.of(context).size.width,
        height: _widgetHeigt,
        decoration: BoxDecoration(
            boxShadow: [
              new BoxShadow(
                blurRadius: 10.0,
                color: Colors.black.withOpacity(0.8),
                offset: new Offset(5, 5)),
              new BoxShadow(
                blurRadius: 10.0,
                color: Colors.white,
                offset: new Offset(-6, -5))
            ]
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0)
          ),
            alignment: Alignment.center,
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
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10.0)
                ),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: _iconHeight/4),
                child: Icon(Icons.check_circle_outline, size: _iconHeight)
              ),
              secondaryBackground: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10.0)
                ),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: _iconHeight/4),
                child: Icon(Icons.delete_outline, size: _iconHeight)
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
      padding: EdgeInsets.all(12.0),
      child: new Container(
        key: Key(iEvent.toString()),
        width: MediaQuery.of(context).size.width,
        height: _widgetHeigt,
        decoration: BoxDecoration(
            boxShadow: [
              new BoxShadow(
                blurRadius: 10.0,
                color: Colors.black.withOpacity(0.8),
                offset: new Offset(5, 5)),
              new BoxShadow(
                blurRadius: 10.0,
                color: Colors.white,
                offset: new Offset(-6, -5))
            ]
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0)
          ),
            alignment: Alignment.center,
            child: Container(
                alignment: Alignment.center,
                child: ListTile(
                  leading: Icon(eventRegistry.getEventIcon(iEvent), size: _widgetHeigt / 3),
                  title: Text(eventRegistry.getEventName(iEvent))
                )
              ),
            )
        ),
    );
  }
}
