import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuieno/events.dart';
import 'package:tuieno/main.dart';
import 'test_utils.dart';

EventRegistry _registry = new EventRegistry();

void main() {
  testWidgets('Render Event List', (WidgetTester tester) async {
    //Add n test events to the registry
    _registry.registerEvent(getTestEvent());

    //Build initial list
    await tester.pumpWidget(MyApp(eventRegistry: _registry));

    expect(find.text('Loading...'), findsOneWidget);
    await tester.pumpAndSettle();

    _registry.deleteEvent(0);

    await tester.pumpAndSettle();
    
    expect(find.text('Nothing to to right now 😎'), findsOneWidget);
    expect(find.text('TuieNo'), findsOneWidget);

    for(int i=0; i<5; i++){
      _registry.registerEvent(getTestEvent());
      await tester.pumpAndSettle();
    }

    await tester.pumpAndSettle();
    int nTestEvents = _registry.nEvents;

    expect(find.byType(EventListItem), findsNWidgets(nTestEvents));

    //Add an item
    _registry.registerEvent(getTestEvent());
    nTestEvents += 1;

    await tester.pumpAndSettle();

    expect(find.byType(EventListItem), findsNWidgets(nTestEvents));

    //Update an event
    _registry.newEventName(iEvent: 1, newName: 'New Name');

    await tester.pumpAndSettle();

    //Delete an Event
    expect(find.byKey(Key('1')), findsOneWidget);
    await tester.drag(find.byType(Dismissible).first, Offset(1000.0, 0.0));
    await tester.pumpAndSettle();
    nTestEvents -= 1;
    expect(find.byType(EventListItem), findsNWidgets(nTestEvents));

    //Test marking an event as completed
    _registry.newEventName(iEvent: 2, newName: 'New Name');
    expect(find.byKey(Key('2')), findsNWidgets(1));
    expect(_registry.getEventCompletionStatus(1), false);

    await tester.drag(find.byKey(Key('2')), Offset(-1000.0, 0.0));
    await tester.pumpAndSettle();
    expect(_registry.getEventCompletionStatus(2), true);

    //See if we can find the events on the closed-items page
    expect(find.byKey(Key('2')), findsNothing);
    expect(find.byKey(Key('ClosedItemsTab')), findsOneWidget);
    expect(find.byKey(Key('AnalysisTab')), findsOneWidget);
    await tester.tap(find.byKey(Key('ClosedItemsTab')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('2')), findsOneWidget);

    //Back to the original page
    await tester.tap(find.byKey(Key('OpenItemsTab')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('2')), findsNothing);

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
    await tester.pump(Duration(milliseconds: 3));
    expect(find.byType(EventListItem).evaluate().last.widget.toString(), '3');
    expect(find.byType(EventListItem).evaluate().first.widget.toString(), '5');
    //Set-back to avoid large overhead
    _registry.eventUpdateInterval = Duration(minutes: 15);
  });
}