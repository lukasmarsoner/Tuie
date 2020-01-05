import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuie/business_logic/event_registry.dart';
import 'package:tuie/ui_elements/event_item_list.dart';
import 'test_utils.dart';

void main() {
  testWidgets('Tapped Navigation', (WidgetTester tester) async {
    EventRegistry _registry = new EventRegistry();

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
    expect(_registry.getEventCompletionStatus(2), false);

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
}