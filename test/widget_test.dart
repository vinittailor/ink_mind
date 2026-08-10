import 'package:flutter_test/flutter_test.dart';
import 'package:ink_mind/core/di/injection_container.dart';
import 'package:ink_mind/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initDependencies();
  });

  testWidgets('App smoke test — launches ChatPage without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const InkMindApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('InkMind'), findsOneWidget);
  });
}
