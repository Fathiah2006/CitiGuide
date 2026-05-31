// Smoke test: the app boots to the splash screen and shows the wordmark.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:citi_guide/app/app.dart';
import 'package:citi_guide/services/prefs_service.dart';

void main() {
  testWidgets('App boots and shows the CitiGuide splash', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PrefsService.create();

    await tester.pumpWidget(CitiGuideApp(prefs: prefs));
    await tester.pump();

    expect(find.text('Discover your city, like a local'), findsOneWidget);

    // drain the splash auto-advance timer before the test ends
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();
  });

  testWidgets('Logged-out splash routes to login', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PrefsService.create();

    await tester.pumpWidget(CitiGuideApp(prefs: prefs));
    // advance past the 2.2s splash delay
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
