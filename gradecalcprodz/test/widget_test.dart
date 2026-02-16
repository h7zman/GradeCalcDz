import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gradecalcprodz/main.dart';

void main() {
  testWidgets('App bootstraps and shows onboarding first', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const GradeCalcApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Set Custom'), findsOneWidget);
    expect(find.text('Coefficients'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('App shows home when onboarding already completed', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});

    await tester.pumpWidget(const GradeCalcApp());
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('GradeCalcDZ'), findsOneWidget);
    expect(find.text('S1'), findsOneWidget);
    expect(find.text('Final Result'), findsOneWidget);
  });
}
