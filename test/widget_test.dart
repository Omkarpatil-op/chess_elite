import 'package:flutter_test/flutter_test.dart';
import 'package:chess_elite/main.dart';
import 'package:chess_elite/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('App launches and renders SplashScreen with brand title', (WidgetTester tester) async {
    await tester.pumpWidget(const ChessEliteApp());
    await tester.pump(const Duration(milliseconds: 50));

    // Expect brand title in splash screen
    expect(find.text('CHESS ELITE'), findsOneWidget);
    expect(find.text('GRANDMASTER EDITION'), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
