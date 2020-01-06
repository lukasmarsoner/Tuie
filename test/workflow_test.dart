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
    
  });
}
