import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuie/business_logic/event_registry.dart';
import 'package:tuie/ui_elements/event_item_list.dart';
import 'package:tuie/main.dart';
import 'test_utils.dart';

void main() {
  testWidgets('Render Event List', (WidgetTester tester) async {
    EventRegistry _registry = new EventRegistry();

    //Add n test events to the registry
    _registry.registerEvent(getTestEvent());

    //Build initial list
    await tester.pumpWidget(MyApp(eventRegistry: _registry));

    _registry.deleteEvent(0);

    await tester.pumpAndSettle();
    
    expect(find.text('Nothing to to right now 😎'), findsOneWidget);
    expect(find.text('TuieNo'), findsOneWidget);
    await tester.tap(find.byKey(Key('ClosedItemsTab')));
    await tester.pumpAndSettle();
    expect(find.text('No finished tasks yet\nLet\'s create some to get started 😄'), findsOneWidget);
    await tester.tap(find.byKey(Key('AnalysisTab')));
    await tester.pumpAndSettle();
    expect(find.text('No graphs yet 🙃'), findsOneWidget);
    await tester.tap(find.byKey(Key('OpenItemsTab')));
    await tester.pumpAndSettle();

    for(int i=0; i<4; i++){
      _registry.registerEvent(getTestEvent());
      await tester.pumpAndSettle();
    }

    await tester.pumpAndSettle();
    int nTestEvents = _registry.nEvents;

    expect(find.byType(OpenEventListItem), findsNWidgets(nTestEvents));

    //Add an item
    _registry.registerEvent(getTestEvent());
    nTestEvents += 1;

    await tester.pumpAndSettle();

    expect(find.byType(OpenEventListItem), findsNWidgets(nTestEvents));

    //Update an event
    _registry.newEventName(iEvent: 1, newName: 'New Name');

    await tester.pumpAndSettle();
  });
}