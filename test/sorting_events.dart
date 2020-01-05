import 'package:flutter_test/flutter_test.dart';
import 'package:tuie/business_logic/event_registry.dart';
import 'package:tuie/ui_elements/event_item_list.dart';
import 'test_utils.dart';

void main() {
  testWidgets('Sorting of Events', (WidgetTester tester) async {
    EventRegistry _registry = new EventRegistry();
    
    for(int i=0; i<5; i++){
      _registry.registerEvent(getTestEvent());
      await tester.pumpAndSettle();
    }

    //Test sorting of list-elements
    //update duration
    _registry.newEventDuration(iEvent: 3, newDuration: Duration(hours: 2));
    _registry.newEventDuration(iEvent: 5, newDuration: Duration(minutes: 15));
    await tester.pumpAndSettle();
    expect(find.byType(OpenEventListItem).evaluate().last.widget.toString(), '5');
    expect(find.byType(OpenEventListItem).evaluate().first.widget.toString(), '3');
    
    //Set shorter update period for testing
    _registry.eventUpdateInterval = Duration(milliseconds: 1);
    _registry.newEventDuration(iEvent: 3, newDuration: Duration(minutes: 15));
    _registry.newEventDuration(iEvent: 5, newDuration: Duration(hours: 2));
    await tester.pump(Duration(milliseconds: 3));
    expect(find.byType(OpenEventListItem).evaluate().last.widget.toString(), '3');
    expect(find.byType(OpenEventListItem).evaluate().first.widget.toString(), '5');
    //Set-back to avoid large overhead
    _registry.eventUpdateInterval = Duration(minutes: 15);
  });
}