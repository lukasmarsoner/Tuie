import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuieno/events.dart';
import 'package:tuieno/main.dart';
import 'test_utils.dart';

EventRegistry _registry = new EventRegistry();

void main() {
  testWidgets('Render Event List', (WidgetTester tester) async {
    //Add n test events to the registry
    for(int i=0; i<5; i++){
      _registry.registerEvent(getTestEvent());
    }

    int nTestEvents = _registry.nEvents;

    //Build initial list
    await tester.pumpWidget(MyApp(eventRegistry: _registry));

    expect(find.text('Loading...'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(EventListItem), findsNWidgets(nTestEvents));

    //Add an item
    _registry.registerEvent(getTestEvent());
    nTestEvents += 1;

    await tester.pumpAndSettle();

    expect(find.byType(EventListItem), findsNWidgets(nTestEvents));

    //Update an event
    _registry.newEventName(iEvent: 0, newName: 'New Name');

    await tester.pumpAndSettle();

    expect(find.text('New Name'), findsNWidgets(1));

    //Delete an Event
    await tester.drag(find.text('New Name'), Offset(1000.0, 0.0));
    await tester.pumpAndSettle();
    nTestEvents -= 1;
    expect(find.byType(EventListItem), findsNWidgets(nTestEvents));

    //Test marking an event as completed
    _registry.newEventName(iEvent: 1, newName: 'New Name');
    expect(find.byKey(Key('1')), findsNWidgets(1));
    expect(_registry.getEventCompletionStatus(1), false);

    await tester.drag(find.byKey(Key('1')), Offset(-1000.0, 0.0));
    await tester.pumpAndSettle();
    expect(_registry.getEventCompletionStatus(1), true);

    //Test sorting of list-elements
    //update duration
    _registry.newEventDuration(iEvent: 3, newDuration: Duration(hours: 2));
    _registry.newEventDuration(iEvent: 5, newDuration: Duration(minutes: 15));
    await tester.pumpAndSettle();
    expect(find.byType(EventListItem).evaluate().last.widget.toString(), '5');
    expect(find.byType(EventListItem).evaluate().first.widget.toString(), '3');
    
    //Set shorter update period for testing
    _registry.eventUpdateInterval = Duration(milliseconds: 1);
    _registry.newEventDuration(iEvent: 3, newDuration: Duration(minutes: 15));
    _registry.newEventDuration(iEvent: 5, newDuration: Duration(hours: 2));
    //Future.delayed(new Duration(microseconds: 3));
    //expect(find.byType(EventListItem).evaluate().last.widget.toString(), '3');
    //expect(find.byType(EventListItem).evaluate().first.widget.toString(), '5');
    //Set-back to avoid large overhead
    _registry.eventUpdateInterval = Duration(minutes: 15);
  });
}