import 'package:tuie/business_logic/event_workflow.dart';
import 'package:tuie/business_logic/event_registry.dart';
import 'test_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Event Workflow Tests', () async {
    EventRegistry _registry = new EventRegistry.newRegistry();
    _registry.registerEvent(getTestEvent());

    EventWorkflowHandler _workflowHandler = new EventWorkflowHandler(eventRegistry: _registry);

    _workflowHandler.registerEvent(0);


    DateTime _now = DateTime.now();
    _now = _now.add(Duration(hours: 2));
    BottomMenuState _bottomMenuState = new BottomMenuState(name: 'Test Name', dueDate: _now, duration: Duration(seconds: 10));

    expect(_bottomMenuState.name, 'Test Name');
    expect(_bottomMenuState.dueDate, _now);
    expect(_bottomMenuState.duration, Duration(seconds: 10));
    
  });
}
