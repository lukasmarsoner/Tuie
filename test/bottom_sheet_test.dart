import 'package:flutter_test/flutter_test.dart';
import 'package:tuie/ui_elements/bottom_sheed.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Test Bottom-Sheet', (WidgetTester tester) async {
    MaterialApp _bottomSheet = MaterialApp(home: new Stack(children: <Widget>[new ExpandingBottonSheet()],));

    //Build initial list
    await tester.pumpWidget(_bottomSheet);

    //Tap to open
    await tester.tap(find.byType(ExpandingBottonSheet));
    await tester.pumpAndSettle();
    //Close again
    await tester.tap(find.byType(ExpandingBottonSheet));
    await tester.pumpAndSettle();

    //Fling upwards
    await tester.drag(find.byType(ExpandingBottonSheet), Offset(0, -1000));
    await tester.pumpAndSettle();

    //Fling downwards
    await tester.drag(find.byType(ExpandingBottonSheet), Offset(0, 1000));
    await tester.pumpAndSettle();

    final Offset firstLocation = tester.getBottomLeft(find.byType(ExpandingBottonSheet));
    final TestGesture _gesture = await tester.startGesture(firstLocation);

    //Test sheet folling back to the bottom
    await _gesture.moveBy(Offset(0, 1));
    await tester.pumpAndSettle();
    await _gesture.removePointer();
    await tester.pumpAndSettle();

    await _gesture.moveTo(firstLocation);
    await _gesture.moveBy(Offset(0, 3));
    await tester.pumpAndSettle();
    await _gesture.moveBy(Offset(0, -1));
    await tester.pumpAndSettle();
  });
}