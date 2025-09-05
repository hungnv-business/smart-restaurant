import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartRestaurantApp());

    // Verify that our counter starts at 0.
    expect(find.text('Smart Restaurant'), findsOneWidget);
  });
}