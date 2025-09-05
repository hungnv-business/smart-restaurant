import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuanBiaApp());

    // Verify that our app loads with correct title.
    expect(find.text('Quán bia'), findsOneWidget);
  });
}