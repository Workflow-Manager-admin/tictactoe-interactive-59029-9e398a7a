import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_app/main.dart';

void main() {
  testWidgets('TicTacToeApp can be built and key widgets present', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const TicTacToeApp());

    // The board should be present (lots of InkWell or AnimatedContainer widgets)
    expect(find.byType(AnimatedContainer), findsWidgets);

    // Should find standard scoreboard labels.
    expect(find.textContaining("X"), findsWidgets);
    expect(find.textContaining("O"), findsWidgets);
    expect(find.textContaining("Draw"), findsWidgets);
    // Mode select and button should be present.
    expect(find.textContaining("Player"), findsWidgets);
    expect(find.text("New Game"), findsOneWidget);
  });
}
