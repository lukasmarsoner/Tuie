import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

//Event Service-Layer Functions
class EventRegistry{
  //index is used as a unique identifier for events
  //upon initililaziation, all events are indexed once again
  int iEventMax = 0;
  Map<int,Event> _events = new Map<int,Event>();
  Map<int,Event> _completedEvents = new Map<int,Event>();
  //Bool defines if entry should be deleted
  var controller = StreamController<Map<int, bool>>();

  Map<int, bool> getOutputMap(Iterable<int> _keys, bool delete){
    Map<int, bool> _otputMap = new Map<int, bool>();
    for(int _key in _keys){
      _otputMap[_key] = delete;
    }
    return _otputMap;
  }

  //We need this to be a singleton
  //Close controller if no-one is listening
  EventRegistry._internal(){
    controller.onCancel = () => controller.close();
    controller.onListen = () => controller.add(getOutputMap(_events.keys, false));
    }
  static final EventRegistry _eventRegistry = EventRegistry._internal();

  factory EventRegistry() {
    return _eventRegistry;
  }

  bool saveEventIndex(int iEvent) => (iEvent != null && _events.keys.contains(iEvent));

  void _yieldEvent(int iEvent, bool delete){
    controller.add({iEvent: delete});
  }

  void registerEvent(Event newEvent){
    _events[iEventMax] = newEvent;
    iEventMax += 1;
    _yieldEvent(iEventMax - 1, false);
    Future.delayed(Duration(microseconds: 100));
  }

  //Update event due date for event with index iEvent
  void newEventDueDate({int iEvent, DateTime newDueDate}){
    if(saveEventIndex(iEvent)){
      _events[iEvent].due = newDueDate;
      _yieldEvent(iEvent, false);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Update event duration for event with index iEvent
  void newEventDuration({int iEvent, Duration newDuration}){
    if(saveEventIndex(iEvent)){
      _events[iEvent].duration = newDuration;
      _yieldEvent(iEvent, false);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Update event name for event with index iEvent
  void newEventName({int iEvent, String newName}){
    if(saveEventIndex(iEvent)){
      _events[iEvent].name = newName;
      _yieldEvent(iEvent, false);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Update event icon for event with index iEvent
  void newEventIcon({int iEvent, IconData newIcon}){
    if(saveEventIndex(iEvent)){
      _events[iEvent].icon = newIcon;
      _yieldEvent(iEvent, false);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Update event completion-status for event with index iEvent
  void updateEventCompletionStatus({int iEvent, bool newStatus}){
    if(saveEventIndex(iEvent)){
      _completedEvents[iEvent] = _events[iEvent];
      deleteEvent(iEvent);
      _yieldEvent(iEvent, true);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Shift event due date for event with index iEvent
  void shiftEventDueDate({int iEvent, Duration dueDateShift}){
    if(saveEventIndex(iEvent)){
      _events[iEvent].shiftDueDate(dueDateShift);
      _yieldEvent(iEvent, false);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Save getter for events
  String getEventName(int iEvent) => saveEventIndex(iEvent)?_events[iEvent].name:throw new Exception('Invalid index!');
  DateTime getEventDueDate(int iEvent) => saveEventIndex(iEvent)?_events[iEvent].due:throw new Exception('Invalid index!');
  IconData getEventIcon(int iEvent) => saveEventIndex(iEvent)?_events[iEvent].icon:throw new Exception('Invalid index!');
  void deleteEvent(int iEvent){
    if(saveEventIndex(iEvent)){
      _events.remove(iEvent);
      _yieldEvent(iEvent, true);
      }
      else{
        throw new Exception('Invalid index!');
        }
  }
  bool getEventCompletionStatus(int iEvent) => (iEvent != null && iEvent < iEventMax)?_completedEvents.keys.contains(iEvent)?true:false:throw new Exception('Invalid index!');
  int getCompletionPercentage(int iEvent, {DateTime now}){
      if(now == null){now=DateTime.now();}
      return saveEventIndex(iEvent)?_events[iEvent].getCompletionPercentage(now):throw new Exception('Invalid index!');
    }
  //Only for testing
  get nEvents => _events.keys.length;

  //Used to trigger updates in the UI
  Stream<Map<int, bool>> eventStream() {
    return controller.stream;
    }

  //Used to trigger regular updates of the remaining time on an event
}

class Event{
  String _name;
  DateTime _due;
  Duration _duration;
  IconData _icon;

  //Setters with sanity-checks
  set name(String valIn) => (valIn != null && valIn.length != 0)?_name = valIn.trim():throw new Exception('Invalid name!');
  set due(DateTime valIn) => valIn != null?_due = valIn:throw new Exception('Invalid Date!');
  set icon(IconData valIn) => valIn != null?_icon = valIn:throw new Exception('Invalid Icon!');
  //We only support events with durations of at least 15 minuts
  set duration(Duration valIn){
    if(valIn != null){
      if(valIn.inMinutes<15){valIn=Duration(minutes: 15);}
      _duration = valIn;
    }
    else{throw new Exception('Invalid Duration!');}
  }
  void shiftDueDate(Duration valIn) => valIn != null?_due = _due.add(valIn):throw new Exception('Invalid Duration!');

  //Getters for valiables
  get name => _name;
  get due => _due;
  get duration => _duration;
  get icon => _icon;
  //Return the remaining time as a fraction of 255 to be used as an alpha-values
  int getCompletionPercentage(DateTime now){
    if(now==null){now = DateTime.now();}
    int _remaintingTime = _due.subtract(duration).difference(now).inMinutes;
    return _remaintingTime < 0
      //Return 255 if the event is over-due
      ?255
      :(255 - atan(_due.subtract(duration).difference(now).inMinutes / duration.inMinutes) / (pi / 2) * 255).round();
    }
}