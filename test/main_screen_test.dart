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

    await tester.pumpAndSettle();

    expect(find.byType(ListItem), findsNWidgets(nTestEvents+1));
  });
}