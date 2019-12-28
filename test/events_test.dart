import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuieno/events.dart';
import 'test_utils.dart';

EventRegistry _registry = new EventRegistry();
IconData acUnit = Icons.ac_unit;


void main() {
  test('Basic Event-tests', () async {

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

    _event.icon = acUnit;
    expect(_event.icon, acUnit);

    //Get completion percentage
    _event.due = DateTime.now();
    _event.shiftDueDate(Duration(minutes: 15));
    _event.duration = Duration(minutes: 15);
    expect(_event.getCompletionPercentage(DateTime.now()), 255);

    //Test event already completed
    _event.duration = Duration(minutes: 30);
    expect(_event.getCompletionPercentage(_event.due), 255);
  });

  test('Basic Event-Registry tests', () async {
    Event _event = getTestEvent();

    //Register a new Event
    _registry.registerEvent(_event);
    expect(_registry.getEventName(0), _event.name);
    expect(_registry.getEventDueDate(0), _event.due);
    expect(_registry.getCompletionPercentage(0, now: DateTime.now()), _event.getCompletionPercentage(DateTime.now()));

    //See if we can yield regular events
    _registry.eventStream().listen((_streamEvent) => expect(_streamEvent.isNotEmpty, true));

    //Add a new event to the registry
    DateTime _dueDate = new DateTime.now();
    _registry.registerEvent(getTestEvent());
    _registry.shiftEventDueDate(iEvent: 0, dueDateShift: new Duration(hours: 10));
    _registry.newEventDueDate(iEvent: 0, newDueDate: _dueDate);
    _registry.newEventName(iEvent: 0, newName: 'Test');
    _registry.newEventDuration(iEvent: 0, newDuration: Duration(days: 1));
    _registry.newEventIcon(iEvent: 0, newIcon: acUnit);
    expect(_registry.getEventCompletionStatus(1), false);
    _registry.updateEventCompletionStatus(iEvent: 1, newStatus: true);

    expect(_registry.getEventCompletionStatus(1), true);
    expect(_registry.getEventIcon(0), acUnit);
    expect(_registry.getEventDueDate(0), _dueDate);
    expect(_registry.getEventName(0), 'Test');

    int nEvents = _registry.nEvents;
    _registry.deleteEvent(0);
    expect(_registry.nEvents, nEvents - 1);
  });
}
