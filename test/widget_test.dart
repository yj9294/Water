import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water/core/storage/app_storage.dart';
import 'package:water/main.dart';

void main() {
  testWidgets('HydraPal renders home screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(WaterApp(storage: AppStorage(prefs)));
    await tester.pumpAndSettle();

    expect(find.text('HydraPal'), findsOneWidget);

    await tester.drag(find.text('HydraPal'), const Offset(0, -360));
    await tester.pumpAndSettle();

    expect(find.text('Quick hydration'), findsWidgets);
  });
}
