import 'package:flutter_test/flutter_test.dart';
import 'package:tuieno/events.dart';
import 'test_utils.dart';

EventRegistry _registry = new EventRegistry();


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

    //Get completion percentage
    _event.due = DateTime.now();
    _event.shiftDueDate(Duration(minutes: 15));
    _event.duration = Duration(minutes: 15);
    expect(_event.getCompletionPercentage(now: DateTime.now()), 255);

    //Test event already completed
    _event.duration = Duration(minutes: 30);
    expect(_event.getCompletionPercentage(now: _event.due), 255);
  });

  test('Basic Event-Registry tests', () async {
    Event _event = getTestEvent();

    //Register a new Event
    _registry.registerEvent(_event);
    expect(_registry.getEventName(0), _event.name);
    expect(_registry.getEventDueDate(0), _event.due);
    expect(_registry.getCompletionPercentage(0, now: DateTime.now()), _event.getCompletionPercentage(now: DateTime.now()));

    //See if we can yield regular events
    _registry.eventStream().listen((_streamEvent) => expect(_streamEvent.isNotEmpty, true));

    //Add a new event to the registry
    _registry.registerEvent(getTestEvent());
    _registry.newEventDueDate(iEvent: 0, newDueDate: new DateTime.now());
    _registry.shiftEventDueDate(iEvent: 0, dueDateShift: new Duration(hours: 10));
    _registry.newEventName(iEvent: 0, newName: 'Test');
    _registry.newEventDuration(iEvent: 0, newDuration: Duration(days: 1));
  });
}
