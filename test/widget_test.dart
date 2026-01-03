import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mighty_app/main.dart';

void main() {
  testWidgets('Mighty app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MightyApp());
    expect(find.text('마이티'), findsOneWidget);
    expect(find.text('게임 시작'), findsOneWidget);
  });
}
