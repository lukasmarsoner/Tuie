import 'dart:async';
import 'event.dart';
import 'package:flutter/material.dart';

//Event Service-Layer Functions
class EventRegistry{
  //index is used as a unique identifier for events
  //upon initililaziation, all events are indexed once again
  int _iEventMax = 0;
  //The interval for updating events is 15 minutes - this might be changable later
  Duration _eventUpdateInterval = Duration(minutes: 15);
  Timer _eventTicker;
  Map<int,Event> _openEvents = new Map<int,Event>();
  Map<int,Event> _closedEvents = new Map<int,Event>();
  //First Boolean defines if open or closed events are send
  //Second Boolean defines if entry should be deleted (true => delete entry)
  StreamController<Map<bool,Map<int, bool>>> eventController = StreamController();

  Map<bool, Map<int, bool>> getOutputMap({Iterable<int> keysOpen, Iterable<int> keysClosed, bool deleteOpen}){
    Map<bool, Map<int, bool>> _otputMap = new Map<bool, Map<int, bool>>();

    //Set open data
    _otputMap[true] = new Map<int, bool>();
    for(int _key in keysOpen){
      _otputMap[true][_key] = deleteOpen;
    }

    //Set closed data
    _otputMap[false] = new Map<int, bool>();
    for(int _key in keysClosed){
      _otputMap[false][_key] = null;
    }

    return _otputMap;
  }
  //We need this to be a singleton
  //Close controller if no-one is listening
  EventRegistry._internal(){
    eventController.onCancel = () {
      _stopEventTicker();
      eventController.close();
    };
    eventController.onListen = (){
      _startEventTicker();
      eventController.add(getOutputMap(keysOpen: _openEvents.keys, keysClosed: _closedEvents.keys, deleteOpen: false));
      };
    }

  //For testing
  EventRegistry.newRegistry(){EventRegistry._internal();}

  //Regularly update all events so the due-dates are updated in the UI
  void _tick(_){
    updateCompletionProgressDataOnOpenTasks(now: DateTime.now());
    eventController.add(getOutputMap(keysOpen: _openEvents.keys, keysClosed: _closedEvents.keys, deleteOpen: false));
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

  bool isOpenEvent(int iEvent) => (iEvent != null && _openEvents.keys.contains(iEvent));
  bool isClosedEvent(int iEvent) => (iEvent != null && _closedEvents.keys.contains(iEvent));

  void _yieldEvent(bool open, int iEvent, bool delete){
    eventController.add({open: {iEvent: delete}});
  }

  void registerEvent(Event newEvent){
    _openEvents[iEventMax] = newEvent;
    _iEventMax += 1;
    _yieldEvent(true, iEventMax - 1, false);
  }

  //Update event due date for event with index iEvent
  void newEventDueDate({int iEvent, DateTime newDueDate, DateTime now}){
    if(isOpenEvent(iEvent)){
      _openEvents[iEvent].due = newDueDate;
      updateEventCompletionProgress(iEvent: iEvent, now: now);
      _yieldEvent(true, iEvent, false);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Update event duration for event with index iEvent
  void newEventDuration({int iEvent, Duration newDuration, DateTime now}){
    if(isOpenEvent(iEvent)){
      _openEvents[iEvent].duration = newDuration;
      updateEventCompletionProgress(iEvent: iEvent, now: now);
      _yieldEvent(true, iEvent, false);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Update event name for event with index iEvent
  void newEventName({int iEvent, String newName}){
    if(isOpenEvent(iEvent)){
      _openEvents[iEvent].name = newName;
      _yieldEvent(true, iEvent, false);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Update event icon for event with index iEvent
  void newEventIcon({int iEvent, IconData newIcon}){
    if(isOpenEvent(iEvent)){
      _openEvents[iEvent].icon = newIcon;
      _yieldEvent(true, iEvent, false);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Update event completion-status for event with index iEvent
  void setEventToCompleted({int iEvent}){
    if(isOpenEvent(iEvent)){
      _closedEvents[iEvent] = _openEvents[iEvent];
      deleteEvent(iEvent);
      _closedEvents[iEvent].completionDate = DateTime.now();
      _yieldEvent(false, iEvent, false);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Trigger update to an event's completion progress
  void updateEventCompletionProgress({int iEvent, DateTime now}){
    if(now == null){now=DateTime.now();}
    if(isOpenEvent(iEvent)){
      _openEvents[iEvent].calculateCompletionProgress(now);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Shift event due date for event with index iEvent
  void shiftEventDueDate({int iEvent, Duration dueDateShift, DateTime now}){
    if(isOpenEvent(iEvent)){
      _openEvents[iEvent].shiftDueDate(dueDateShift);
      updateEventCompletionProgress(iEvent: iEvent, now: now);
      _yieldEvent(true, iEvent, false);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  get iEventMax => _iEventMax;

  Event getEvent(int iEvent) => isOpenEvent(iEvent)?_openEvents[iEvent]:throw new Exception('Invalid index!');

  //Save getter for events
  String getEventName(int iEvent) => isOpenEvent(iEvent)
    ?_openEvents[iEvent].name
    :isClosedEvent(iEvent)
      ?_closedEvents[iEvent].name
      :throw new Exception('Invalid index!');
  DateTime getEventDueDate(int iEvent) => isOpenEvent(iEvent)
    ?_openEvents[iEvent].due
    :throw new Exception('Invalid index!');
  DateTime getEventCompletionDate(int iEvent) => isClosedEvent(iEvent)
    ?_closedEvents[iEvent].completionDate
    :throw new Exception('Invalid index!');
  IconData getEventIcon(int iEvent) => isOpenEvent(iEvent)
    ?_openEvents[iEvent].icon
    :isClosedEvent(iEvent)
      ?_closedEvents[iEvent].icon
      :throw new Exception('Invalid index!');

  void deleteEvent(int iEvent){
    if(isOpenEvent(iEvent)){
      _openEvents.remove(iEvent);
      _yieldEvent(true, iEvent, true);
      }
      else{
        throw new Exception('Invalid index!');
        }
  }

  bool getEventCompletionStatus(int iEvent) => (iEvent != null && iEvent < iEventMax)
    ?isClosedEvent(iEvent)
      ?true
      :isOpenEvent(iEvent)
        ?false
        :throw new Exception('Invalid index!')
      :throw new Exception('Invalid index!');

  int getEventCompletionProgress(int iEvent, {DateTime now}){
      if(now == null){now=DateTime.now();}
      isOpenEvent(iEvent)
          ?_openEvents[iEvent].calculateCompletionProgress(now)
          :throw new Exception('Invalid index!');
      return _openEvents[iEvent].completionProgress;
    }
  
  //List of events as ordered by completion progress
  List<int> getEventsOrderedByCompletionProgress({DateTime now}){
    if(now == null){now=DateTime.now();}
    updateCompletionProgressDataOnOpenTasks(now: now);
    //Sort events by completion progress
    List<int> _sortedEventIndexes = _openEvents.keys.toList();
    _sortedEventIndexes.sort((i,j) => _openEvents[i].completionProgress.compareTo(_openEvents[j].completionProgress));
    return _sortedEventIndexes.reversed.toList();
  }

  //List of events as ordered by completion date
  List<int> getEventsSortedByCompletionDate(){
    List<int> _sortedEventIndexes = _closedEvents.keys.toList();
    _sortedEventIndexes.sort((i,j) => _closedEvents[i].completionDate.compareTo(_closedEvents[j].completionDate));
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
  Stream<Map<bool, Map<int, bool>>> eventStream() {
    return eventController.stream;
    }
}
