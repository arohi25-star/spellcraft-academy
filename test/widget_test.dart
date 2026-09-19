import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellcraft_academy/main.dart';
import 'package:spellcraft_academy/services/auth_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AuthService.instance.resetForTesting();
    await AuthService.instance.initialize();
  });

  tearDown(() async {
    await AuthService.instance.signOut();
  });

  testWidgets('Welcome screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SpellCraftApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('SPELLCRAFT'), findsOneWidget);
    expect(find.text('ACADEMY'), findsOneWidget);
    expect(find.text('ENTER THE ACADEMY'), findsOneWidget);
  });
}
