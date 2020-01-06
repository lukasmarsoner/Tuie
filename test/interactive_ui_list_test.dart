import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:tuie/business_logic/event_registry.dart';
import 'package:tuie/ui_elements/event_item_list.dart';
import 'test_utils.dart';
import 'package:tuie/main.dart';

void main() {
  testWidgets('Render Event List', (WidgetTester tester) async {
    EventRegistry registry = new EventRegistry.newRegistry();

    //Build initial list
    await tester.pumpWidget(new MyApp(eventRegistry: registry));

    //Add n test events to the registry
    registry.registerEvent(getTestEvent());

    registry.deleteEvent(0);

    await tester.pumpAndSettle();
    
    expect(find.text('Nothing to to right now...'), findsOneWidget);
    await tester.tap(find.byKey(Key('ClosedItemsTab')));
    await tester.pumpAndSettle();
    expect(find.text('No finished tasks yet\nLet\'s create some to get started!'), findsOneWidget);
    await tester.tap(find.byKey(Key('AnalysisTab')));
    await tester.pumpAndSettle();
    expect(find.text('No graphs yet'), findsOneWidget);
    await tester.tap(find.byKey(Key('OpenItemsTab')));
    await tester.pumpAndSettle();

    for(int i=0; i<3; i++){
      registry.registerEvent(getTestEvent());
      await tester.pumpAndSettle();
    }

    await tester.pumpAndSettle();
    int nTestEvents = registry.nEvents;

    expect(find.byType(OpenEventListItem), findsNWidgets(nTestEvents));

    //Add an item
    registry.registerEvent(getTestEvent());
    nTestEvents += 1;

    await tester.pumpAndSettle();

    expect(find.byType(OpenEventListItem), findsNWidgets(nTestEvents));

    //Update an event
    registry.newEventName(iEvent: 1, newName: 'New Name');

    await tester.pumpAndSettle();
    expect(find.text('New Name'), findsOneWidget);

  });

  testWidgets('Interact with events + tapped navigation', (WidgetTester tester) async {
    EventRegistry _registry = new EventRegistry.newRegistry();

    await tester.pumpWidget(new MyApp(eventRegistry: _registry));

    for(int i=0; i<5; i++){
      _registry.registerEvent(getTestEvent());
      await tester.pumpAndSettle();
    }

    int nTestEvents = _registry.nEvents;

    //Delete an Event
    expect(find.byKey(Key('1')), findsOneWidget);
    await tester.drag(find.byType(Dismissible).first, Offset(-1000.0, 0.0));
    await tester.pumpAndSettle();
    nTestEvents -= 1;
    expect(find.byType(OpenEventListItem), findsNWidgets(nTestEvents));

    //Test marking an event as completed
    _registry.newEventName(iEvent: 2, newName: 'New Name');
    expect(find.byKey(Key('2')), findsNWidgets(1));
    expect(_registry.getEventCompletionStatus(1), false);

    await tester.drag(find.byKey(Key('2')), Offset(1000.0, 0.0));
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

  });

  testWidgets('Sort events', (WidgetTester tester) async {
    EventRegistry _registry = new EventRegistry.newRegistry();

    await tester.pumpWidget(new MyApp(eventRegistry: _registry));

    for(int i=0; i<4; i++){
      _registry.registerEvent(getTestEvent());
      await tester.pumpAndSettle();
    }
    //Test sorting of list-elements
    //update duration
    _registry.newEventDuration(iEvent: 1, newDuration: Duration(hours: 2));
    _registry.newEventDuration(iEvent: 3, newDuration: Duration(minutes: 15));
    await tester.pumpAndSettle();
    expect(find.byType(OpenEventListItem).evaluate().last.widget.toString(), '3');
    expect(find.byType(OpenEventListItem).evaluate().first.widget.toString(), '1');
    
    //Set shorter update period for testing
    _registry.eventUpdateInterval = Duration(milliseconds: 1);
    _registry.newEventDuration(iEvent: 1, newDuration: Duration(minutes: 15));
    _registry.newEventDuration(iEvent: 3, newDuration: Duration(hours: 2));
    await tester.pump(Duration(milliseconds: 3));
    expect(find.byType(OpenEventListItem).evaluate().last.widget.toString(), '1');
    expect(find.byType(OpenEventListItem).evaluate().first.widget.toString(), '3');
    //Set-back to avoid large overhead
    _registry.eventUpdateInterval = Duration(minutes: 15);
  });
}