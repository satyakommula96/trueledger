import 'package:flutter_test/flutter_test.dart';
import 'package:truecash/main.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TrueCashApp(showIntro: false));

    // Verify that the title is present
    expect(find.text('TRUE CASH'), findsOneWidget);
  });
}
