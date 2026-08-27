import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:frontend/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Hive.init('./test_hive');
    await Hive.openBox('auth');
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  testWidgets('NexusApp renders cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: NexusApp(),
      ),
    );

    // Verify app renders without crashing
    expect(find.byType(NexusApp), findsOneWidget);
  });
}
