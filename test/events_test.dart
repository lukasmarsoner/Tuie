import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuie/business_logic/event_registry.dart';
import 'package:tuie/business_logic/event.dart';
import 'test_utils.dart';
import 'dart:async';

EventRegistry _registry = new EventRegistry();
Image campingTent = Image.asset('assets/icons/event_types/camping-tent.png');

void main() {
  test('Event-Class', () async {
    //Test creating a new Event
    Event _event = getTestEvent();

    expect(_event.name, testIO['name']);
    expect(_event.due, testIO['due']);

    _event.shiftDueDate(new Duration(hours: 10));
    DateTime _newDueDate = testIO['due'].add(new Duration(hours: 10));

    expect(_event.due, _newDueDate);

    //Test that minimum duration is 15 minutes
    _event.duration = Duration(seconds: 0);
    expect(_event.duration, Duration(minutes: 15));

    _event.name = 'New Name';
    expect(_event.name, 'New Name');

    _event.due = _newDueDate;
    expect(_event.due, _newDueDate);

    _event.icon = campingTent;
    expect(_event.icon, campingTent);

    //Get completion percentage
    _event.due = DateTime.now();
    _event.shiftDueDate(Duration(minutes: 15));
    _event.duration = Duration(minutes: 15);
    _event.calculateCompletionProgress(DateTime.now());
    expect(_event.completionProgress, 255);

    //Test event already completed
    _event.duration = Duration(minutes: 30);
    _event.calculateCompletionProgress(_event.due);
    expect(_event.completionProgress, 255);


    //Test if all errors for setters are thrown as expected
    expect(() => _event.name = null, throwsException);
    expect(() => _event.due = null, throwsException);
    expect(() => _event.icon = null, throwsException);
    expect(() => _event.completionDate = null, throwsException);
    expect(() => _event.duration = null, throwsException);
    expect(() => _event.shiftDueDate(null), throwsException);
  });

  test('Event-Registry Class', () async {
    Event _event = getTestEvent();

    //Register a new Event
    _registry.registerEvent(_event);
    expect(_registry.getEventName(0), _event.name);
    expect(_registry.getEventDueDate(0), _event.due);
    _event.calculateCompletionProgress(DateTime.now());
    expect(_registry.getEventCompletionProgress(0, now: DateTime.now()), _event.completionProgress);

    //Register some more events for testing
    for(int i=0; i< 10; i++){_registry.registerEvent(getTestEvent());}

    //See if we can yield regular events
    StreamSubscription _eventStreamSubscription = _registry.eventStream().listen((_streamEvent) => expect(_streamEvent.isNotEmpty, true));
    int nEvents = _registry.nEvents;

    //Add a new event to the registry
    DateTime _dueDate = new DateTime.now();
    _registry.registerEvent(getTestEvent());
    _registry.shiftEventDueDate(iEvent: 0, dueDateShift: new Duration(hours: 10));
    _registry.newEventDueDate(iEvent: 0, newDueDate: _dueDate);
    _registry.newEventName(iEvent: 0, newName: 'Test');
    _registry.newEventDuration(iEvent: 0, newDuration: Duration(days: 1));
    _registry.newEventIcon(iEvent: 0, newIcon: campingTent);

    nEvents = _registry.nEvents;
    expect(_registry.getEventCompletionStatus(nEvents-1), false);
    _registry.setEventToCompleted(iEvent: nEvents-1);
    expect(_registry.getEventCompletionStatus(nEvents-1), true);
    _registry.setEventToCompleted(iEvent: nEvents-2);
    expect(_registry.getEventCompletionStatus(nEvents-2), true);
    expect(_registry.getEventCompletionDate(nEvents-1).hour, DateTime.now().hour);
    expect(_registry.getEventsSortedByCompletionDate(), [nEvents-2, nEvents-1]);

    expect(_registry.getEventIcon(0), campingTent);
    expect(_registry.getEventDueDate(0), _dueDate);
    expect(_registry.getEventName(0), 'Test');

    nEvents = _registry.nEvents;
    _registry.deleteEvent(0);
    expect(_registry.nEvents, nEvents - 1);
    
    _registry.updateCompletionProgressDataOnOpenTasks();
    //Set some different durations on events to test sorting
    //Default is 30 minutes
    _registry.newEventDuration(iEvent: 5, newDuration: Duration(hours: 1));
    _registry.newEventDuration(iEvent: 8, newDuration: Duration(hours: 2));
    expect(_registry.getEventCompletionProgress(5), isPositive);

    //Check if sorting by completion progress works
    nEvents = _registry.nEvents;
    List<int> _sortedEventIndexes = _registry.getEventsOrderedByCompletionProgress(now: DateTime.now());
    expect(_sortedEventIndexes[0], 8);
    expect(_sortedEventIndexes[1], 5);

    //Test getting an event from the registry
    _registry.newEventName(iEvent: 5, newName: 'Test');
    expect(_registry.getEvent(5).name, 'Test');

    //Test if all errors for setters are thrown as expected
    expect(() => _registry.newEventDueDate(iEvent: -1), throwsException);
    expect(() => _registry.newEventDuration(iEvent: -1), throwsException);
    expect(() => _registry.newEventName(iEvent: -1), throwsException);
    expect(() => _registry.newEventIcon(iEvent: -1), throwsException);
    expect(() => _registry.setEventToCompleted(iEvent: -1), throwsException);
    expect(() => _registry.updateEventCompletionProgress(iEvent: -1), throwsException);
    expect(() => _registry.shiftEventDueDate(iEvent: -1), throwsException);
    expect(() => _registry.deleteEvent(-1), throwsException);

    //Test if all errors for getters are thrown as expected
    expect(() => _registry.getEventName(-1), throwsException);
    expect(() => _registry.getEventDueDate(-1), throwsException);
    expect(() => _registry.getEventCompletionDate(-1), throwsException);
    expect(() => _registry.getEventIcon(-1), throwsException);
    expect(() => _registry.getEventCompletionStatus(-1), throwsException);
    expect(() => _registry.getEventCompletionProgress(-1), throwsException);


    //Cancle the stream as it is no longer needed
    _eventStreamSubscription.cancel();
  });
}
