import 'dart:async';

//Event Service-Layer Functions
class EventRegistry{
  //index is used as a unique identifier for events
  //upon initililaziation, all events are indexed once again
  int iEventMax = 0;
  Map<int,Event> _events = new Map<int,Event>();
  var controller = StreamController<Map<int,Event>>();

  //We need this to be a singleton
  //Close controller if no-one is listening
  EventRegistry._internal(){
    controller.onCancel = () => controller.close();
    controller.onListen = () => controller.add(_events);
    }
  static final EventRegistry _eventRegistry = EventRegistry._internal();

  factory EventRegistry() {
    return _eventRegistry;
  }

  void _yieldEvent(int iEvent){
    controller.add({iEvent: event(iEvent)});
  }

  void registerEvent(Event newEvent){
    _events[iEventMax] = newEvent;
    iEventMax += 1;
    _yieldEvent(iEventMax - 1);
    Future.delayed(Duration(microseconds: 100));
  }

  //Update event due date for event with index iEvent
  void newEventDueDate({int iEvent, DateTime newDueDate}){
    if(iEvent != null && iEvent < iEventMax){
      _events[iEvent].due = newDueDate;
      _yieldEvent(iEvent);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Update event duration for event with index iEvent
  void newEventDuration({int iEvent, Duration newDuration}){
    if(iEvent != null && iEvent < iEventMax){
      _events[iEvent].duration = newDuration;
      _yieldEvent(iEvent);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Update event name for event with index iEvent
  void newEventName({int iEvent, String newName}){
    if(iEvent != null && iEvent < iEventMax){
      _events[iEvent].name = newName;
      _yieldEvent(iEvent);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Shift event due date for event with index iEvent
  void shiftEventDueDate({int iEvent, Duration dueDateShift}){
    if(iEvent != null && iEvent < iEventMax){
      _events[iEvent].shiftDueDate(dueDateShift);
      _yieldEvent(iEvent);
    }
    else{
      throw new Exception('Invalid index!');
    }
  }

  //Save getter for events
  Event event(int iEvent) => (iEvent != null && iEvent < iEventMax)?_events[iEvent]:throw new Exception('Invalid index!');

  //Used to trigger updates in the UI
  Stream<Map<int,Event>> eventStream() {
    return controller.stream;
    }
}

class Event{
  String _name;
  DateTime _due;
  Duration _duration;

  //Setters with sanity-checks
  set name(String valIn) => (valIn != null && valIn.length != 0)?_name = valIn.trim():throw new Exception('Invalid name!');
  set due(DateTime valIn) => valIn != null?_due = valIn:throw new Exception('Invalid Date!');
  set duration(Duration valIn) => valIn != null?_duration = valIn:throw new Exception('Invalid Duration!');
  void shiftDueDate(Duration valIn) => valIn != null?_due = _due.add(valIn):throw new Exception('Invalid Duration!');

  //Getters for valiables
  get name => _name;
  get due => _due;
  get duration => _duration;
}