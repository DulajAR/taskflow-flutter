import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:taskflow/main.dart';
import 'package:taskflow/providers/task_provider.dart';

void main() {
  testWidgets('TaskFlow app loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TaskProvider(),
        child: const TaskFlowApp(),
      ),
    );

    await tester.pump();

    expect(find.text('TaskFlow'), findsOneWidget);
  });
}