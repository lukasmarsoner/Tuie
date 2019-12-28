import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuieno/events.dart';
import 'package:tuieno/main.dart';
import 'test_utils.dart';

EventRegistry _registry = new EventRegistry();

void main() {
  testWidgets('Render Event List', (WidgetTester tester) async {
    //Add n test events to the registry
    int nTestEvents = 5;

    for(int i=0; i<nTestEvents; i++){
      _registry.registerEvent(getTestEvent());
    }

    //Build initial list
    await tester.pumpWidget(MyApp(eventRegistry: _registry));

    expect(find.text('Loading...'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(ListItem), findsNWidgets(nTestEvents));

    //Add an item
    _registry.registerEvent(getTestEvent());
    nTestEvents += 1;

    await tester.pumpAndSettle();

    expect(find.byType(ListItem), findsNWidgets(nTestEvents));

    //Update an event
    _registry.newEventName(iEvent: 0, newName: 'New Name');

    await tester.pumpAndSettle();

    expect(find.text('New Name'), findsNWidgets(1));

    //Dismiss an Event
    await tester.drag(find.text('New Name'), Offset(1000.0, 0.0));
    await tester.pumpAndSettle();
    nTestEvents -= 1;
    expect(find.byType(ListItem), findsNWidgets(nTestEvents));

    //Test marking an event as completed
    _registry.newEventName(iEvent: 1, newName: 'New Name');
    expect(find.byKey(Key('1')), findsNWidgets(1));
    expect(_registry.getEventCompletionStatus(1), false);

    await tester.drag(find.byKey(Key('1')), Offset(-1000.0, 0.0));
    await tester.pumpAndSettle();
    expect(_registry.getEventCompletionStatus(1), true);
  });
}