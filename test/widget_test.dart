
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskflow/providers/task_provider.dart';
import 'package:taskflow/providers/theme_provider.dart';
import 'package:taskflow/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('TaskFlow app loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => TaskProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => ThemeProvider(),
          ),
        ],
        child: const TaskFlowApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('TaskFlow'), findsOneWidget);
  });
}
