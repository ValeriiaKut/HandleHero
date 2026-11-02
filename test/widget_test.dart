import 'package:flutter_test/flutter_test.dart';
import 'package:handle_hero/main.dart';
import 'package:handle_hero/ui/home/home_page.dart';

void main() {
  testWidgets('App opens home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(HomePage), findsOneWidget);
  });
}
