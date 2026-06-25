// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flame/game.dart';
import 'package:aetherius/home/space_shooter_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SpaceShooterGame smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(GameWidget(game: SpaceShooterGame()));

    // Verify that GameWidget is rendered.
    expect(find.byType(GameWidget<SpaceShooterGame>), findsOneWidget);
  });
}
