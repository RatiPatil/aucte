// AUCTE — Basic widget smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aucte/app.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AucteApp()),
    );

    // Verify the splash screen shows the app name
    expect(find.text('AUCTE'), findsOneWidget);

    // Complete splash timer cleanly
    await tester.pump(const Duration(seconds: 3));
  });
}
