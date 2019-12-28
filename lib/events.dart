import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

//Event Service-Layer Functions
class EventRegistry{
  //index is used as a unique identifier for events
  //upon initililaziation, all events are indexed once again
  int iEventMax = 0;
  //The interval for updating events is 15 minutes - this might be changable later
  Duration _eventUpdateInterval = Duration(minutes: 15);
  Timer _eventTicker;
  Map<int,Event> _openEvents = new Map<int,Event>();
  Map<int,Event> _closedEvents = new Map<int,Event>();
  //Boolean defines if entry should be deleted (true => delete entry)
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
    controller.onCancel = () {
      _stopEventTicker();
      controller.close();
    };
    controller.onListen = (){
      _startEventTicker();
      controller.add(getOutputMap(_openEvents.keys, false));
      };
    }

  //Regularly update all events so the due-dates are updated in the UI
  void _tick(_){
    updateCompletionProgressDataOnOpenTasks(now: DateTime.now());
    controller.add(getOutputMap(_openEvents.keys, false));
  }

  _startEventTicker(){
    _eventTicker = Timer.periodic(_eventUpdateInterval, _tick);
  }

  _stopEventTicker(){
    if(_eventTicker != null){
      _eventTicker.cancel();
      _eventTicker = null;
    }
  }

  static final EventRegistry _eventRegistry = EventRegistry._internal();

  factory EventRegistry() {
    return _eventRegistry;
  }

  bool _isEventIndexSave(int iEvent) => (iEvent != null && _openEvents.keys.contains(iEvent));

  void _yieldEvent(int iEvent, bool delete){
    controller.add({iEvent: delete});
  }

  void registerEvent(Event newEvent){
    _openEvents[iEventMax] = newEvent;
    iEventMax += 1;
    _yieldEvent(iEventMax - 1, false);
    Future.delayed(Duration(microseconds: 100));
  }

  //Update event due date for event with index iEvent
  void newEventDueDate({int iEvent, DateTime newDueDate, DateTime now}){
    if(_isEventIndexSave(iEvent)){
      _openEvents[iEvent].due = newDueDate;
      updateEventCompletionProgress(iEvent: iEvent, now: now);
      _yieldEvent(iEvent, false);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Update event duration for event with index iEvent
  void newEventDuration({int iEvent, Duration newDuration, DateTime now}){
    if(_isEventIndexSave(iEvent)){
      _openEvents[iEvent].duration = newDuration;
      updateEventCompletionProgress(iEvent: iEvent, now: now);
      _yieldEvent(iEvent, false);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Update event name for event with index iEvent
  void newEventName({int iEvent, String newName}){
    if(_isEventIndexSave(iEvent)){
      _openEvents[iEvent].name = newName;
      _yieldEvent(iEvent, false);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Update event icon for event with index iEvent
  void newEventIcon({int iEvent, IconData newIcon}){
    if(_isEventIndexSave(iEvent)){
      _openEvents[iEvent].icon = newIcon;
      _yieldEvent(iEvent, false);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Update event completion-status for event with index iEvent
  void setEventToCompleted({int iEvent}){
    if(_isEventIndexSave(iEvent)){
      _closedEvents[iEvent] = _openEvents[iEvent];
      deleteEvent(iEvent);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Trigger update to an event's completion progress
  void updateEventCompletionProgress({int iEvent, DateTime now}){
    if(now == null){now=DateTime.now();}
    if(_isEventIndexSave(iEvent)){
      _openEvents[iEvent].calculateCompletionProgress(now);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Shift event due date for event with index iEvent
  void shiftEventDueDate({int iEvent, Duration dueDateShift, DateTime now}){
    if(_isEventIndexSave(iEvent)){
      _openEvents[iEvent].shiftDueDate(dueDateShift);
      updateEventCompletionProgress(iEvent: iEvent, now: now);
      _yieldEvent(iEvent, false);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Save getter for events
  String getEventName(int iEvent) => _isEventIndexSave(iEvent)?_openEvents[iEvent].name:throw new Exception('Invalid index!');
  DateTime getEventDueDate(int iEvent) => _isEventIndexSave(iEvent)?_openEvents[iEvent].due:throw new Exception('Invalid index!');
  IconData getEventIcon(int iEvent) => _isEventIndexSave(iEvent)?_openEvents[iEvent].icon:throw new Exception('Invalid index!');
  void deleteEvent(int iEvent){
    if(_isEventIndexSave(iEvent)){
      _openEvents.remove(iEvent);
      _yieldEvent(iEvent, true);
      }
      else{
        throw new Exception('Invalid index!');
        }
  }
  bool getEventCompletionStatus(int iEvent) => (iEvent != null && iEvent < iEventMax)?_closedEvents.keys.contains(iEvent)?true:false:throw new Exception('Invalid index!');

  int getEventCompletionProgress(int iEvent, {DateTime now}){
      if(now == null){now=DateTime.now();}
      if(_openEvents[iEvent].completionProgress == null){
        _isEventIndexSave(iEvent)?_openEvents[iEvent].calculateCompletionProgress(now):throw new Exception('Invalid index!');
        }
      return _openEvents[iEvent].completionProgress;
    }
  
  //List of events as ordered by completion progress
  List<int> getEventsOrderedByCompletionProgress({DateTime now}){
    if(now == null){now=DateTime.now();}
    updateCompletionProgressDataOnOpenTasks(now: now);
    //Sort events by completion progress
    List<int> _sortedEventIndexes = _openEvents.keys.toList();
    _sortedEventIndexes.sort((i,j) => _openEvents[i]._completionProgress.compareTo(_openEvents[j]._completionProgress));
    return _sortedEventIndexes.reversed.toList();
  }
  
  //Update completion progress on all open tasks
  void updateCompletionProgressDataOnOpenTasks({DateTime now}){
    if(now == null){now=DateTime.now();}
    _openEvents.values.forEach((event) => event.calculateCompletionProgress(now));
  }

  //Only for testing
  get nEvents => _openEvents.keys.length;
  set eventUpdateInterval(Duration valIn) => valIn != null?_eventUpdateInterval=_eventUpdateInterval:throw new Exception('Invalid duration!');

  //Used to trigger updates in the UI
  Stream<Map<int, bool>> eventStream() {
    return controller.stream;
    }
}

class Event{
  String _name;
  DateTime _due;
  Duration _duration;
  IconData _icon;
  int _completionProgress;

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

  //Calculate the remaining time as a fraction of 255 to be used as an alpha-values
  void calculateCompletionProgress(DateTime now){
    if(now==null){now = DateTime.now();}
    int _remaintingTime = _due.subtract(duration).difference(now).inMinutes;
    _completionProgress = _remaintingTime < 0
      //Set to 255 if the event is over-due
      ?255
      :(255 - atan(_due.subtract(duration).difference(now).inMinutes / duration.inMinutes) / (pi / 2) * 255).round();
    }

  //Getters for valiables
  get name => _name;
  get due => _due;
  get duration => _duration;
  get icon => _icon;
  get completionProgress => _completionProgress;
}