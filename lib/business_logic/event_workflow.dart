import 'package:tuie/business_logic/event.dart';
import 'package:tuie/business_logic/event_registry.dart';
import 'dart:async';

//Used to transmitt data to the sheet so we don't expose the events themselves
class BottomMenuState{
  String name;
  DateTime dueDate;
  Duration duration;

  BottomMenuState({this.dueDate, this.duration, this.name});

}

//This module keeps track of temporary data for new events
//and events being edited before they are comitted to the registry
class EventWorkflowHandler{
  EventRegistry eventRegistry;
  Event _workflowEvent;
  StreamController<Map<int, bool>> eventController = StreamController();
  int iEvent;

  EventWorkflowHandler({this.eventRegistry, this.iEvent});

  void registerEvent(int iEvent){
    //Check if it is an open event - error is thrown by the method
    eventRegistry.isOpenEvent(iEvent);

    //Copy data from item to be edited
    _workflowEvent = eventRegistry.getEvent(iEvent);
  }

}